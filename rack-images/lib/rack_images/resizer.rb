require 'yaml'
require 'tmpdir'
require 'cgi'

class RackImages::Resizer

  def run(path)
    if path.match(/\/not-available$/)
      fail_with 'the requested image was requested with path "not available", we will therefore not try to retrieve it'
    end

    # TODO: this shouldn't be necessary as the urls are verified via hash and
    # they are created by pandora
    # for example: /robertin/r400x400/B130c.jpg
    # without decimal places
    if m = path.match(/^\/([a-z_]+)\/([ropxm0-9\.]+)\/(.*)$/)
      @db, @dimensions, @upstream_path = m.to_a[1..-1]

      # in order to avoid problems with urldecoding by web servers, we encode
      # the upstream path with base64 when generating image urls. Therefore, we
      # need to decode it here
      @upstream_path = self.class.try_decode64(@upstream_path)

      generate unless File.exists?(cache_file)
      File.open cache_file
    elsif m = path.match(/^\/([a-z_]+)\/original\/(.*)$/)
      @db, @upstream_path = m.to_a[1..-1]

      # see above
      @upstream_path = self.class.try_decode64(@upstream_path)

      ensure_original
      File.open original_file
    else
      fail_with "'#{path}' does not match any of the recognized patterns"
    end
  end

  def generate
    ensure_original

    system 'mkdir', '-p', File.dirname(cache_file)

    cmd = ['convert', original_file]
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
    if File.exists?(original_file)
      return
    else
      RackImages::Server.logger.info(
        "no original found at '#{original_file}', trying to download from upstream"
      )
    end

    remote = original_sources[@db]

    unless remote
      # since the remote is missing, we will try to find a directory with
      # originals and symlink it to the images directory (unless the symlink
      # already exists)
      unless File.exists?(original_dir)
        candidate = "#{ENV['PM_ORIGINALS_DIR']}/#{@db}/original"

        if File.exists?(candidate)
          system 'mkdir', '-p', "#{data_dir}/#{@db}"
          system 'ln', '-sfn', candidate, "#{data_dir}/#{@db}"

          # now, we try again
          return if File.exists?(original_file)
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
