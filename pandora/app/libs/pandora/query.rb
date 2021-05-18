class Pandora::Query
  def initialize(user, criteria)
    @user = user
    @criteria = criteria
  end

  def run(type = :search)
    flash = {}

    # limit indices to open sources for this user
    if @user.dbuser?
      @criteria[:indices] = { @user.open_sources.first.name => true }
    end

    search_result = []
    number_of = elastic.counts
    search_fields = athene_yml('athene_search_fields.yml')['search']
    sort_fields = athene_yml('athene_search_fields.yml')['sort']
    boolean_fields = [['and', 'must'], ['and not', 'must_not'], ['or', 'should']]

    # Boolean field @criteria
    boolean_fields_selected = {"0" => "must", "1" => "must", "2" => "must", "3" => "must"}
    if @criteria[:boolean_fields_selected].present?
      boolean_fields_selected.merge!(@criteria[:boolean_fields_selected])
    end

    # Search field @criteria
    search_fields_selected = {"0" => "all", "1" => "artist", "2" => "title", "3" => "location"}
    if @criteria[:search_field].present?
      search_fields_selected.merge!(@criteria[:search_field])
    end

    # Search value @criteria
    if type == :time
      # Time search default value
      search_values_text = {"0" => "*", "1" => "", "2" => "", "3" => ""}
    else
      search_values_text = {"0" => "", "1" => "", "2" => "", "3" => ""}
    end

    if @criteria[:search_value].present?
      search_values_text.merge!(@criteria[:search_value])
    else
      @criteria[:search_value] = search_values_text
    end

    # Date @criteria
    date_query = ""
    date_from = ""
    date_to = ""

    if @criteria[:date].present?
      if @criteria[:date][:query].present?
        date_query = @criteria[:date][:query]
      end
      if @criteria[:date][:from].present?
        date_from = @criteria[:date][:from]
      end
      if @criteria[:date][:to].present?
        date_to = @criteria[:date][:to]
      end
    end

    if (@criteria['search_value'] && (@criteria['search_value']['0'] != @criteria['previous_search_value']))
      date_from = ""
      date_to = ""
    end

    # Sort field @criteria
    if type == :time
      sort_field = "date"
    else
      sort_field = "relevance"
    end

    if @criteria[:sort].present?
      if @criteria[:sort][:field].present?
        sort_field = @criteria[:sort][:field]
      end
    end

    # Sort order @criteria
    sort_order = "asc"
    sort_order_reverse = "desc"

    if @criteria[:sort].present?
      if @criteria[:sort][:order].present?
        sort_order = @criteria[:sort][:order]
      else
        if sort_field == "relevance" || sort_field == "rating_average" || sort_field == "rating_count" || sort_field == "comment_count"
          sort_order = "desc"
          sort_order_reverse = "asc"
        end
      end
    end

    # Use raw fields for sorting except for date
    if sort_field == "date" && type == :time
      sort = [{
        "date_range_from" => {
           numeric_type: 'date',
           order: sort_order
        }
      }]
    elsif sort_field == "relevance"
      sort = [{
        "_score" => {
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

    # Available indices
    counts_hash = elastic.counts
    counts_hash.delete('total')

    if type == :time
      if @criteria[:source_name]
        sources = Source.where(name: @criteria[:source_name], is_time_searchable: true)
      else
        sources = Source.where(is_time_searchable: true)
      end
      indices_available =
        sources.pluck(:name) &
        counts_hash.select{|k, v| v > 0}.keys
    else
      indices_available =
        Source.pluck(:name) &
        counts_hash.select{|k, v| v > 0}.keys
    end

    indices = @criteria[:indices] ?
      indices_available & @criteria[:indices].select{|a, s| s == true}.keys :
      indices_available

    # Page param
    page_number = 1
    page_size = 10

    if @criteria[:page].present?
      if @criteria[:page][:number].present?
        page_number = @criteria[:page][:number].to_i
      end
      if @criteria[:page][:size].present?
        page_size = @criteria[:page][:size].to_i
      end
    end

    # Restrict page size to a maximum of 100
    if page_size > 100
      page_size = 100
    end

    page_from = (page_number - 1) * page_size

    query = {}
    query_must = []
    query_must_not = []
    query_should = []

    search_fields_selected.each { |position, search_field|
      unless search_values_text[position].blank?
        # @todo Check if all these exceptions can just be escaped.
        # The following reserved characters can only be used as described by the Query string syntax:
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_reserved_characters
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax
        # Some have to be filtered depending on their occurence to prevent syntax errors:

        # 1. remove occurences of colons from query string:
        search_value = search_values_text[position].gsub(":", " ")
        # Colons can be introduced later to specify field names or ranges, see:
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_field_names
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_ranges

        # 2. remove occurences of / and \:
        search_value = search_value.gsub("\/", " ")
        search_value = search_value.gsub("\\", " ")
        # / can be introduced later to support regular expressions, \ to provide escaping, see:
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_regular_expressions

        # 3. remove odd occurences of ":
        if search_value.scan(/\"/).count.odd?
          search_value = search_value.gsub("\"", " ")
        end
        # " can be used to enclose multiple terms into one and use Query string syntax operator on them.

        # 4. remove ( and ) if their respective count is not equal:
        if search_value.scan(/\(/).count != search_value.scan(/\)/).count
          search_value = search_value.gsub("\(", " ")
          search_value = search_value.gsub("\)", " ")
        end

        # 5. remove occurences of [ and ]:
        search_value = search_value.gsub("\[", " ")
        search_value = search_value.gsub("\]", " ")

        # 6. remove occurences of !, +, and -:
        search_value = search_value.gsub("!", " ")
        search_value = search_value.gsub("+", " ")
        # Do not remove the - from record IDs and record object IDs, otherwise they are not found.
        if search_field != "record_id" && search_field != "record_object_id"
          search_value = search_value.gsub("-", " ")
        end
        # !, +, and - could be used as boolean operator, see:
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_boolean_operators

        # 7. remove occurences of ~ at the beginning of the query string, if there is a space before ~, or if any non-digit nor space comes after ~:
        if search_value.gsub!(/(\A~|\ ~|~[^\ \d]+|~\d+[^\ \d]+)/, "")
          flash[:warning] = "The fuzzy operator '~' can only be appended to a term or phrase and be followed by a positive number.".t +
            " " +
            "As a result, your query has been corrected to the following string:".t +
            " " +
            "'#{search_value}'." +
            " " +
            "Please update your query if necessary.".t +
            " " +
            "See %s for details and examples." / "<a href='/#{I18n.locale}/help/syntax#fuzzy_search'>#{"fuzzy help".t}</a>"
        end

        # 8. remove occurences of ^ at the beginning of the query string and if there is a space before or a space after or a non-digit after ^:
        search_value = search_value.gsub(/(\A\^|\ \^|\^\ |\^\z)/, "")

        # 9. remove occurences of ^ if there is a non-digit after ^:
        if search_value.gsub!(/(\^\D)/, "")
          flash[:warning] = "The boost operator '^' can only be appended to a term or phrase and be followed by a positive number.".t +
            " " +
            "As a result, your query has been corrected to the following string:".t +
            " " +
            "'#{search_value}'." +
            " " +
            "Please update your query if necessary.".t +
            " " +
            "See %s for details and examples." / "<a href='/#{I18n.locale}/help/syntax#boosting'>#{"boost help".t}</a>"
        end

        # 10. remove occurences of ( and ) if there is only space in between:
        search_value = search_value.gsub(/\( *\)/, "")

        if search_value == "*"
          query_hash = {
            # Other field * search
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
            query_string: {
              # Set the query value to be parsed.
              query: "*",
              # Select the fields for which the query is executed.
              fields: athene_yml('athene_search_fields.yml')['mappings'][search_field]
            }
          }
        else
          # Surround with double quotes and use raw field (config/athene_search_fields.yml) to find exact matches for record_object_id.
          if search_field == "record_id" || search_field == "record_object_id"
            search_value = "\"#{search_value}\""
          elsif search_field == "rating_average"
            rating_average_rounded = search_value.gsub(",", ".").to_f.round
            # Use range query string syntax and search in the range of the rounded rating average search value.
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_ranges
            search_value = "[" + (rating_average_rounded.to_f - 0.5).to_s + " TO " + (rating_average_rounded.to_f + 0.4).to_s + "]"
          elsif search_field == "rating_count"
            search_value = search_value.to_i.to_s
          end

          # Other field search
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
          query_string = {
            # Set the query value to be parsed.
            query: search_value,
            default_operator: "AND",
            # Do not analyze wildcard since that might be a wrong guess. This has nothing to do with allowing wildcards.
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_wildcards
            analyze_wildcard: false,
            # Select the fields for which the query is executed.
            fields: athene_yml('athene_search_fields.yml')['mappings'][search_field]
          }

          # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#operator-min
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#type-cross-fields
          if search_field == 'all'
            query_string.merge!({
              type: "cross_fields",
              fields: Indexing::IndexFields.search_mapping(field: search_field)
            })
          end

          query_hash = {
            query_string: query_string
          }
        end

        # https://www.elastic.co/guide/en/elasticsearch/guide/current/combining-filters.html
        # "should": At least one of these clauses must match. The equivalent of OR.
        # If the next boolean field is "should", the current has to be "should" too. In all other
        # cases it can be "must".
        next_position = (position.to_i + 1).to_s

        if boolean_fields_selected[next_position] && boolean_fields_selected[next_position] == "should" && !search_values_text[next_position].blank?
          query_should.push(query_hash)
        elsif boolean_fields_selected[position] == "must"
          query_must.push(query_hash)
        elsif boolean_fields_selected[position] == "must_not"
          query_must_not.push(query_hash)
        else
          query_should.push(query_hash)
        end
      end
    }

    # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-query.html#ranges-on-dates
    if !date_from.blank? || !date_to.blank?
      range = {}

      if !date_from.blank?
        date_from_i = date_from.to_i

        if date_from_i < 0
          date_from = (date_from_i * -1).to_s.rjust(4, '0')
          range.merge!("gte": "#{date_from} BC")
        else
          date_from = date_from_i.to_s.rjust(4, '0')
          range.merge!("gte": date_from)
        end
      end

      if !date_to.blank?
        date_to_i = date_to.to_i

        if date_to_i < 0
          date_to = (date_to_i * -1).to_s.rjust(4, '0')
          range.merge!("lte": "#{date_to} BC")
        else
          date_to = date_to_i.to_s.rjust(4, '0')
          range.merge!("lte": date_to)
        end
      end

      date_query = {
        range: {
          "date_range": range
        }
      }

      query_must.push(date_query)
    end

    search_values = search_values_text.values

    query = {
      aggs: {
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

    # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html#bool-min-should-match
    # If there is more than 1 should clause, at least 1 should contribute to matching documents.
    if query_should.size > 1
      minimum_should_match = 1
    else
      minimum_should_match = 0
    end

    # Select checked indices only (all with a value of true)
    # checked_indices = indices.select { |key, value| value[:checked] }.keys
    # if @index.client.indices.exists index: checked_indices
    if !search_values.all? { |value| value.blank? } && !indices.empty?
      query.merge!(
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/query-time-boosting.html
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html#request-body-search-index-boost
        #indices_boost: Rails.configuration.x.athene_search_indices['boost'],
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html
        query: {
          bool: {
            # https://www.elastic.co/guide/en/elasticsearch/guide/current/combining-filters.html
            must: query_must,
            must_not: query_must_not,
            should: query_should,
            minimum_should_match: minimum_should_match
          }
        },
        sort: sort,
        from: page_from,
        size: page_size
      )

      if @criteria[:sample] && !@criteria[:sample].empty? # Sample search
        query[:from] = 0
        query[:size] = @criteria[:sample_size].to_i

        msearches = []
        indices.each do |i|
          msearches << {index: i}
          msearches << query
        end
        msearch_result = elastic.msearch msearches

        hits = []
        total = 0
        msearch_result['responses'].each do |response|
          total += response['hits']['hits'].size
          hits += response['hits']['hits']
        end

        search_result = {
          'hits' => {
            'total' => total,
            'hits' => hits
          }
        }

        if page_from < hits.size
          (page_from + page_size) <= hits.size ?
            (length = page_size) :
            (length = hits.size % page_size)

          search_result['hits']['hits'] = hits[page_from, length]
        else
          search_result['hits']['hits'] = []
        end
        search_result
      else
        search_result = elastic.search indices, query
      end
    else
      search_result = elastic.search indices, query
    end
    # end

    source_lookup = Source.includes(:institution, :keywords).map{|s| [s.name, s]}.to_h
    out_indices = {}
    indices_available.each do |i|
      out_indices[i] = {
        'checked' => !@criteria[:indices] || !!@criteria[:indices][i],
        'source' => source_lookup[i]
      }
    end

    object_ids = []
    aspects = {}

    if search_result.present?
      object_ids = search_result['hits']['hits'].
        map{|h| h['_source']['record_object_id']}.
        flatten.compact.uniq

      unless object_ids.empty?
        others = elastic.by_object_ids(object_ids)
        aspects = others['hits']['hits'].group_by{|r| r['_source']['record_object_id'].first}
      end
    end

    r = {
      'type' => type,
      'result' => search_result,
      'number_of' => number_of,
      'fields' => {
        'all' => search_fields,
        'selected' => search_fields_selected,
        'values' => search_values_text,
        'boolean' => boolean_fields,
        'boolean_selected' => boolean_fields_selected,
        'date_from' => date_from,
        'date_to' => date_to,
        'date_range' => elastic.date_aggregations(indices)
      },
      'sort' => {
        'fields' => sort_fields,
        'field' => sort_field,
        'order' => sort_order,
        'order_reverse' => sort_order_reverse
      },
      'indices' => out_indices,
      'object_ids' => object_ids,
      'aspects' => aspects,
      'flash' => flash
    }

    Pandora::SearchResult.new(r, @criteria)
  end

  def athene_yml(filename)
    file = "#{ENV['PM_ROOT']}/pandora/config/#{filename}"
    str = ERB.new(File.read file).result(binding)
    data = YAML.load(str)[Rails.env.to_s]
  end

  def elastic
    @elastic ||= Pandora::Elastic.new
  end
end
