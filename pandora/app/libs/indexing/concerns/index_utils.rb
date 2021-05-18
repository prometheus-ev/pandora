# Concern including util class methods for accessing the index from the console.
module Indexing::Concerns::IndexUtils
  extend ActiveSupport::Concern

  # The class methods module.
  module ClassMethods
    # Get the Elasticsearch client.
    #
    # @param log [Boolean] Enable the log, true if Rails environment is development, false otherwise.
    #
    # @return [Elasticsearch::Transport::Client] The Elasticsearch client.
    def client(log = Rails.env.development?)
      index = Indexing::Index.new(log)
      index.client
    end

    # Get all index names as an array of strings.
    #
    # @param log [Boolean] Enable the log.
    #
    # @return [Array] An array of index name strings.
    def indices(log = false)
      index = Indexing::Index.new(log)
      index.indices
    end

    # Get an array of index alias names.
    #
    # @param log [Boolean] Enable the log.
    #
    # @return [Array] An array of index alias names.
    def aliases(log = false)
      index = Indexing::Index.new(log)
      index.aliases
    end

    # Check if the index already exists.
    #
    # @param index_name [String] The name of the index/alias to check.
    def exists?(index_name, log = false)
      index = Indexing::Index.new(log)
      index.client.indices.exists? index: index_name
    end

    # Create an index with settings and mappings.
    #
    # @param index_name [String] The name of the index to create.
    # @param log [Boolean] Enable the log.
    def create(index_name, log = false)
      index = Indexing::Index.new(log)
      index.create(index_name)
    end

    # Delete an index with settings and mappings and clear the cache.
    #
    # @param index_name [String] The name of the index to create.
    # @param log [Boolean] Enable the log.
    def delete(index_name, log = false)
      index = Indexing::Index.new(log)
      index.delete(index_name)
    end

    # Rollback an alias to the previous version of an index.
    #
    # @param alias_name [String] The alias name.
    # @param log [Boolean] Enable the log.
    def rollback(alias_name, log = false)
      index = Indexing::Index.new(log)
      if index.client.indices.exists?(index: alias_name)

        current_index_name = index.index_name_from_alias_name(alias_name)
        # previous_index_name = alias_name + "_" + (current_index_version - 1).to_s

        # @todo sort_by_date ???
        indices = index.client.indices.get(index: "#{alias_name}*" ).keys.sort

        if indices.length > 1
           # ES API 5.0
           # index.client.indices.rollover alias: alias_name, new_index: indices[0].to_s

           # ES API 2.0
           index.client.indices.put_alias index: indices[0].to_s, name: alias_name
           index.client.indices.delete_alias index: current_index_name, name: alias_name
           index.delete(indices[-1])
         else
           puts "Only a single version of index #{alias_name} available, cannot rollback..."
         end
      end
    end

    # Count the numer of records of a specified index or of all indices.
    #
    # @param index_name [String] The index name to count.
    # @param log [Boolean] Enable the log.
    #
    # @return [Fixnum] The number of records of the queried index.
    def count(index_name = "_all", log = false)
      index = Indexing::Index.new(log)
      index.count(index_name)
    end

    # Prints general information about each index.
    #
    # @param log [Boolean] Enable the log.
    def info(log = false)
      index = Indexing::Index.new(log)
      max_index_name = index.indices.max_by{ |x| x.length }
      index.indices.each do |idx|
        aliases = index.client.indices.get_alias(index: idx)[idx]['aliases'].keys[0]
        index_settings = index.client.indices.get_settings(index: idx)
        time_in_milliseconds = index_settings[idx]['settings']['index']['creation_date']
        time_in_seconds = time_in_milliseconds.to_i / 1000
        creation_date = DateTime.strptime(time_in_seconds.to_s, '%s')
        date = creation_date.strftime('%Y-%m-%d %I:%M%p')
        records =  index.client.count(index: idx)['count']
        printf "Indexing::Index: "
        printf "%#{max_index_name.length}s", idx
        printf ", Documents: "
        printf "%10i", records
        printf ", Created on: "
        printf "%10s", date
        printf ", Aliases: "
        printf "%5s", aliases
        printf "\n"
      end
    end

    # Search an index with a certain name.
    #
    # @param idx [String||Array of Strings] The index name(s) to search.
    # @param query [String] The search query, see: https://www.elastic.co/guide/en/elasticsearch/reference/2.4/query-dsl-query-string-query.html
    # @param field [String] The search field, one of the Rails.configuration.x.athene_search_fields['mappings'] fields.
    # @param from [Number] Starting offset
    # @param size [Number] Number of hits to return
    # @param log [Boolean] Enable the log.
    #
    # @return [Hash] The result hash of the search.
    # https://www.rubydoc.info/gems/elasticsearch-api/Elasticsearch/API/Actions#search-instance_method
    def search(idx, query = '*', field = 'all', from = 0, size = 10, log = false, pretty: false)
      index = Indexing::Index.new(log)
      fields = Indexing::IndexFields.search_mapping(field: field)

      query_string = {
        query: query,
        default_operator: "AND",
        allow_leading_wildcard: true,
        analyze_wildcard: true,
        fields: fields
      }

      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#operator-min
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#type-cross-fields
      if field == 'all'
        query_string.merge!({ type: "cross_fields" })
      end

      result = index.client.search index: idx, body: {
        explain: true,
        query: {
          bool: {
            must: {
              query_string: query_string
            }
          }
        },
        docvalue_fields: ["title.raw", "artist_normalized.raw"],
        from: from,
        size: size
      }

      if pretty
        puts JSON.pretty_generate(result)
      else
        result
      end
    end

    # https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-termvectors.html
    # https://www.rubydoc.info/gems/elasticsearch-api/Elasticsearch/API/Actions#termvectors-instance_method
    def termvectors(idx, id, log = false)
      index = Indexing::Index.new(log)
      index.client.termvectors index: idx, id: id
    end

    # Index the rating of an image.
    #
    # @param pid [String] The pid of the image.
    # @param average [Number] The average rating.
    # @param count [Number] The number of ratings for the image.
    def rate(pid, average, count, log = false)
      index = Indexing::Index.new(log)
      doc = {}
      doc.merge!({ rating_average: average })
      doc.merge!({ rating_count: count })

      index.client.update index: pid.split("-").first,
                          id: pid,
                          body: { doc: doc },
                          refresh: true
    end

    # Index the comments of an image.
    #
    # @param pid [String] The pid of the image.
    # @param average [Number] The average rating.
    # @param count [Number] The number of ratings for the image.
    def comment(pid, text, count, log = false)
      index = Indexing::Index.new(log)
      doc = {}
      doc.merge!({ user_comments: text })
      doc.merge!({ comment_count: count })

      index.client.update index: pid.split("-").first,
                           id: pid,
                           body: { doc: doc },
                           refresh: true
    end

    # Convenience method for processing indices.
    #
    # @param indices [Array] The array of indices to process.
    def process_indices(indices, log = false)
      index = Indexing::Index.new(log)
      index.process_indices(indices)
    end

    def number_of(log = false)
      index = Indexing::Index.new(log)
      index.number_of
    end
  end
end
