# Coordinates the image vector retrieval from various sources. Retrieves
# existing vector data from JSON files and updates them. Image data is cached in
# the {Pandora::SuperImage} which can also be used for retrieval:
# @example
#   si = Pandora::SuperImage.new('robertin-1234')
#   p si.vectors
# @example start a simple run with all collectors and persist the results
#   pids = ['mysource1-12345...', 'mysource2-67890...']
#   iv = Pandora::ImageVectors.new
#   iv.generate(pids)
#   iv.persist!
#
# @example only use a subset of available collectors
#   klasses = [Pandora::ImageVectors::DomainantColors]
#   Pandora::ImageVectors.new.generate(pids, klasses)
# @example a single image vector record
#   {
#     "robertin-12345" => {
#       "ignore" => false,
#       "mtime" => 2345234554,
#       "size" => 1234,
#       "last_run" => 453234,
#       "features" => {
#         "colors" => {},
#         "similarity" => {}
#       }
#     }
#   }
class Pandora::ImageVectors
  def self.for_sources(source_ids, klasses = nil)
    klasses = (klasses.nil? ?
               self.klasses :
               klasses.map{|k| "Pandora::ImageVectors::#{k.camelize}".constantize.new})

    iv = new

    Pandora.puts("#{source_ids.join(', ')}: loading vectors...")

    Pandora::Elastic.new.with_records(source_ids) do |record|
      pid = record['_source']['record_id']
      iv.generate([pid], klasses)
    end

    Pandora.puts

    iv.persist!

    (klasses || self.class.klasses).each do |klass|
      Pandora.puts "#{source_ids.join(', ')}: #{klass.count} #{klass.class.id} vectors added."
    end
  end

  def self.for_pids(pids, klasses = nil)
    klasses = (klasses.nil? ?
               self.klasses :
               klasses.map{|k| "Pandora::ImageVectors::#{k.camelize}".constantize})

    iv = new
    iv.generate([pids], klasses)
    iv.persist!
  end

  def self.drop(source_ids)
    files = (source_ids == ['all'] ?
      Dir["#{ENV['PM_VECTORS_DIR']}/*"] :
      source_ids.map{|i| "#{ENV['PM_VECTORS_DIR']}/#{i}.json"})

    system 'rm', '-f', *files
  end

  def initialize
    @generated_count = 0
    @fresh_count = 0
    @missing_count = 0
  end

  def generate(pids, klasses = nil)
    now = Time.now.utc

    todo = pids.select do |pid|
      si = Pandora::SuperImage.new(pid)
      file = si.original_filename
      select = false

      if !file.blank? && !File.exist?(file)
        si.image_data(:small, {curl_transfer_max_time: "5"})
      end

      if file.blank? || !File.exist?(file)
        @missing_count += 1
      elsif fresh?(file, si.vectors)
        @fresh_count += 1
      else
        # If the file exists and JSON has a file size of 0,
        # the JSON file has been batch generated on prometheus-srv
        # and ony needs updated matadata.
        if si.vectors['size'] == 0
          si.vectors.merge!(
            'last_run' => now,
            'mtime' => File.stat(file).mtime.utc,
            'size' => File.size(file)
          )
          @fresh_count += 1
        else
          @generated_count += 1
          select = true
        end
      end

      Pandora.printf("\e[K%s: %s (generated), %s (fresh), %s (missing file)\r",
                     si.source_id,
                     @generated_count,
                     @fresh_count,
                     @missing_count)
      select
    end

    (klasses || self.class.klasses).each do |klass|
      klass.generate(todo).each do |pid, record|
        si = Pandora::SuperImage.new(pid)
        data = si.vectors
        data ||= {}
        data['features'] ||= {}
        data['features'][klass.class.id] = record
      end
    end

    todo.each do |pid|
      si = Pandora::SuperImage.new(pid)
      file = si.original_filename
      si.vectors.merge!(
        'last_run' => now,
        'mtime' => File.stat(file).mtime.utc,
        'size' => File.size(file)
      )
    end

    Pandora::SuperImage.vectors
  end

  def fresh?(path, vectors)
    return false unless vectors
    return true if vectors['ignore'] == true
    return false unless vectors['last_run']

    original_path = path
    if File.exist?(original_path)
      mtime = File.stat(original_path).mtime.utc

      if vectors['mtime'].is_a?(String)
        mtime = mtime.strftime("%Y-%m-%d %H:%M:%S UTC")
      end

      if vectors['mtime'] && vectors['mtime'] < mtime
        return false
      end

      size = File.size(original_path)
      if vectors['size'] != size
        return false
      end
    end

    if vectors['last_run'] && vectors['last_run'] < 1.year.ago
      return false
    end

    true
  end

  def persist!
    system 'mkdir', '-p', ENV['PM_VECTORS_DIR']

    Pandora::SuperImage.vectors.each do |source, data|
      filename = "#{ENV['PM_VECTORS_DIR']}/#{source}.json"
      File.write(filename, JSON.dump(data))
    end

    Pandora::SuperImage.expire_vectors!
  end

  def self.klasses
    return [
      Similarity,
      DominantColors
    ]
  end
end
