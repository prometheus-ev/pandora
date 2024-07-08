class Indexing::IndexTasks
  def initialize(options = {})
    @options = options.reverse_merge(verbose: !Rails.env.test?)
  end

  def status
    results = get_status
    headers = [:name, :pandora, :dump, :alias, :indices]
    paddings = [30, 7, 6, 4, 5, 0]

    results = results.values.sort_by!{|r| r[:name]}

    out = headers.map.with_index do |h, i|
      h.to_s.ljust(paddings[i])
    end.join(' | ')
    Pandora.puts out

    out = results.map do |r|
      headers.map.with_index do |h, i|
        r[h].to_s.ljust(paddings[i])
      end.join(' | ')
    end.join("\n")
    Pandora.puts out
  end

  def dump(indices)
    FileUtils.mkdir_p base_dir

    if indices[0] == 'all'
      indices = elastic.aliases
    elsif indices.empty?
      Pandora.puts "No indices selected."
      Pandora.puts
      Pandora.puts 'Usage e.g: pandora:index:dump INDEX="daumier robertin", or pandora:index:dump INDEX="all"'
    end

    indices.each do |index|
      # get the mapping
      settings = elastic.settings(index).values.first['settings']
      mappings = elastic.mappings(index).values.first['mappings']

      # retrieve the records
      records = []

      start_progress(index, elastic.total(index))
      elastic.each_doc index, batch_size: 25000 do |hit|
        hit['_source'] = Indexing::Attachments.strip(hit['_source'])
        records << hit

        progress
      end

      # new_records = elastic.scan(index, 25000)
      # scroll_id = new_records['_scroll_id']
      # start_progress(index, new_records['hits']['total']['value'])
      # while current_progress < new_records['hits']['total']['value']
      #   records += new_records['hits']['hits'].map do |hit|
      #     hit.merge('_source' => Indexing::Attachments.strip(hit['_source']))
      #   end
      #   progress(new_records['hits']['hits'].size)
      #   new_records = elastic.continue(scroll_id)
      #   scroll_id = new_records['_scroll_id']
      # end

      # dump the data to a file
      write file(index), JSON.dump(
        'mappings' => mappings,
        'settings' => settings,
        'records' => records
      )
    end
  end

  def load(indices, update_mapping = false)
    FileUtils.mkdir_p base_dir

    if indices[0] == 'all'
      indices = files.map{|f| f.split('/').last.split('.').first}
    elsif indices.empty?
      Pandora.puts "No indices selected."
      Pandora.puts
      Pandora.puts 'Usage, e.g: pandora:index:load INDEX="daumier robertin", or pandora:index:load INDEX="all"'
    end

    indices.each do |alias_name|
      data = JSON.parse(read file(alias_name))

      # we need to ensure the source because the attachments are referencing
      # it, we will still update it below with the correct data
      source = Source.find_and_update_or_create_by(name: alias_name,
                                                   record_count: 0)

      # create a new index with mapping
      settings = fix_settings(data['settings'])

      if update_mapping
        new_index_name = elastic.create_index alias_name, settings, Indexing::IndexMappings.read
      else
        new_index_name = elastic.create_index alias_name, settings, data['mappings']
      end

      attachments = Indexing::Attachments.new(alias_name)

      # bulk import the records
      start_progress("importing #{alias_name}", data['records'].size)

      data['records'].each do |record|
        record['_source'] = attachments.enrich(record['_source'])

        elastic.bulk([
          {'create' => {'_index' => new_index_name, '_id' => record['_id']}},
          record['_source']
        ], batch_size: 500)

        progress
      end

      elastic.bulk_commit refresh: true
      elastic.add_alias_to(index_name: new_index_name)
      elastic.cleanup_backups_of(alias_name: alias_name)

      Source.find_and_update_or_create_by(name: alias_name,
                                          is_time_searchable: source.type == 'dump' ? source.respond_to?('date_range') : false,
                                          record_count: data['records'].count)
    end
  end

  def drop(index)
    case index
    when :all then drop(elastic.aliases)
    when Array
      if index.empty?
        Pandora.puts "no indices selected"
      else
        index.map{|s| drop(s)}
      end
    when String
      # remove all indices <index>_*
      elastic.destroy_index(index + '*')
    end
  end

  def check(index)
    case index
    when :all then check(files.map{|f| f.split('/').last.split('.').first})
    when Array
      if index.empty?
        Pandora.puts "no indices selected"
      else
        index.map{|s| check(s)}
      end
    when String
      errors = []
      data = JSON.parse(read file(index))
      start_progress("checking #{index}", data.size)
      data.each do |record|
        errors += validate(record)
        progress
      end
      Pandora.puts errors
    end
  end

  def revert(index)
    case index
    when :all then revert(elastic.aliases.keys)
    when Array
      if index.empty?
        Pandora.puts "no indices selected"
      else
        index.map{|s| revert(s)}
      end
    when String
      current_index_version = elastic.index_version_of(alias_name: index)
      previous_index_name = "#{index}_#{current_index_version - 1}"
      if elastic.index_exists?(previous_index_name)
        elastic.add_alias_to(index_name: previous_index_name)
      end
    end
  end

  # Download the VGBK artists CSV file and transform it to a YAML file.
  #
  # For further information about the artists file, see:
  #
  # https://www.bildkunst.de/service/kuenstler-suche.html
  #
  # Use "Download aller Künstler mit Onlinerechten als CSV-Datei", see url below.
  def update_vgbk_artists
    csv_filename = File.join(Dir.tmpdir, "#{Time.now.to_i}-vgbk-artists.csv")
    yml_filename = Rails.root.join('config', 'indexing-vgbk-artists.yml')
    url = 'https://bildkunst-onlinemeldung.de/api/search/file/1'

    # https://ruby-doc.org/stdlib-2.5.3/libdoc/net/http/rdoc/Net/HTTP.html
    Pandora.puts "Downloading " + csv_filename + "... \r"
    open csv_filename, 'wb' do |io|
      response = fetch(url)
      io.write response.body # .encode(Encoding::UTF_8)
    end
    Pandora.puts "Downloading " + csv_filename + "... finished!\n"

    # https://ruby-doc.org/stdlib-2.5.3/libdoc/csv/rdoc/CSV.html
    Pandora.puts "Reading " + csv_filename + "... \r"
    # col_sep \t represents a tab. Now a ';' is used.
    csv_content = CSV.read(csv_filename, headers: true, encoding: "ISO-8859-1:UTF-8", col_sep: ";", liberal_parsing: true)
    Pandora.puts "Reading " + csv_filename + "... finished!\n"

    Pandora.puts "Writing #{yml_filename}... \r"
    File.open(yml_filename, 'w') {|file|
      file.puts "<%= Rails.env %>:"
      file.puts "  artists:"
      csv_content.each {|row|
        artist = row.field(1) || ""
        artist = artist[0...-1] if artist.chars.last == "*"
        artist << " " unless artist.empty?
        artist << row.field(0)
        artist = artist[0...-1] if artist.chars.last == "*"
        artist = artist.gsub("'", "''") if artist.include?("'")
        artist = artist.gsub("\"", "") if artist.include?("\"")
        file.puts "    - '" + artist.downcase + "'"
      }
    }
    Pandora.puts "Writing #{yml_filename}... finished!\n"
  end

  def write_vgbk_artist_records_as_csv
    elastic = Pandora::Elastic.new
    query = {
      term: {
        rights_work: 'rights_work_vgbk'
      }
    }
    file = "#{Rails.root}/tmp/vgbk_artist_records.csv"
    headers = ['Link to prometheus record', 'Artist', 'Title']
    encoding = 'UTF-8'

    csv = CSV.generate(col_sep: ';', quote_char: '"', encoding: encoding, write_headers: true, headers: headers) do |writer|
      elastic.pit

      while (records = elastic.pit_search_after(query: query)['hits']['hits']).size > 0
        records.each do |record|
          link = "#{ENV['PM_BASE_URL']}/de/image/#{record["_source"]["record_id"]}"
          artist = ''
          title = ''

          if artist_normalized = record["_source"]["artist_normalized"]
            artist = if artist_normalized.is_a? Array
              artist_normalized.join(' | ')
            else
              artist_normalized
            end
          end

          if title = record["_source"]["title"]
            if title.is_a? Array
              title = title.join(' | ')
            end
          end

          writer << [link, artist, title]
        end
      end

      elastic.pit_delete
    end

    File.write(file, csv)
  end

  def update_pknd_artists
    xml_filename = Rails.root.join('config', 'synonyms', 'pknd.xml')
    txt_filename = Rails.root.join('config', 'synonyms', 'pknd.txt')

    # http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML
    document = Nokogiri::XML(File.open(xml_filename)) do |config|
      # http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/ParseOptions
      config.noblanks.huge
    end

    document.remove_namespaces!

    # https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Document#errors-instance_method
    if document.errors.size != 0
      document.errors.map{|error| Pandora.puts error}
      error 'Please correct the syntax errors and try again...'
    end

    # Select all artists.
    artists = document.xpath('//term')

    File.open(txt_filename, 'w') do |f|
      artists.each do |artist|
        main_artist = artist.xpath('./name/text()').to_a
        sub_artists = artist.xpath('./sub/name/text()').to_a

        artist = main_artist + sub_artists

        # Preprocess.
        artist.map! {|synonym_artist|
          synonym_artist.content.gsub(/,? Künstlerin/, '')
          synonym_artist.content.gsub(/,? Künstler/, '')
        }

        last_names = artist.map {|synonym_artist|
          synonym_artist = synonym_artist.split(',')
          if synonym_artist.size == 1
            synonym_artist[0]
          else
            nil
          end
        }

        reversed_names = artist.map {|synonym_artist|
          synonym_artist = synonym_artist.split(', ')

          if synonym_artist.size == 4
            [synonym_artist[2], synonym_artist[0], synonym_artist[1], synonym_artist[3]].join(' ')
          elsif synonym_artist.size == 3
            [synonym_artist[1], synonym_artist[0], synonym_artist[2]].join(' ')
          elsif synonym_artist.size == 2
            synonym_artist.reverse.join(' ')
          else # A size of 1 or > 3 is not used at the moment.
            nil
          end
        }

        artist = last_names + reversed_names

        # Cleanup.
        artist = artist.compact.uniq.join(', ')

        if !artist.blank?
          f.puts artist
        end
      end
    end
  end

  private

    def fetch(uri_str, limit = 10)
      # You should choose a better exception.
      raise ArgumentError, 'too many HTTP redirects' if limit == 0

      response = Net::HTTP.get_response(URI(uri_str))

      case response
      when Net::HTTPSuccess then
        response
      when Net::HTTPRedirection then
        location = response['location']
        warn "redirected to #{location}"
        fetch(location, limit - 1)
      else
        response.value
      end
    end

    def start_progress(title, total)
      require 'ruby-progressbar'
      @progress = ProgressBar.create(
        title: title,
        total: total,
        format: "%t |%B| %c/%C (+%R/s) | %a |%f",
        output: @options[:verbose] ? STDERR : File.open('/dev/null', 'w')
      )
    end

    def progress(amount = 1)
      @progress.progress += amount
    end

    def current_progress
      @progress.progress
    end

    def fix_settings(settings)
      settings['index'].delete('provided_name')
      settings['index'].delete('creation_date')
      settings['index'].delete('uuid')
      settings['index'].delete('version')

      filters = settings['index']['analysis']['filter']
      filters.each_value do |filter|
        if path = filter['synonyms_path']
          file = path.split('/').last
          new_path = "#{ENV['PM_SYNONYMS_DIR']}/#{file}"
          filter['synonyms_path'] = new_path
        end
      end

      settings
    end

    def validate(record)
      results = []

      title = record['_source']['title']
      if title.is_a?(Array)
        if title.size != 1
          results << "record #{record['_id']}: title should have exactly one element: #{title.inspect}"
        end
      else
        results << "record #{record['_id']}: title is not an array: #{title.inspect}"
      end

      results
    end

    def get_status
      results = {}

      elastic.aliases.each_key do |a|
        results[a] ||= {name: a}
        results[a][:alias] = true
      end

      elastic.indices.each do |i|
        source = i['index'].gsub(/_\d+$/, '')
        results[source] ||= {name: source}
        results[source][:indices] ||= []
        results[source][:indices] << i['index']
      end

      Source.all.each do |s|
        results[s.name] ||= {name: s.name}
        results[s.name][:pandora] = true
      end

      files.each do |f|
        source = f.split('/').last.split('.').first
        results[source] ||= {name: source}
        results[source][:dump] = true
      end

      results.delete 'upload'

      results
    end

    def base_dir
      @base_dir = ENV['PM_INDEX_PACK_DIR']
    end

    def files
      Dir["#{base_dir}/*.json.gz"]
    end

    def file(name)
      "#{base_dir}/#{name}.json.gz"
    end

    def write(file, data)
      FileUtils.rm file, force: true
      plain = file.gsub(/\.gz$/, '')
      File.open(plain, 'w'){|f| f.write data}
      system "gzip #{plain}"
    end

    def read(file)
      raise "#{file} doesn't exist" unless File.exist?(file)

      `gunzip -c #{file}`
    end

    def elastic
      @elastic ||= Pandora::Elastic.new
    end
end
