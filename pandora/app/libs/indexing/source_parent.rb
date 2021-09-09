# Super class of all source subclasses responsible for indexing subclasses and
# for creating a source model database record.
#
# When indexing data, start the Rails console:
# * Development:
#     bundle exec rails console
# * Production:
#     bundle exec rails console -e production
#
# == Indexing
# Index a single source file:
#   BerlinUdk.index
# Index array of source names:
#   SourceParent.index_array(sources: ["robertin", "theoleik"])
# Index all source files where the filename starts with d, e, and f using a glob pattern as first parameter:
#   SourceParent.index_all(glob_pattern: "[d-f]*")
# Index all source files:
#   SourceParent.index_all
#
# == Counting
# To count index records of a source subclass, use the instance method count, e.g.:
#   Artemis.new.count
# see {count}. It is also possible to count index records via the index class:
#   Indexing::Index.count("artemis")
# see {Indexing::Index.count}.
# To count XML record nodes of a subclass, use, e.g.:
#   Artemis.new.records.count
# To count the number of source model instances, use the class method:
#   SourceParent.count
# E.g. Artemis.count returns the same, since, when not instantiated, accesses the count method of the super class (SourceParent).
require "net/http"

class Indexing::SourceParent
  attr_accessor :name
  attr_accessor :record

  KLAPSCH_FILTER = "*Klapsch*"

  #############################################################################
  # Class methods
  #############################################################################

  def self.logger
    Rails.logger
  end

  # Get Source names as array of strings.
  #
  # @return [Array] An array of Source name strings.
  def self.names
    Source.all.map { |source|
      source.name
    }
  end

  # Index a Source subclass.
  #
  # @param log [Boolean] Enable the log.
  def self.index(create_institutional_uploads: false, log: false)
    source = new(create_institutional_uploads: create_institutional_uploads, log: log)
    superclass = source.class.superclass
    superclass_name = "Indexing::SourceSuper"

    if (superclass.name == superclass_name ||
        (superclass.superclass && superclass.superclass.name == superclass_name))
      self.index_array(sources: [source.name.underscore], create_institutional_uploads: create_institutional_uploads, log: log)
    else
      logger.error "Only sources available in directory app/libs/indexing/sources can be indexed."
    end
  end

  # Index all source files available, restrict them by a glob pattern.
  #
  # @param glob_pattern [String] Add a glob pattern to restrict the files that should be indexed.
  # @see https://ruby-doc.org/core-2.1.5/Dir.html#method-c-glob
  # @param log [Boolean] Enable the log.
  def self.index_all(glob_pattern: "*", time: false, log: false)
    source_files = Dir.glob("app/libs/indexing/sources/" + glob_pattern + ".rb")
    sources = source_files.map { |source_file|
      File.basename(source_file, ".rb")
    }
    self.index_array(sources: sources, time: time, log: log)
  end

  # Index an Array of source names.
  #
  # @param source_names [Array] An Array of source names.
  # @param log [Boolean] Enable the log.
  def self.index_array(sources: [], time: false, create_institutional_uploads: false, log: false)
    if time
      sources = sources.delete_if { |source|
        source = source.camelize.constantize.new(create_institutional_uploads: create_institutional_uploads, log: log)
        !source.respond_to?('date_range')
      }
    end

    logger.info "Sources to index:"
    logger.info sources.sort

    remaining_sources = sources
    number_of_sources = sources.count
    number_of_current_source = 0
    records_indexed_total = 0

    sources.sort.each { |source|
      source = source.camelize.constantize.new(create_institutional_uploads: create_institutional_uploads, log: log)
      number_of_current_source += 1
      logger.info "Indexing source #{number_of_current_source}/#{number_of_sources}, #{source.name}..."

      s = Source.find_by_name(source.name)

      if s && s.type == 'upload'
        records_indexed = s.index
      else
        if Indexing::Index.client(log).indices.exists_alias(name: source.name)
          current_index_name = Indexing::Index.client(log).indices.get_alias(name: source.name).keys[0].dup
          current_index_count = current_index_name.split("_")[-1].to_i
        else
          current_index_count = 0
        end

        new_index_name = source.name + "_" + (current_index_count + 1).to_s

        Indexing::Index.delete(new_index_name, log)
        Indexing::Index.create(new_index_name, log)

        # Ensure cluster health so that the new index is actually ready to
        # be used (set 10s timeout though).
        path = "_cluster/health/#{new_index_name}?wait_for_status=green&timeout=10s"
        Indexing::Index.client(log).perform_request('GET', path)

        records_indexed = source.index(current_index_count, log)
      end

      remaining_sources = remaining_sources - [source.name]

      records_indexed_total += records_indexed
      logger.info "Total records indexed: #{records_indexed_total}"
      logger.info "-" * 100
      logger.info "Remaining sources:"
      logger.info remaining_sources.sort
    }

    logger.info ""
    klapsch_record_ids = filter_records(Indexing::Index.aliases, KLAPSCH_FILTER)
    logger.info "#{klapsch_record_ids.size} indexed records containing \"#{KLAPSCH_FILTER}\":"
    klapsch_record_ids.each do |klapsch_record_id|
      logger.info klapsch_record_id
    end
    logger.info ""

    records_indexed_total
  end

  # Convenience class method for searching a source index.
  def self.search(query = '*', field = 'all', from = 0, size = 10, log = false, pretty: false)
    Indexing::Index.search(self.name.split('::').last.underscore, query, field, from, size, log, pretty: pretty)
  end

  def self.filter_records(sources, filter)
    record_ids = []
    # from + size can not be more than the index.max_result_window index setting which defaults to 10,000.
    # Cf.: https://www.elastic.co/guide/en/elasticsearch/reference/2.4/search-request-from-size.html
    Indexing::Index.search(sources, filter, 'all', 0, 10000)["hits"]["hits"].each do |h|
      record_ids.push h["_id"]
    end
    record_ids
  end

  #############################################################################
  # Instance methods
  #############################################################################

  def initialize(create_institutional_uploads: false, log: false)
    self.name = self.class.name.split('::').last.underscore
    @create_institutional_uploads = create_institutional_uploads
    @index = Indexing::Index.new(log)
  end

  def logger
    @logger ||= Rails.logger
  end

  # Index a Source subclass. If necessary the index is created.
  #
  # @param current_index_count [Integer] The number of the current index.
  # @param log [Boolean] Enable the log.
  # @todo Notify user per email if anything goes wrong.
  def index(current_index_count, log = false)
    previous_index_name = name + "_" + (current_index_count - 1).to_s
    current_index_name = name + "_" + current_index_count.to_s
    new_index_name = name + "_" + (current_index_count + 1).to_s
    @records_indexed = 0
    @records_excluded = 0
    @records_updated = 0
    @records_created = 0
    recs = nil

    benchmark = Benchmark.realtime {
      directory = Rails.configuration.x.dumps_path + name
      if File.directory?(directory)
        logger.info "Number of dump files: " + Dir.children(directory).count.to_s
        Dir.each_child(directory) do |file|
          # Do not process directories, only XML and JSON files.
          if !File.directory?(file) && (File.extname(file) == '.xml' || File.extname(file) == '.json')
            # Call records from the subclass.
            recs = records(file)
            if !process_records(recs, new_index_name, log)
              return 0
            end
          end
        end
      else
        recs = records
        if !process_records(recs, new_index_name, log)
          return 0
        end
      end

      # Refresh the index only once after indexing to make changes searchable.
      # https://www.rubydoc.info/gems/elasticsearch-api/Elasticsearch/API/Indices/Actions#refresh-instance_method
      @index.client.indices.refresh index: new_index_name

      # Zero downtime update of alias with new index.
      # Check if a previous version of the index exists.
      if current_index_count > 0
        # Delete the previous index from the alias and add the new one.
        # http://www.rubydoc.info/gems/elasticsearch-api/Elasticsearch/API/Indices/Actions#update_aliases-instance_method
        @index.client.indices.update_aliases body: {
          actions: [
            { remove: { index: current_index_name, alias: name } },
            { add:    { index: new_index_name, alias: name } }
          ]
        }
        @index.delete(previous_index_name)
      else
        @index.delete(name)
        # Add the new index to the alias.
        # http://www.rubydoc.info/gems/elasticsearch-api/Elasticsearch/API/Indices/Actions#put_alias-instance_method
        @index.client.indices.put_alias(index: new_index_name, name: name)
      end
    }

    logger.info "\nFinished indexing #{name} in #{benchmark} s, #{benchmark / 60} min."
    logger.info "-" * 100
    logger.info "Index for alias " + name + ":"
    logger.info @index.client.indices.get_alias(name: name)
    logger.info "-" * 100
    logger.info "Index versions:"
    logger.info @index.client.indices.get(index: name + '*').keys
    logger.info "-" * 100

    if respond_to?('date_range')
      if @date_ranges_parse_failed.size > 0
        logger.info 'Unparseable datings of ' + name + ':'
        logger.info ''
        @date_ranges_parse_failed.each do |date_range_parse_failed|
          logger.info date_range_parse_failed
        end
        logger.info ''
        logger.info "Please update the dating preprocessor or the historical_dating Gem."
        logger.info ''
      end

      logger.info name + ' stats:'
      logger.info "#{@date_ranges_count} of #{@records_created} records do have datings."
      logger.info "#{@date_ranges_count - @date_ranges_parse_failed.size} datings could be parsed."
      logger.info "#{@date_ranges_parse_failed.size} datings could not be parsed."
    else
      logger.info name + ' is not configured for time search.'
      logger.info ''
      logger.info 'If you want it to, please add a date_range method to the source file in the following way:'
      logger.info ''
      logger.info 'def date_range'
      logger.info '  super(<date-as-string>)'
      logger.info 'end'
    end

    logger.info "-" * 100

    Source.find_and_update_or_create_by(name: name,
                                        is_time_searchable: respond_to?('date_range'),
                                        record_count: @records_created)

    logger.info "-" * 100
    index_ratings(name)
    logger.info "-" * 100
    index_comments(name)
    logger.info "-" * 100
    index_image_vectors(name)
    logger.info "-" * 100

    if @create_institutional_uploads
      Pandora::DilpsImporter.new(name).import
      logger.info "-" * 100
    end

    # Remove original and resized images on staging in order to see
    # if the can still be requested successfully.
    #
    # Surrounding a system command with backticks executes the command
    # and returns the output as string.
    if `hostname`.delete("\n") == 'prometheus2.uni-koeln.de'
      logger.info "-" * 100
      Pandora::ImagesDir.new.delete_upstream_images(name)
      logger.info "-" * 100
    end

    @records_created
  end

  # Index image vectors.
  #
  # @param index_name [String] The name of the index.
  # @param log [Boolean] Enable the log.
  def index_image_vectors(index_name = "_all", log = false)
    if File.exists?(vectors_file = File.join(ENV['PM_VECTORS_DIR'], '/', "#{name}.json"))
      logger.info "Parsing image vectors file..."
      image_vectors = JSON.parse(File.read(vectors_file))
    else
      logger.info "No image vectors file available..."
      return
    end

    image_vectors_indexed = 0
    image_vectors_count = image_vectors.size.to_s
    elastic = Pandora::Elastic.new
    bulk = []

    benchmark = Benchmark.realtime {
      logger.info "Image vectors counted: " + image_vectors_count

      if @index.client.indices.exists? index: index_name
        image_vectors.each do |image_vector|
          field_validator = Indexing::FieldValidator.new
          field_validator.validate('image_vector', image_vector['vector'])

          begin
            bulk += [
              {'update' => {'_index' => index_name, '_id' => image_vector['img_id']}},
              {'doc' => field_validator.validated_fields}
            ] if !field_validator.validated_fields.nil?

            image_vectors_indexed += 1

            if bulk.size >= 1000
              elastic.bulk bulk
              bulk = []
              printf "\rImage vectors indexed: #{image_vectors_indexed}" unless Rails.env.test?
            end
          rescue Exception => e
            logger.error "\n" + e.message
            logger.error " Image vectors update failed..."
            logger.error image_vector.inspect
          end
        end

        elastic.bulk bulk, query_parameters: {'refresh': true}
        printf "\rImage vectors indexed: #{image_vectors_indexed}" unless Rails.env.test?
      end
    }
    logger.info "\nFinished in #{benchmark} s."
    image_vectors_indexed
  end

  # Index all rating records available at Rating model.
  #
  # @param log [Boolean] Enable the log.
  def index_ratings(index_name = "_all", log = false)
    if index_name == "_all"
      ratings = Image.where("votes > ? ", 0)
    else
      ratings = Image.where("votes > ? AND source_id = ?", 0, Source.find_by_name(index_name))
    end

    ratings_indexed = 0
    ratings_count = ratings.count.to_s

    benchmark = Benchmark.realtime {
      logger.info "Ratings counted: " + ratings_count
      ratings.each do |rating|
        rating_index = Source.find(rating.source_id).name
        if @index.client.indices.exists? index: rating_index
          field_validator = Indexing::FieldValidator.new
          field_validator.validate('rating_average', rating.rating)
          field_validator.validate('rating_count', rating.votes)

          begin
            @index.client.update index: rating_index,
                                 id: rating.pid,
                                 body: { doc: field_validator.validated_fields },
                                 refresh: true

            ratings_indexed += 1
            printf "\rRatings indexed: #{ratings_indexed}" unless Rails.env.test?
          rescue Exception => e
            logger.error "\n" + e.message
            logger.error " Rating update failed..."
            logger.error rating.inspect
          end
        end
      end
    }
    logger.info "\nFinished in #{benchmark} s."
    logger.info "Ratings indexed: #{ratings_indexed}/#{ratings_count}"
    ratings_indexed
  end

  # Index all comment records available at Comment model.
  #
  # @param log [Boolean] Enable the log.
  def index_comments(index_name = "_all", log = false)
    # TODO Instead of getting all comments get all images with comments (of all or one index) and loop over them.
    # TODO Add test.
    if index_name == "_all"
      comments = Comment.all
    else
      comments = Comment.where("image_id LIKE ?", "%#{index_name}%")
    end

    comments_indexed = 0
    comments_count = comments.count.to_s

    benchmark = Benchmark.realtime {
      logger.info "Comments counted: " + comments_count

      comments.each do |comment|
        comment_index = comment.image_id.split("-").first
        comment_count = comment.image.comments.count
        user_comments = comment.image.comments.map{|comment| comment.text}.join("; ")

        if @index.client.indices.exists? index: comment_index
          field_validator = Indexing::FieldValidator.new
          field_validator.validate('comment_count', comment_count)
          field_validator.validate('user_comments', user_comments)

          begin
            @index.client.update index: comment_index,
                                 id: comment.image_id,
                                 body: { doc: field_validator.validated_fields },
                                 refresh: true

            comments_indexed += 1
            printf "\rComments indexed: #{comments_indexed}/#{comments_count}" unless Rails.env.test?
          rescue Exception => e
            logger.error "\n" + e.message
            logger.error " Comment update failed..."
            logger.error comment.inspect
          end
        end
      end
    }
    logger.info "\nFinished in #{benchmark} s."
    logger.info "Comments indexed: #{comments_indexed}/#{comments_count}"
    comments_indexed
  end

  # Count the records of the source's index.
  #
  # @return [Fixnum] The number of records.
  #
  # @example Count index records of a subclass:
  #   Artemis.new.count
  def count
    @index.count(name)
  end

  def encoding(file)
    Nokogiri::XML(IO.readlines(file)[0]).encoding
  end

  # Get a Nokogiri XML document from a XML file.
  #
  # @return [Nokogiri::XML::Document] The Nokogiri XML document.
  # @todo Notify user per email if anything goes wrong.
  def document(file = nil)
    if file
      file_name = Rails.configuration.x.dumps_path + name + "/" + file
    else
      file_name = Dir.glob("#{Rails.configuration.x.dumps_path}#{name}.{xml,json}").first
    end

    if File.extname(file_name) == '.xml'
      if File.exist?(file_name)
        @document = xml_document(file_name)
      else
        logger.info "!" * 100
        logger.info "#{file_name} does not exist."
        logger.info "!" * 100

        @document = Nokogiri::XML("")
      end
    else
      if File.exist?(file_name)
        @document = json_document(file_name)
      else
        logger.info "!" * 100
        logger.info "#{file_name} does not exist."
        logger.info "!" * 100

        @document = {}
      end
    end

    return @document
  end

  def xml_document(file_name)
    file = File.open(file_name)

    # Use Nokogiri XML Reader for large source data files.
    # http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Reader
    # @todo Add to config to separate the test source data file form the list.
    xml_reader_source_names = [
      "heidicon",
      "ffm_conedakor",
      "dresden",
      "test_source_xml_reader",
      "metropolitan",
      "smk",
      "paris_musees"
    ]

    if xml_reader_source_names.any? { |n| name.include?(n) }
      # http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Reader
      @document = Nokogiri::XML::Reader(File.open(file), nil, encoding(file))
    else
      # http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML
      @document = Nokogiri::XML(File.open(file)) do |config|
        # http://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/ParseOptions
        config.noblanks.huge
      end

      @document.remove_namespaces!
    end

    unless @document.encoding
      raise Pandora::Exception, "XML in '#{file_name}' does not declare an encoding"
    end

    @document
  end

  def json_document(file_name)
    json_file = File.read(file_name)

    Indexing::JsonSource.new(json_file)
  end

  def process_record_id(record_id)
    Indexing::FieldProcessor.new.process_record_id(record_id, name)
  end

  private

  def process_records(recs, new_index_name, log = false)
    @date_ranges_count = 0
    @date_ranges_parse_failed = []

    if @document.errors.size != 0
      # https://www.rubydoc.info/github/sparklemotion/nokogiri/Nokogiri/XML/Document#errors-instance_method
      logger.info "!" * 100
      @document.errors.map{ |error| logger.info error }
      logger.info "Please correct the syntax errors and try again..."
      logger.info "!" * 100

      return false
    elsif recs && recs.is_a?(Nokogiri::XML::NodeSet)
      records_counted = recs.count.to_s
      records_parser_info = ", using Nokogiri::XML for parsing."
    elsif recs && recs.is_a?(Indexing::XmlReaderNodeSet)
      records_counted = "unknown"
      records_parser_info = ", using Nokogiri::XML::Reader for parsing."
    elsif recs && recs.is_a?(Array)
      records_counted = recs.size.to_s
      records_parser_info = ", using JSON for parsing."
    else
      logger.info "!" * 100
      logger.info "Something is wrong with " + name + ", skipping..."
      logger.info "!" * 100
      return false
    end

    if records_counted == "0"
      logger.info "!" * 100
      logger.info "No records available for " + name + ", skipping..."
      logger.info "!" * 100
      return false
    end

    logger.info "Records counted: " + records_counted + records_parser_info

    recs.each do |record|
      # Assign the record to the record instance variable with the help of the record setter method.
      init(record)

      # If the record ID is nil, we do not index.
      if record_id.nil?
        @records_excluded += 1
        # If the records_to_exclude method exist and the record ID is included, we do not index.
      elsif self.respond_to?("records_to_exclude") && records_to_exclude.include?(record_id.to_s)
        @records_excluded += 1
      else
        processed_fields = Indexing::FieldProcessor.new(source: self, field_keys: Indexing::IndexFields.index).run
        validated_fields = Indexing::FieldValidator.new(processed_fields: processed_fields).run

        # Does the processed record ID already exist? If so, then update.
        if @index.client.exists? index: new_index_name, id: validated_fields['record_id']
          @records_updated += 1
        else
          @records_created += 1
        end

        # http://www.rubydoc.info/gems/elasticsearch-api/Elasticsearch/API/Actions#index-instance_method
        # Right now, if the ID already exists, the whole document is updated, see:
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/update-doc.html
        # @TODO: check if we also need partial updates, e.g.:
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/partial-updates.html
        @index.client.index index: new_index_name,
                            id: validated_fields['record_id'],
                            body: validated_fields,
                            refresh: false
        @records_indexed += 1
      end

      printf "\rRecords created: #{@records_created} | updated: #{@records_updated} (indexed in total: #{@records_indexed}) | excluded: #{@records_excluded}" unless Rails.env.test?
    end

    return true
  end
end
