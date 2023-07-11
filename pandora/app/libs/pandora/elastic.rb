class Pandora::Elastic
  include Pandora::ElasticInfo

  def image_vector_query(record_id:, query: '*', distance: 'euc', page_size: 5, page_from: 0, sort_field: 'relevance', sort_order: 'desc')
    image_vector = record(record_id)['_source']['image_vector']

    if sort_field == "relevance"
      sort = [{
        '_score' => {
          order: sort_order
        }
      }]
    else
      sort = [{
        "#{sort_field}.raw" => {
          order: sort_order
        }
      }]
    end

    if distance == 'euc'
      #euclidean
      score_fn = "doc['image_vector'].size() == 0 ? 0 : 1 / (l2norm(params.vector,'image_vector') + 1.0)"
    elsif distance == 'cos'
      #cosine
      score_fn = "doc['image_vector'].size() == 0 ? 0 : cosineSimilarity(params.vector, 'image_vector') + 1.0"
    elsif distance == 'man'
      #manhattan
      score_fn = "doc['image_vector'].size() == 0 ? 0 : 1 / (l1norm(params.vector,'image_vector') + 1.0)"
    end

    data = request 'POST', "/#{aliases.join(',')}/_search", {}, {}, {
      min_score: 0.69,
      size: page_size,
      from: page_from,
      sort: sort,
      "query": {
        "script_score": {
          "query": {
            "query_string": {
                "query": query
            }
          },
          "script": {
            "source": score_fn,
            "params": {
              "vector": image_vector
            }
          }
        }
      }
    }

    require_ok!
    data
  end

  def sample(indices, size = 20)
    query = {
      size: size,
      query: {
        function_score: {
          random_score: {}
        }
      }
    }

    data = request 'POST', "/#{indices.join(',')}/_search", {}, {}, query
    require_ok!
    data
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-search.html
  def search(indices, query = {}, from = 0, size = 10)
    query.merge!(from: from) unless query.has_key?(:from)
    query.merge!(size: size) unless query.has_key?(:size)
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

  def each_batch(name, batch_size: 500, &block)
    result = scan(name, 25000)
    scroll_id = result['_scroll_id']
    total = result['hits']['total']['value']
    count = 0

    while count < total
      batch = result['hits']['hits']

      yield batch

      count += result['hits']['hits'].size
      result = continue(scroll_id)
      scroll_id = result['_scroll_id']
    end
  end

  def each_doc(name, batch_size: 500, &block)
    each_batch name, batch_size: batch_size do |batch|
      batch.each do |doc|
        yield doc
      end
    end
  end

  def total(name)
    data = request 'GET', "/#{name}/_count"
    require_ok!
    data['count']
  end

  # https://www.elastic.co/guide/en/elasticsearch/reference/current/paginate-search-results.html#search-after
  def pit
    data = request 'POST', "/#{aliases.join(',')}/_pit", {keep_alive: '1m'}
    require_ok!
    @pit = data['id']
  end

  def pit_search_after(query:)
    body = {
      size: 1000,
      pit: {
        id: @pit,
        keep_alive: '1m'
      },
      sort: [{
        "_shard_doc": "desc"
      }]
    }

    body.merge!(query: query)

    unless @search_after.blank?
      body.merge!(search_after: @search_after)
    end

    data = request 'GET', "/_search", {}, {}, body
    require_ok!

    if data['hits']['hits'].size > 0
      @search_after = data['hits']['hits'].last['sort']
    end

    data
  end

  def pit_delete
    data = request 'DELETE', "/_pit", {}, {}, {
      id: @pit
    }
    require_ok!
    data
  end

  def date_aggregations(indices)
    query = {
      size: 0,
      aggs: date_aggregation
    }

    search(indices, query)
  end

  def date_aggregation
    {
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
    }
  end

  def object_record_count_aggregation
    {
      count_by_index_and_is_main_record: {
        multi_terms: {
          terms: [{
            field: '_index'
          }, {
            field: 'is_main_record.raw',
            missing: 'true'
          }],
          size: aliases.size * 2
        },
        aggs: object_count_aggregation
      }
    }
  end

  def indices_with_objects_aggregation
    {
      indices_with_objects: {
        filters: {
          filters: {
            exists_record_object_id: {
              exists: {
                field: 'record_object_id'
              }
            },
            range_record_object_id_count: {
              range: {
                record_object_id_count: {
                  gte: 2
                }
              }
            }
          }
        },
        aggs: {
          indices: {
            terms: {
              field: '_index',
              size: aliases.size
            }
          }
        }
      }
    }
  end

  def object_count_aggregation
    {
      object_count: {
        cardinality: {
          field: 'record_object_id.raw'
        }
      }
    }
  end

  def record_object_id_aggregations(sort)
    query = {
      size: 0,
      aggs: {
        record_object_id: {
          terms: {
            field: "record_object_id.raw",
            min_doc_count: 2,
            size: 100000
          }
        },
        aggs: {
          docs: {
            top_hits: {
              size: 100000,
              sort: sort
            }
          }
        }
      }
    }
  end

  def is_main_record_filter
    {
      bool: {
        must_not: [
          term: {
            is_main_record: 'false'
          }
        ]
      }
    }
  end

  def record_object_id_count_filter
    {
      range: {
        'record_object_id_count.short': {
          gte: 2
        }
      }
    }
  end

  def indices_with_objects
    indices = []
    aggs = {}

    aggs.merge!(indices_with_objects_aggregation)

    data = request 'POST', "/#{aliases.join(',')}/_search", {}, {}, {
      aggs: aggs,
      track_total_hits: true,
      size: 0
    }
    require_ok!

    buckets = data.dig('aggregations', 'indices_with_objects', 'buckets', 'range_record_object_id_count', 'indices', 'buckets')

    if buckets
      indices = buckets.map do |bucket|
        name = alias_name_from(index_name: bucket['key'])
        title = Source.find_by(name: name).title
        {name: name, title: title}
      end
    end

    indices.sort_by{|index| index[:name]}
  end

  def counts
    # construct a mapping from index name to alias name
    raw_aliases = request 'GET', "/_alias/_all"
    if raw_aliases.empty? || (raw_aliases["error"] == "alias [] missing" && raw_aliases["status"] == 404)
      result = {'total' => {'records' => 0, 'objects' => 0}}
    else
      require_ok!
      alias_map = Hash[raw_aliases.map{|k, v| [k, v['aliases'].keys.first]}]

      aggs = {}
      aggs.merge!(object_count_aggregation)
      aggs.merge!(object_record_count_aggregation)

      # fetch the actual counts
      data = request 'POST', "/#{aliases.join(',')}/_search", {}, {}, {
        aggs: aggs,
        track_total_hits: true,
        size: 0
      }
      require_ok!

      # use the mapping to retrieve the alias names for each index counted
      result = {}
      total_objects = data['aggregations']['object_count']['value']
      total_records = 0
      data['aggregations']['count_by_index_and_is_main_record']['buckets'].each do |bucket|
        i = alias_map[bucket['key'][0]]

        if i
          unless result[i]
            result[i] = {}
            result[i]['objects'] = 0
            result[i]['records'] = 0
          end

          if bucket['key'][1] == 'true'
            doc_count = bucket['doc_count']
            object_count = bucket['object_count']['value']

            result[i]['objects'] += object_count
            result[i]['records'] += doc_count
            total_records += doc_count
          else
            doc_count = bucket['doc_count']
            result[i]['records'] += doc_count
            total_records += doc_count
          end

          if result[i]['objects'] == 0
            result[i]['objects'] = result[i]['records']
          end
        end
      end
      result['total'] = {'objects' => total_objects, 'records' => total_records}
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

  def by_object_ids(ids, size = nil, options = {})
    body = {
      query: {
        bool: {
          filter: [
            { terms: { 'record_object_id.raw': ids }}
          ]
        }
      }
    }
    body.merge!(size: size) if size

    data = request 'POST', "/#{aliases.join(',')}/_search", {}, {}, body
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

  def bulk(operations, batch_size: 500)
    operations = [operations] unless operations.is_a?(Array)

    @bulk_backlog ||= []
    @bulk_backlog += operations

    if @bulk_backlog.size >= batch_size
      bulk_commit
    else
      0
    end
  end

  def bulk_commit(refresh: false)
    return if @bulk_backlog.nil? || @bulk_backlog.empty?

    body = @bulk_backlog.map{|d| d.to_json}.join("\n")
    @bulk_backlog = []

    params = (refresh ? {refresh: true} : nil)
    response = request "POST", "/_bulk", params, {}, "#{body}\n"
    updated_records = response['items'].select do |item|
      item.dig('index', 'result') == 'updated'
    end
    require_ok!
    updated_records.count
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

  # https://www.elastic.co/guide/en/elasticsearch/reference/8.6/docs-get.html#docs-get-api-example
  def record_id_exists?(record_id)
    alias_name = record_id.split("-")[0]

    status_code = request 'HEAD', "/#{alias_name}/_doc/#{record_id}"

    if status_code == 200
      true
    else
      false
    end
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

    # Drop any old indices for this alias name
    # Add a wildcard to not return an error if index does not exist yet.
    destroy_index("#{new_index_name}*")

    # create the new index
    data = request 'PUT', "/#{new_index_name}", {}, {}, {
      'settings' => settings,
      'mappings' => mappings
    }
    require_ok!
    data['index']
  end

  def ensure_index(alias_name, settings = Indexing::IndexSettings.read, mappings = Indexing::IndexMappings.read)
    return alias_name if aliases.include?(alias_name)
    
    destroy_index("#{alias_name}*")
    data = request 'PUT', "/#{alias_name}_1", {}, {}, {
      'settings' => settings,
      'mappings' => mappings
    }
    require_ok!

    create_alias("#{alias_name}_1", alias_name)

    alias_name
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

  def destroy_all
    result = request 'DELETE', '/_all'
    require_ok!
    result
  end

  def destroy_alias(alias_name)
    destroy_index "#{alias_name}*"
  end

  def destroy_record(record_id, raise_errors: true)
    alias_name = record_id.split('-').first
    result = request 'DELETE', "/#{alias_name}/_doc/#{record_id}"
    require_ok! if raise_errors
    result
  end

  def create_alias(index_name, alias_name)
    request 'PUT', "/#{index_name}/_aliases/#{alias_name}"
    require_ok!
  end

  def destroy_alias(name)
    request 'DELETE', "/_all/_alias/#{name}"
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

  def index_upload(super_image)
    alias_name = super_image.index_name
    ensure_index(alias_name)
    attrs = index_attributes(super_image)

    # comments
    attrs.merge!(
      'comment_count' => super_image.upload.image.comments.not_deleted.count,
      'user_comments' => super_image.upload.image.comments.not_deleted.pluck(:text).join('; ')
    )

    # ratings
    attrs.merge!(
      'rating_average' => super_image.image.score,
      'rating_count' => super_image.image.votes
    )

    klapsch = Indexing::Klapsch.new(attrs)
    if klapsch.match?
      remove_upload(super_image, raise_errors: false)
      AccountMailer.with(super_image: super_image).klapsch_match.deliver_now
      return
    end

    # skipping image vectors for now since we don't have them for uploads and 
    # we'd need a way to generate them one by one

    create_index_record(alias_name, attrs['record_id'], attrs)

    # we are copying the file form the upload image directory to the source
    # database image so that image retrieval works for both pids
    if alias_name != 'uploads' # -> institutional
      from = "#{ENV['PM_IMAGES_DIR']}/upload/original/#{attrs['path']}"
      target = "#{ENV['PM_IMAGES_DIR']}/#{alias_name}/original"
      to = "#{target}/#{attrs['path']}"
      system 'mkdir', '-p', target
      system 'cp', '-f', from, to
    end

    if super_image.upload? && !super_image.institutional?
      prometheus = Institution.find_by!(name: 'prometheus')
      source = Source.
        create_with(
          name: 'uploads',
          title: 'User uploads',
          kind: 'User upload',
          type: 'user_upload',
          is_time_searchable: false,
          institution: prometheus,
          keywords: [Keyword.find_or_create_by!(title: 'upload')]
        ).
        find_or_initialize_by name: 'uploads'

      source.record_count = counts['uploads']
      source.save!
    else
      source = super_image.source
      Source.find_and_update_or_create_by(
        name: source.name,
        kind: source.kind,
        type: source.type,
        is_time_searchable: false,
        record_count: source.uploads.size
      )
    end

    refresh
  end

  def remove_upload(super_image, raise_errors: true)
    alias_name = super_image.index_name
    attrs = super_image.elastic_record['_source']

    destroy_record(super_image.index_record_id, raise_errors: raise_errors)
    refresh

    # we are deleting the file copy as well
    if alias_name != 'uploads' # -> institutional
      target = "#{ENV['PM_IMAGES_DIR']}/#{alias_name}/original"
      file = "#{target}/#{attrs['path']}"
      system 'rm', '-f', file
    end
  end

  def miro_record_ids
    @miro_record_ids ||= Rails.configuration.x.indexing_warburg_and_miro_record_ids['miro']
  end

  def index_attributes(super_image)
    index_name = super_image.index_name
    upload = super_image.upload

    attributes = upload.attributes
    attributes['record_id'] = upload.id.to_s
    attributes['path'] = "#{attributes['image_id']}.#{attributes['filename_extension']}"
    attributes['keywords'] = upload.keywords.to_a.map{|keyword| keyword.title} if upload.keywords.count > 0
    attributes['name'] = index_name
    if !attributes['date'].blank?
      attributes['date_range'] = Indexing::SourceSuper.new.single_date_range(attributes['date'])
    end
    processed_fields = Indexing::FieldProcessor.new(source: attributes, field_keys: Indexing::IndexFields.index).run
    validated_fields = Indexing::FieldValidator.new(processed_fields: processed_fields).run


    # Handle Miro.
    miro = miro_record_ids['index_name'] || []
    if miro.include?(validated_fields['record_id'])
      validated_fields['path'] = "miro"
    end

    # If there is an existing index record ID, we want to keep it in order
    # that collections or links are still valid. See #1012.
    if !upload.index_record_id.blank?
      validated_fields['record_id'] = upload.index_record_id
    end

    validated_fields
  end

  def index_uploads(source)
    index_name = create_index(source.name)
    alias_name = alias_name_from(index_name: index_name)
    tmp_file = Tempfile.new('image_list_')
    miro_record_ids = Rails.configuration.x.indexing_warburg_and_miro_record_ids[:miro][:alias_name]
    records_created = 0

    source.uploads.each do |upload|
      validated_fields = index_attributes(upload.super_image)
      create_index_record(index_name, validated_fields['record_id'], validated_fields)

      # Handle Miro.
      if miro_record_ids && miro_record_ids.include?(validated_fields['record_id'])
        validated_fields['path'] = "miro"
      else
        tmp_file.write("#{validated_fields['path']}\n")
      end

      records_created += 1

      printf "\rRecords created: #{records_created} | updated: 0 (indexed in total: #{records_created}) | excluded: 0" unless Rails.env.test?
    end

    puts

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
                                        is_time_searchable: true,
                                        record_count: source.uploads.size)

    # Run post indexing tasks.
    source_parent = Indexing::SourceParent.new
    source_parent.index_comments(alias_name)
    source_parent.index_ratings(alias_name)
    source_parent.index_image_vectors(alias_name)
    source_parent.check_klapsch([alias_name])

    source.uploads.count
  end

  def analyze(alias_name, analyzer, text)
    data = request 'GET', "/#{index_name_from(alias_name: alias_name)}/_analyze", {}, {}, {
      analyzer: analyzer,
      text: text
    }

    require_ok!
    data
  end

  protected

    def request(method = 'GET', path = '/', params = {}, headers = {}, body = nil)
      retries = 0
      headers.reverse_merge!(
        'content-type' => 'application/json',
        'accept' => 'application/json'
      )

      if body && !body.is_a?(String)
        body = body.to_json
      end

      begin
        @response = client.request(
          method, "#{ENV['PM_ELASTIC_URI']}#{path}",
          params, body ? body : '', headers
        )
      rescue Timeout::Error
        retries += 1
        raise if retries > 1
        retry
      end

      if method == 'HEAD'
        @response.status_code
      else
        JSON.parse(@response.body)
      end
    end

    def client
      @client ||= begin
        http_client = HTTPClient.new
        # Necessary for index packs loading with mapping update.
        #http_client.send_timeout = 480
        #http_client.receive_timeout = 480
        http_client
      end
    end
end
