class Pandora::Indexing::Indexer
  def self.index(source_names, generate_vectors: false)
    ActiveRecord::Base.logger.silence do
      parsers = instantiate_parsers!(source_names)

      parsers.each do |parser|
        indexer = new(parser, generate_vectors)
        indexer.index
      end

      "#{parsers.count} #{'source'.pluralize(parsers.count)} indexed."
    end
  end

  def self.instantiate_parsers!(source_names)
    source_names.map do |source_name|
      klass_name = if Source.institutional_source_names.include?(source_name)
        'Pandora::Indexing::Parser::InstitutionalDatabase'
      else
        prefix = ENV['PM_INDEXING_PARSER_CLASS_NAME_PREFIX']
        "#{prefix}#{source_name.camelize}"
      end

      begin
        klass = klass_name.constantize
        parser = if klass.legacy?
          klass
        else
          klass.new({name: source_name})
        end

        parser
      rescue NameError => e
        raise(
          Pandora::Exception,
          "no parser found for source '#{source_name}' (tried '#{klass_name}')"
        )
      end
    end
  end

  def initialize(parser, generate_vectors)
    @parser = parser
    @generate_vectors = generate_vectors
    @result = {
      started_at: Time.now.to_i,
      log: [],
      success: false
    }
  end

  def index
    vectors

    if @parser.legacy?
      @parser.index
      return
    end

    elastic.refresh
    log("#{@parser.source_name}: #{elastic.count(@parser.source_name)} records before indexing")
    @new_index = elastic.create_index(@parser.source_name)

    index_records

    elastic.add_alias_to(index_name: @new_index)
    # index_user_metadata
    elastic.cleanup_backups_of(alias_name: @parser.source_name)

    klapsch_check

    persist_result
    mail_result
  end

  def self.index_user_metadata(source_name)
    results = nil
    benchmark = Benchmark.realtime do
      results = UserMetadata.to_elastic(
        source_name,
        strict_original_checking: true
      )
    end

    Pandora.puts "User metadata count: #{results[:count]}"
    Pandora.puts "User metadata records indexed: #{results[:indexed]}"
    Pandora.puts "\nFinished in #{benchmark} s."
  end


  protected

    def vectors
      return if !@generate_vectors

      unless ENV['PM_INDEX_IMAGE_VECTORS'] == 'true'
        log(
          "#{@parser.source_name}: vectors are only generated on production"
        )
        return
      end

      Pandora::ImageVectors.for_sources(
        [@parser.source_name],
        ["similarity"]
      )
    end

    def index_records
      max = ENV['PM_MAX_RECORDS_PER_SOURCE'].presence
      @result[:max] = max

      max_reached = false
      total_object_count = 0
      total_record_count = 0
      total_indexed_record_count = 0
      total_updated_record_count = 0

      log("#{@parser.source_name}: indexing...")
      log("#{@parser.source_name}: indexed (i), updated (u), total (t)")

      indexed_record_count = 0

      @parser.preprocess
      object_count = @parser.object_count
      record_count = @parser.record_count
      total_record_count += record_count

      # Pandora.profile

      @parser.to_enum.each do |record|
        r = attacher.enrich(record)

        # There might be the case a record is assigned to multiple
        # objects and exists multiple times in the raw data. We could
        # update the record and assign multiple object ids to it,
        # which seems expensive, or we include the object id in the
        # record id. This will add multiple records, which might be no problem.
        # if elastic.record_id_exists?(r['record_id'])
        # else
        # end
        updated_record_count = elastic.bulk(
          [
            {
              index: {
                _id: r["record_id"],
                _index: @new_index
              }
            },
            r
          ]
        )

        indexed_record_count += 1
        indexed_record_count -= updated_record_count
        total_indexed_record_count += 1
        total_indexed_record_count -= updated_record_count
        total_updated_record_count += updated_record_count

        Pandora.printf("\e[K#{log_progress_line(@parser.source_name, total_indexed_record_count, total_updated_record_count, total_record_count, @parser.batch)}\r")

        if max && indexed_record_count >= max.to_i
          max_reached = true
          break
        end
      end

      # Pandora.profile

      updated_record_count = elastic.bulk_commit refresh: true

      total_object_count += object_count
      total_indexed_record_count -= updated_record_count
      total_updated_record_count += updated_record_count

      log(log_progress_line(@parser.source_name, total_indexed_record_count, total_updated_record_count, total_record_count, @parser.batch))

      if max && total_indexed_record_count >= max.to_i
        log(
          "#{@parser.source_name}: stopping at #{max} ", \
          "records (PM_MAX_RECORDS_PER_SOURCE)"
        )
      end
      log("#{@parser.source_name}: #{total_indexed_record_count} records after indexing")
      log("#{@parser.source_name}: attaching...")
      log("#{@parser.source_name}: #{attacher.ratings_count} #{'rating'.pluralize(attacher.ratings_count)}, #{attacher.comments_count} #{'comment'.pluralize(attacher.comments_count)}, #{attacher.user_metadata_count} user metadata, #{attacher.vectors_count} #{'vector'.pluralize(attacher.vectors_count)}")

      orphans = attacher.orphans
      log(
        "#{@parser.source_name}: found no record for: " +
        "#{orphans[:ratings].size} #{'rating'.pluralize(orphans[:ratings].size)}, " +
        "#{orphans[:comments].size} #{'comment'.pluralize(orphans[:comments].size)}, " +
        "#{orphans[:user_metadata].size} user metadata, " +
        "#{orphans[:vectors].size} #{'vector'.pluralize(orphans[:vectors].size)}"
      )

      @result[:objects] = total_object_count
      @result[:records] = total_record_count
      @result[:index_records] = total_indexed_record_count
      @result[:update_records] = total_updated_record_count
      @result[:attachments] = {
        counts: attacher.counts,
        orphans: orphans
      }

      Source.find_and_update_or_create_by(name: @parser.source_name,
                                          kind: @parser.source[:kind],
                                          type: @parser.source[:type],
                                          is_time_searchable: @parser.respond_to?(:date_range),
                                          object_count: total_object_count,
                                          record_count: total_indexed_record_count)
    end

    def index_user_metadata
      self.class.index_user_metadata(@parser.source_name)
    end

    def klapsch_check
      result = Indexing::Index.search([@parser.source_name], '*klapsch*', 'all', 0, 10000)
      record_ids = result["hits"]["hits"].map{|h| h["_id"]}
      log "#{@parser.source_name}: #{record_ids.size} klapsch"
    end

    def result_file
      ts = Time.at(@result[:started_at]).strftime('%Y%m%d_%H%M%S')
      file = "#{@parser.source_name}.#{ts}.json"
    end

    def results_dir
      ENV['PM_INDEX_RESULTS_DIR']
    end

    def persist_result
      @result[:success] = true
      @result[:finished_at] = Time.now.to_i

      path = "#{results_dir}/#{result_file}"

      system 'mkdir', '-p', results_dir
      File.write path, JSON.pretty_generate(@result)
    end

    def mail_result
      to = ENV['PM_INDEX_NOTIFY']
      return unless to.present?

      params = {
        to: to,
        name: @parser.source_name,
        file: "#{results_dir}/#{result_file}"
      }
      AccountMailer.with(params).indexing_finished.deliver_now
    end

    def attacher
      @attacher ||= Indexing::Attachments.new(@parser.source_name)
    end

    def elastic
      @elastic ||= Pandora::Elastic.new
    end

    def log(msg = nil)
      @result[:log] << msg
      Pandora.puts(msg)
    end

    def log_progress_line(source_name, total_indexed_record_count, total_updated_record_count, total_record_count, batch)
      "#{source_name}: #{total_indexed_record_count} (i), #{total_updated_record_count} (u), #{total_record_count} (t), #{batch}"
    end
end
