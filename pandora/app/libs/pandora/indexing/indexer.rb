class Pandora::Indexing::Indexer
  def self.index(source_names = ['bonn_maya', 'json_test_source', 'oldenburg_afrika', 'cma'])
    ActiveRecord::Base.logger.level = 1

    parsers = instantiate_parsers!(source_names)

    parsers.each do |parser|
      instance = new(parser)
      instance.index
    end

    ActiveRecord::Base.logger.level = 0
  end

  def self.index_glob_pattern(glob_pattern = '*')
    source_files = Dir.glob("app/libs/indexing/sources/" + glob_pattern + ".rb")
    source_names = source_files.map { |source_file|
      File.basename(source_file, ".rb")
    }.sort
    self.index(source_names)
  end

  def self.instantiate_parsers!(source_names)
    parsers = []

    source_names.each do |source_name|
      klass_name = if Source.institutional_source_names.include?(source_name)
        'Pandora::Indexing::Parser::InstitutionalDatabase'
      else
        "#{ENV['PM_PANDORA_INDEXING_PARSER_CLASS_NAME_PREFIX']}#{source_name.camelize}"
      end

      begin
        parsers << klass_name.constantize.new({name: source_name})
      rescue NameError => e
        raise(
          Pandora::Exception,
          "no parser found for source '#{source_name}' (tried '#{klass_name}')"
        )
      end
    end

    parsers
  end

  def initialize(parser)
    @parser = parser
    @source_name = parser.source[:name]
  end

  def index
    elastic.refresh
    @new_index = elastic.create_index(@source_name)

    index_records

    elastic.add_alias_to(index_name: @new_index)
    # index_user_metadata
    elastic.cleanup_backups_of(alias_name: @source_name)

    klapsch_check
  end

  def self.index_user_metadata(source_name)
    results = nil
    benchmark = Benchmark.realtime do
      results = UserMetadata.to_elastic(
        source_name,
        strict_original_checking: true
      )
    end

    logger.info "User metadata count: #{results[:count]}"
    logger.info "User metadata records indexed: #{results[:indexed]}"
    logger.info "\nFinished in #{benchmark} s."
  end

  def self.logger
    @logger ||= Rails.logger
  end


  protected

    def index_records
      total_object_count = 0
      total_indexed_record_count = 0
      total_updated_record_count = 0

      @parser.filenames.each do |filename|
        puts "#{@source_name}: #{filename}"

        indexed_record_count = 0

        @parser.filename = filename
        @parser.preprocess
        object_count = @parser.object_count
        record_count = @parser.record_count

        @parser.to_enum.each do |record|
          r = attacher.enrich(record)

          # There might be the case a record is assigned to multiple objects and exists multiple
          # times in the raw data. We could update the record and assign multiple object ids to it,
          # which seems expensive, or we include the object id in the record id. This will add
          # multiple records, which might be no problem.
          #if elastic.record_id_exists?(r['record_id'])
          #else
            total_updated_record_count += elastic.bulk([{'index' => {'_id' => r['record_id'], '_index' => @new_index}}, r])
          #end

          indexed_record_count += 1
          total_indexed_record_count += 1

          printf "#{@source_name}: #{indexed_record_count}/#{record_count} records indexed (#{total_updated_record_count} records updated in total)".ljust(60) + "\r"
        end

        total_object_count += object_count

        puts
      end

      total_updated_record_count += elastic.bulk_commit refresh: true
      total_indexed_record_count -= total_updated_record_count
      Source.find_and_update_or_create_by(name: @source_name,
                                          kind: @parser.source[:kind],
                                          type: @parser.source[:type],
                                          is_time_searchable: @parser.respond_to?(:date_range),
                                          object_count: total_object_count,
                                          record_count: total_indexed_record_count)

      if @parser.filenames.size > 1
        puts "#{@source_name}: total"

        if total_object_count > 0
          puts "#{@source_name}: #{total_object_count} objects with #{total_indexed_record_count} records indexed (#{total_updated_record_count} records updated in total)"
        else
          puts "#{@source_name}: #{total_indexed_record_count} records indexed (#{total_updated_record_count} records updated in total)"
        end
      end

      puts
    end

    def index_user_metadata
      self.class.index_user_metadata(@source_name)
    end

    def klapsch_check
      result = Indexing::Index.search([@source_name], '*klapsch*', 'all', 0, 10000)
      record_ids = result["hits"]["hits"].map{ |h| h["_id"] }
      puts "klapsch: #{record_ids.size}"
    end

    def attacher
      @attacher ||= Indexing::Attachments.new(@source_name)
    end

    def elastic
      @elastic ||= Pandora::Elastic.new
    end

    def logger
      self.class.logger
    end

end
