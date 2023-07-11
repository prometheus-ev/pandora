require 'yaml'
require 'tmpdir'
require 'cgi'

class RackImages::Resizer
  attr_reader :content_type

  def run(path)
    @content_type = 'image/jpeg'

    if path.match(/\/not-available$/)
      fail_with 'the requested image was requested with path "not available", we will therefore not try to retrieve it'
    end

    # TODO: this shouldn't be necessary as the urls are verified via hash and
    # they are created by pandora
    # for example: /robertin/r400x400/B130c.jpg
    # without decimal places
    if m = path.match(/^\/([a-z0-9_]+)\/([ropxm0-9\.]+)\/(.*)$/)
      @db, @dimensions, @upstream_path = m.to_a[1..-1]
      msg = "path '#{path}' parsed as db:#{@db}, dims:#{@dimensions}, upstream_path:#{@upstream_path}"

      # in order to avoid problems with urldecoding by web servers, we encode
      # the upstream path with base64 when generating image urls. Therefore, we
      # need to decode it here
      @upstream_path = self.class.try_decode64(@upstream_path)

      # we also want to log the decoded path
      msg += ", decoded:#{@upstream_path}"
      self.class.info(msg)

      unless File.exist?(cache_file)
        self.class.info("no cached file found at #{cache_file}, generating ...")
        generate
      end

      File.open cache_file
    elsif m = path.match(/^\/([a-z0-9_]+)\/original\/(.*)$/)
      @db, @upstream_path = m.to_a[1..-1]
      msg = "path '#{path}' parsed as db:#{@db}, dims:<original>, upstream_path:#{@upstream_path}"

      # see above
      @upstream_path = self.class.try_decode64(@upstream_path)

      # we also want to log the decoded path
      msg += ", decoded:#{@upstream_path}"
      self.class.info(msg)

      ensure_original
      @content_type = content_type_for(original_file)
      File.open original_file
    else
      fail_with "'#{path}' does not match any of the recognized patterns"
    end
  end

  # drop all resolution files for a given pid
  def drop(db, pid)
    original = "#{data_dir}/#{db}/original/#{pid}.jpg"
    files = Dir["#{data_dir}/#{db}/*/#{pid}.jpg"] - [original]
    system 'rm', '-f', *files
  end

  def generate
    ensure_original

    original = original_file

    if is_video?(original_file)
      self.class.info('video file')
      system 'mkdir', '-p', File.dirname(frame_file)

      unless File.exist?(frame_file)
        self.class.info('frame not extracted yet, extracting ...')
        extract_frame(original_file, frame_file)
      end

      original = frame_file
    end

    system 'mkdir', '-p', File.dirname(cache_file)

    resize_image(original, cache_file)
  end

  def is_video?(file)
    cmd = ['file', '-i', '-b', file]

    status, stdout, stderr = RackImages.run(cmd)

    unless status == 0
      fail_with "could not determine original mime type. Command used: #{cmd.inspect}, stderr: #{stderr}"
    end

    mime = stdout.split(' ')[0]
    !!mime.match?(/^video\/.*/)
  end

  def is_pdf?(file)
    content_type = content_type_for(file)
    !!content_type.match?(/^application\/pdf.*/)
  end

  def content_type_for(file)
    cmd = ['file', '--mime-type', '-b', file]

    status, stdout, stderr = RackImages.run(cmd)

    unless status == 0
      fail_with "could not determine original mime type. Command used: #{cmd.inspect}, stderr: #{stderr}"
    end

    stdout.strip
  end

  def resize_image(original_file, target_file)
    cmd = ['convert']
    if is_pdf?(original_file)
      cmd << '-flatten'
    end
    cmd << "#{original_file}[0]"
    if r = directives[:crop]
      cmd += ['-crop', "#{r[:geometry]}"]
    end
    if r = directives[:resize]
      cmd += ['-resize', "#{r[:width]}x#{r[:height]}#{r[:mode]}"]
    end
    cmd << cache_file

    status, stdout, stderr = RackImages.run(cmd)

    unless status == 0
      fail_with "image could not be converted. Command used: #{cmd.inspect}, stderr: #{stderr}"
    end
  end

  def extract_frame(original_file, target_file, frame=0)
    cmd = [
      'ffmpeg', '-i',
      original_file,
      '-vf', "select=eq(n\\,#{frame})", '-vframes', '1',
      target_file
    ]

    status, stdout, stderr = RackImages.run(cmd)

    unless status == 0
      fail_with "frame could not be extracted from video. Command used: #{cmd.inspect}, stderr: #{stderr}"
    end
  end

  def directives
    result = {}

    # r = /^r(\d+)x(\d+)$/
    # if m = @dimensions.match(r)
    #   result[:resize] = {width: m[1], height: m[2]}
    # end

    # r = /^r(\d+)$/
    # if m = @dimensions.match(r)
    #   result[:resize] = {width: m[1], height: m[1]}
    # end

    # r = /^r(\d+)o(\d+)x(\d+)p(\d+)p(\d+)$/
    # if m = @dimensions.match(r)
    #   result[:resize] = {width: m[1], height: m[1]}
    #   result[:crop] = {geometry: "#{m[2]}x#{m[3]}+#{m[4]}+#{m[5]}"}
    # end

    if m = @dimensions.match(/^r(\d+(?:\.\d+)?)x(\d+(?:\.\d+)?)$/)
      result[:resize] = {width: m[1], height: m[2], mode: '>'}
    elsif m = @dimensions.match(/r(\d+)m/)
      result[:resize] = {width: m[1], height: m[1], mode: '^>'}
    elsif m = @dimensions.match(/^r(\d+(?:\.\d+)?)$/)
      result[:resize] = {width: m[1], height: m[1], mode: '>'}
    elsif m = @dimensions.match(/(?:(?:r(\d+(?:\.\d+)?)(?:x(\d+(?:\.\d+)?))?)|(?:o(\d+(?:\.\d+)?)x(\d+(?:\.\d+)?)[pm](\d+(?:\.\d+)?)[pm](\d+(?:\.\d+)?))){1,2}/)
      result[:resize] = {width: m[1], height: m[2] || m[1], mode: '>'}
      result[:crop] = {geometry: "#{m[3]}x#{m[4]}+#{m[5]}+#{m[6]}"}
    end

    result
  end

  def ensure_original
    if File.exist?(original_file)
      return
    else
      self.class.info("no original found at '#{original_file}', trying to download from upstream")
    end

    remote = original_sources[@db]

    unless remote
      # since the remote is missing, we will try to find a directory with
      # originals and symlink it to the images directory (unless the symlink
      # already exists)
      unless File.exist?(original_dir)
        candidate = "#{ENV['PM_ORIGINALS_DIR']}/#{@db}/original"

        if File.exist?(candidate)
          system 'mkdir', '-p', "#{data_dir}/#{@db}"
          system 'ln', '-sfn', candidate, "#{data_dir}/#{@db}"

          # now, we try again
          return if File.exist?(original_file)
        end
      end

      fail_with [
        "#{@db} has no upstream url defined.",
        "Perhaps the images should be in #{ENV['PM_IMAGES_DIR']}/#{@db}/original?"
      ].join(' ')
    end

    url = "#{remote}#{@upstream_path}"

    # TODO: only used for artemis source. Indexer changed, remove after mid 2021
    url.gsub! '$@$', '?'

    if File.symlink?(original_dir)
      fail_with [
        "Found an url for #{@db}, but the relevant original directory is a",
        'symlink which indicates that originals should be read from there',
        'instead an url, aborting'
      ].join(' ')
    end

    # we do this with curl since it reliably supports https proxies and this
    # is a relatively rare process (so no performance issues expected by
    # spawning a process each time)
    Dir.mktmpdir 'rack-images-' do |dir|
      tmp_file = "#{dir}/image.dat"
      cmd = ['curl', '-L', '--fail', '--max-time', '10']
      cmd << "--proxy \"#{proxy}\"" if proxy
      cmd << url

      status, stdout, stderr = RackImages.run(cmd, stdout: tmp_file)

      if status == 0
        system 'mkdir', '-p', File.dirname(original_file)
        system 'mv', tmp_file, original_file
      else
        fail_with "url #{url} could not be retrieved. Command used: #{cmd.inspect}, stderr: #{stderr}"
      end
    end
  end

  def cache_file
    result = "#{cache_dir}/#{upstream_base_path}"
    result.gsub!(/\.[a-zA-Z0-9]+$/, '')
    "#{result}.jpg"
  end

  def original_file
    result = "#{original_dir}/#{@upstream_path}"

    # TODO: some sources are indexed with uri escaped strings which doesn't
    # match the file names of the originals (in the cases in which they are)
    # hosted by prometheus), so we need to revert this
    result = CGI.unescape(result)

    result
  end

  def upstream_base_path
    @upstream_path.gsub(/\.[a-zA-Z0-9]$/, '')
  end

  def original_dir
    "#{data_dir}/#{@db}/original"
  end

  def cache_dir
    "#{data_dir}/#{@db}/#{@dimensions}"
  end

  def frame_file
    "#{data_dir}/#{@db}/frames/#{upstream_base_path}.jpg"
  end

  def data_dir
    ENV['PM_IMAGES_DIR']
  end

  def original_sources
    @original_sources ||= YAML.load_file("#{ENV['PM_ORIGINALS_YML_DIR']}/originals.yml")
  end

  def proxy
    result = ENV['PM_IMAGE_PROXY']
    result && result != '' ? result : nil
  end

  def self.info(msg)
    RackImages::Server.logger.info msg
  end

  def fail_with(message)
    raise RackImages::Exception, message
  end

  def self.encode64(str)
    Base64.urlsafe_encode64(str, padding: false)
  end

  def self.decode64(str)
    Base64.urlsafe_decode64(str)
  end

  def self.try_decode64(str)
    decode64(str)
  rescue => e
    str
  end
end
