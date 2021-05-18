class Pandora::Elastic

  def version
    data = request
    require_ok!
    if data['version'] && data['version']['number'] && data['version']['lucene_version']
      "Elasticsearch #{data['version']['number']} (based on Lucene #{data['version']['lucene_version']})"
    else
      "Elasticsearch (based on Lucene)"
    end
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html
  def search(indices, query = {})
    query.merge!(track_total_hits: true)
    data = request 'POST', "/#{indices.join(',')}/_search", {}, {}, query
    require_ok!
    data
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-multi-search.html
  def msearch(msearches)
    body = msearches.map{|m| JSON.dump(m)}.join("\n")
    data = request 'GET', '/_msearch', {}, {}, body + "\n"
    require_ok!
    data
  end

  def date_aggregations(indices)
    query = {
      aggs: {
        date_count: {
          value_count: { "field": "date.raw" }
        },
        date_range_from_stats: {
          stats: {
            field: "date_range_from"
          }
        },
        date_range_to_stats: {
          stats: {
            field: "date_range_to"
          }
        }
      },
      size: 0
    }

    search(indices, query)
  end

  def counts
    # construct a mapping from index name to alias name
    raw_aliases = request 'GET', "/_alias/_all"
    if raw_aliases.empty? || (raw_aliases["error"] == "alias [] missing" && raw_aliases["status"] == 404)
      result = {'total' => {'value' => 0}}
    else
      require_ok!
      alias_map = Hash[raw_aliases.map{|k, v| [k, v['aliases'].keys.first]}]

      # fetch the actual counts
      data = request 'POST', "/#{aliases.join(',')}/_search", {}, {}, {
        aggs: {
          count_by_type: {
            terms: {
              field: '_index',
              size: aliases.size
            }
          }
        },
        track_total_hits: true,
        size: 0
      }
      require_ok!

      # use the mapping to retrieve the alias names for each index counted
      result = {'total' => data['hits']['total']}
      data['aggregations']['count_by_type']['buckets'].each do |bucket|
        i = alias_map[bucket['key']]
        result[i] = bucket['doc_count'] if i
      end
    end

    result
  end

  def image_ids(source, options = {})
    options.reverse_merge!(
      page: 1,
      per_page: 10
    )

    data = request 'GET', "/#{source}/_search", {
      _source: false,
      size: options[:per_page]
      # TODO: why has skip been used?
      #skip: skip(options[:page], options[:per_page])
    }

    data['hits']['hits'].map do |h|
      h['_id']
    end
  end

  def record(id)
    response = records([id])['docs'].first
    response['found'] ? response : response.merge(
      '_source' => {
        'path' => 'not-available'
      }
    )
  end

  def records(ids, options = {})
    rdata = {
      'docs': ids.map{|id|
        index, hash = id.split('-')
        {
          '_index': index,
          '_id': id
        }
      }
    }
    request 'GET', "/_mget", { '_source': 'true' }, {}, rdata
  end

  def by_object_ids(ids, options = {})
    data = request 'POST', "/#{aliases.join(',')}/_search", {}, {}, {
      'query' => {
        'bool' => {
          'filter' => [
            {'terms' => {'record_object_id.raw' => ids}}
          ]
        }
      }
    }
    require_ok!
    data
  end

  def more_like_this(id)
    source = id.split("-")[0]

    data = request 'POST', "/#{aliases.join(',')}/_search", {}, {}, {
      'query' => {
        'more_like_this' => {
          'like' => [{'_index' => source, '_id' => id}],
          'fields' => [
            'title',
            'title_variants',
            'keyword',
            'keyword_artigo',
            'description',
            'material',
            'technique',
            'epoch'
          ],
          'min_term_freq' => 1,
          'max_query_terms' => 5,
          'min_word_length' => 4
        }
      }
    }
    require_ok!
    data
  end

  def bulk(instructions)
    return true if instructions.empty?

    data = instructions.map{|i| JSON.dump(i)}.join("\n")
    data << "\n"
    request 'POST', '/_bulk', {}, {}, data
    require_ok!
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-update.html
  def update(source, id, data)
    request 'POST', "/#{source}/_update/#{id}", {}, {}, {
      'doc' => data
    }
  end

  def index_exists?(name)
    !!indices.find{|i| i['index'] == name}
  end

  def create_index(alias_name, settings = Indexing::IndexSettings.read, mappings = Indexing::IndexMappings.read)
    if aliases.include?(alias_name)
      index_name = index_name_from(alias_name: alias_name)
    end

    if index_name
      index_count = index_name.split("_")[-1].to_i + 1
    else
      index_count = 1
    end

    new_index_name = "#{alias_name}_#{index_count}"

    # Add a wildcard to not return an error if index does not exist yet.
    destroy_index("#{new_index_name}*")

    data = request 'PUT', "/#{new_index_name}", {}, {}, {
      'settings' => settings,
      'mappings' => mappings
    }
    require_ok!
    data['index']
  end

  def create_index_record(index, id, body)
    data = request 'PUT', "/#{index}/_doc/#{id}", {}, {}, body
    require_ok!
    data
  end

  def destroy_index(index_name)
    result = request 'DELETE', "/#{index_name}"
    require_ok!
    result
  end

  def destroy_record(record_id)
    alias_name = record_id.split('-').first
    result = request 'DELETE', "/#{alias_name}/_doc/#{record_id}"
    require_ok!
    result
  end

  def create_alias(index_name, alias_name)
    request 'PUT', "/#{index_name}/_aliases/#{alias_name}"
    require_ok!
  end

  def add_alias_to(index_name:)
    alias_name = alias_name_from(index_name: index_name)

    actions = []
    if aliases.include?(alias_name)
      actions << {
        remove: {
          index: index_name_from(alias_name: alias_name), alias: alias_name
        }
      }
    end

    actions << {
        add: {
          index: index_name, alias: alias_name
        }
      }

    data = request 'POST', "/_aliases", {}, {}, {
      actions: actions
    }
    require_ok!
    data
  end

  def remove_alias(index_name, alias_name)
    request 'DELETE', "/#{index_name}/_aliases/#{alias_name}"
    require_ok!
  end

  def ensure_alias(name, a)
    (indices_for(a) - [name]).each do |i|
      remove_alias(i, a)
    end
    create_alias(name, a)
  end

  def mappings(name)
    data = request 'GET', "/#{name}/_mapping"
    require_ok!
    data
  end

  def settings(name)
    data = request 'GET', "/#{name}/_settings"
    require_ok!
    data
  end

  def aliases
    data = request 'GET', "/_alias/_all"
    require_ok!
    data.values.map{|v| v['aliases'].keys.first}
  end

  def index_name_from(alias_name:)
    data = request 'GET', "/*/_alias/#{alias_name}"
    if data['status'] == 404
      ''
    else
      require_ok!
      data.keys[0]
    end
  end

  def alias_name_from(index_name:)
    index_name.rpartition('_').first
  end

  def index_version_of(alias_name:)
    index_name = index_name_from(alias_name: alias_name)
    version_of(index_name: index_name)
  end

  def version_of(index_name:)
    index_name.rpartition('_').last.to_i
  end

  def index_has_alias?(index_name: '*', alias_name:)
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-alias-exists.html
    status_code = request 'HEAD', "/#{index_name}/_alias/#{alias_name}"
    if status_code == 200
      true
    else
      false
    end
  end

  def indices_for(a)
    data = request 'GET', "/*/_alias/#{a}"
    require_ok!
    data.keys
  end

  def indices
    data = request 'GET', "/_cat/indices"
    require_ok!
    data
  end

  # index_names: comma-separated list or wildcard expression of index names used to limit the request.
  def cleanup_backups_of(alias_name:, keep: 2, dry: false)
    deleted_backups = []

    # https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-get-index.html
    data = request 'GET', "/#{alias_name}*"
    require_ok!

    unless data.keys.empty?
      data.keys.each do |index_name|
        if !index_has_alias?(index_name: index_name, alias_name: alias_name) &&
           version_of(index_name: index_name) <= (index_version_of(alias_name: alias_name) - keep)
          deleted_backups << index_name

          unless dry
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-delete-index.html
            status_code = request 'DELETE', "/#{index_name}"
            require_ok!
          end
        end
      end

      if dry
        puts
        puts "Set parameter 'dry' to true in order to not delete any indices, e.g.:"
        puts
        puts "  cleanup_backups_of('robertin', true)"
        puts
      end
    end

    deleted_backups
  end

  def close
    request 'POST', '/_all/_close'
    require_ok!
  end

  def scan(name, per_page = 1000)
    data = request 'GET', "/#{name}/_search", {
      scroll: '1m',
      size: per_page
    }
    require_ok!
    data
  end

  def continue(scroll_id)
    data = request 'GET', '/_search/scroll', {scroll: '1m'}, {}, {
      'scroll_id' => scroll_id
    }
    require_ok!
    data
  end

  def refresh
    request 'POST', '/_refresh'
  end

  def skip(page = 1, per_page = 10)
    (page - 1) * per_page
  end

  def require_ok!
    if @response && (@response.status < 200 || @response.status > 299)
      raise Pandora::Exception, "elastic request failed: #{@response.body}"
    end
  end

  def index_uploads(source)
    index_name = create_index(source.name)
    alias_name = alias_name_from(index_name: index_name)
    tmp_file = Tempfile.new('image_list_')

    source.uploads.each do |upload|
      upload = upload.attributes
      record_id = [alias_name, Digest::SHA1.hexdigest(upload['image_id'])].join('-')
      path = "#{upload['image_id']}.#{upload['filename_extension']}"

      upload.merge!('record_id' => record_id)
      upload.merge!('path' => path)

      create_index_record(index_name, record_id, upload.to_json)

      tmp_file.write("#{path}\n")
    end

    tmp_file.close

    add_alias_to(index_name: index_name)
    cleanup_backups_of(alias_name: alias_name)

    cmd = "mkdir -p #{ENV['PM_IMAGES_DIR']}/#{alias_name}/original/"
    system(cmd)

    cmd = "rsync -avu --delete --files-from=#{tmp_file.path} #{ENV['PM_IMAGES_DIR']}/upload/original/ #{ENV['PM_IMAGES_DIR']}/#{alias_name}/original/"
    system(cmd)

    # TODO is_time_searchable could be set to true if we force a date for uploads.
    Source.find_and_update_or_create_by(name: source.name,
                                        kind: source.kind,
                                        type: source.type,
                                        is_time_searchable: false,
                                        record_count: source.uploads.size)
  end

  def info(time: false)
    info = []

    info << '|_.alias_name|_.index_name|_.total records|_.date records|_.parsed date records|_.unparsed date records|_.parsed date record percentage|'

    aliases.sort.each do |a|
      source = Source.find_by_name(a)
      index_name = index_name_from(alias_name: a)

      if source
        date_record_count = date_aggregations([source.name])['aggregations']['date_count']['value']

        if source.is_time_searchable?
          parsed_date_record_count = date_aggregations([source.name])['aggregations']['date_range_from_stats']['count']
          unparsed_date_record_count = date_record_count - date_aggregations([source.name])['aggregations']['date_range_from_stats']['count']
          parsed_date_record_percentage = parsed_date_record_count.to_d / (date_record_count.nonzero? || 1).to_d * 100.0
        else
          next if time
        end

        row = "|#{source.name}|" +
          "#{index_name}|" +
          ">.#{ActiveSupport::NumberHelper::number_to_delimited(source.record_count)}|" +
          ">.#{ActiveSupport::NumberHelper::number_to_delimited(date_record_count)}|" +
          ">.#{ActiveSupport::NumberHelper::number_to_delimited(parsed_date_record_count) || '-'}|" +
          ">.#{ActiveSupport::NumberHelper::number_to_delimited(unparsed_date_record_count) || '-'}|"

        if parsed_date_record_percentage < 95.0
          row += ">.*#{ActiveSupport::NumberHelper::number_to_rounded(parsed_date_record_percentage, precision: 2) || '-'}*|"
        else
          row += ">.#{ActiveSupport::NumberHelper::number_to_rounded(parsed_date_record_percentage, precision: 2) || '-'}|"
        end

        info << row
      end
    end

    puts 'Redmine Textile table markup language:'
    puts info
  end

  def analyze(alias_name, analyzer, text)
    data = request 'GET', "/#{alias_name}/_analyze", {}, {}, {
      analyzer: analyzer,
      text: text
    }

    require_ok!
    data
  end

  protected

    def request(method = 'GET', path = '/', params = {}, headers = {}, body = nil)
      headers.reverse_merge!(
        'content-type' => 'application/json',
        'accept' => 'application/json'
      )

      if body && !body.is_a?(String)
        body = body.to_json
      end

      @response = client.request(
        method, "#{ENV['PM_ELASTIC_URI']}#{path}",
        params, body ? body : '', headers
      )

      if method == 'HEAD'
        @response.status_code
      else
        JSON.parse(@response.body)
      end
    end

    def client
      @client ||= HTTPClient.new
    end
end
