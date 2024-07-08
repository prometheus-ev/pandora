class Pandora::Query
  def initialize(user, criteria)
    @user = user
    @criteria = criteria

    if @criteria[:time] == '1' && (@criteria.dig(:date, :from).present? || @criteria.dig(:date, :to).present?)
      @criteria[:time] = true
    end

    if @criteria[:objects] == '1'
      @criteria[:objects] = true
    end
  end

  def run(type = :search)
    flash = {}

    # limit indices to open sources for this user
    if @user.dbuser?
      @criteria[:indices] = {@user.open_sources.first.name => true}
    end

    search_result = []
    number_of = elastic.counts
    search_fields = Indexing::IndexFields.search
    sort_fields = Indexing::IndexFields.sort
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
    if @criteria[:time]
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

    # Sort field @criteria
    if @criteria[:time]
      sort_field = "date"
    else
      sort_field = "relevance"
    end

    # If it is a pur asterisk search, do not sort by relevance but by asterisk search field.
    asterisk_search_values = search_values_text.select do |key, value|
      value == '*'
    end
    non_asterisk_search_values = search_values_text.select do |key, value|
      value != '*' && !value.blank?
    end

    # If there are asterisk search values and non-asterisk search value, remove asterisk search values.
    if asterisk_search_values.size > 0 && non_asterisk_search_values.size > 0
      search_values_text.transform_values! do |value|
        if value == '*'
          value = ''
        else
          value
        end
      end

      asterisk_search_values = {}

      flash[:warning] = "Please do not use the '*' search in combination with other search values. '*' inputs have been removed for this search.".t
    end

    # Multiple asterisk search.
    if asterisk_search_values.size > 1
      kept_first = false

      search_values_text.update(search_values_text) do |key, value|
        if value == '*' && kept_first == false
          kept_first = true
          asterisk_search_values = {key => value}
          value
        elsif value == '*' && kept_first == true
          ''
        else
          value
        end
      end

      flash[:warning] = "Please use the '*' search in one search field only. The first one has been used for this search.".t
    end

    # Asterisk only seach.
    if !@criteria[:time]
      if asterisk_search_values.size == 1
        relevance_sort_field = search_fields_selected[asterisk_search_values.keys.first]

        if relevance_sort_field == 'all' || !sort_fields.include?(relevance_sort_field)
          sort_field = 'title'
        else
          sort_field = relevance_sort_field
        end
      # Use user search order setting only if it is no asterisk search.
      else
        if search_order_setting = @user.search_settings[:order]
          sort_field = search_order_setting
        end
      end
    end

    if @criteria.dig(:sort, :field).present?
      sort_field = @criteria[:sort][:field]
    end

    # Sort order @criteria
    sort_order = "asc"
    sort_order_reverse = "desc"

    if @criteria.dig(:sort, :order).present?
      sort_order = @criteria[:sort][:order]
      sort_order_reverse = sort_order == 'asc' ? 'desc' : 'asc'
    else
      if sort_field == "relevance" || sort_field == "rating_average" || sort_field == "rating_count" || sort_field == "comment_count"
        sort_order = "desc"
        sort_order_reverse = "asc"
      end
    end

    # Use raw fields for sorting except for date
    if sort_field == "date" && @criteria[:time]
      sort = [{
        "date_range_from" => {
          numeric_type: 'date',
          order: sort_order
        }
      }]
    elsif sort_field == "relevance"
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

    search_fields_selected.each do |position, search_field|
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
              query: search_value,
              # Select the fields for which the query is executed.
              fields: Indexing::IndexFields.search_mapping(field: search_field)
            }
          }
        else
          # Surround with double quotes and use raw field (see IndexFields class) to find exact matches for record_object_id.
          if search_field == "record_id" || search_field == "record_object_id"
            search_value = "\"#{search_value}\""
          elsif search_field == "rating_average"
            rating_average_rounded = search_value.gsub(",", ".").to_f.round
            # Use range query string syntax and search in the range of the rounded rating average search value.
            # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#_ranges
            search_value = "[" + (rating_average_rounded.to_f - 0.5).to_s + " TO " + (rating_average_rounded.to_f + 0.4).to_s + "]"
          elsif search_field == "rating_count"
            search_value = "rating_count:#{search_value}"
          end

          # Other field search
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html
          query_string = {
            query: search_value,
            default_operator: "AND",
            # auto_generate_synonyms_phrase_query: false,
            analyze_wildcard: true,
            fields: Indexing::IndexFields.search_mapping(field: search_field),
            type: "cross_fields"
          }

          # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#operator-min
          # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html#type-cross-fields
          if search_field == 'all'
            # query_string.merge!({
            #  type: "cross_fields"
            # })
          end

          # Default query string settings.
          query_string.merge!({
            fuzziness: "AUTO"
          })

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
    end

    # Date from/to validations.
    if @criteria[:time]
      if !date_to.blank?
        if date_to.to_i > Date.today.year
          date_to = Date.today.year.to_s
          @criteria['date']['to'] = date_to
        end
      end
      if !date_from.blank? && !date_to.blank?
        date_from_i = date_from.to_i
        date_to_i = date_to.to_i

        if date_from_i > date_to_i
          date_from_tmp = date_from
          date_from = date_to
          date_to = date_from_tmp

          @criteria[:date][:from] = date_from
          @criteria[:date][:to] = date_to

          flash[:warning] = "The start year of your date filter has been later then the end year.".t +
            " " +
            "As a result, your query has been corrected and the dates have been reversed.".t
        end
      end
    end
    if @criteria[:time] && (date_from.blank? || date_to.blank?)
      if !date_from.blank?
        date_to = date_from
        @criteria[:date][:to] = date_from
      end
      if !date_to.blank?
        date_from = date_to
        @criteria[:date][:from] = date_to
      end
    end

    if @criteria[:time]
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
    end

    search_values = search_values_text.values

    aggs = {}
    aggs.merge!(elastic.date_aggregation)
    aggs.merge!(elastic.object_count_aggregation)

    query = {
      aggs: aggs,
      size: 0
    }

    # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html#bool-min-should-match
    # If there is a should clause, at least one of both should contribute to matching documents.
    minimum_should_match = query_should.size - 1


    # Select checked indices only (all with a value of true)
    # checked_indices = indices.select { |key, value| value[:checked] }.keys
    # if @index.client.indices.exists index: checked_indices
    if !search_values.all?{|value| value.blank?} && !indices.empty?
      query_bool = {
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/combining-filters.html
        must: query_must,
        must_not: query_must_not,
        should: query_should,
        minimum_should_match: minimum_should_match
      }

      filter = []
      # #1584: Unfortunately, if searching for a detail of a non-main-record, the result is not shown
      # with this filter. Disable for now.
      # Collapse seems the right feature to use.
      # filter << elastic.is_main_record_filter

      if @criteria[:objects]
        filter << elastic.record_object_id_count_filter
        # query.merge!(elastic.record_object_id_aggregations(sort))
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
        # query.merge!({
        #  collapse: {
        #    field: 'record_object_id.raw',
        #    inner_hits: {
        #      name: 'objects',
        #      size: 10
        #    }
        #  }
        # })
        # page_from = 0
        # page_size = 0
      end

      # Merge filter into bool query.
      query_bool.merge!({filter: filter})

      query.merge!(
        # https://www.elastic.co/guide/en/elasticsearch/guide/current/query-time-boosting.html
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-body.html#request-body-search-index-boost
        # indices_boost: Rails.configuration.x.athene_search_indices[:boost],
        # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-bool-query.html
        query: {
          bool: query_bool
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

    object_ids = []
    aspects = {}

    if search_result.present?
      object_ids = search_result['hits']['hits'].
        map{|h| h['_source']['record_object_id']}.
        flatten.compact.uniq

      unless object_ids.empty?
        object_ids.each do |object_id|
          others = elastic.by_object_ids(Array.wrap(object_id), 20)
          aspects.merge!(others['hits']['hits'].group_by{|r| r['_source']['record_object_id'].first})
        end
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

  def similar
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

    sort_fields = Indexing::IndexFields.sort
    sort_field = "relevance"
    sort_order = "asc"
    sort_order_reverse = "desc"

    if @criteria.dig(:sort, :field).present?
      sort_field = @criteria[:sort][:field]
    end

    if @criteria.dig(:sort, :order).present?
      sort_order = @criteria[:sort][:order]
      sort_order_reverse = sort_order == 'asc' ? 'desc' : 'asc'
    else
      if sort_field == "relevance" || sort_field == "rating_average" || sort_field == "rating_count" || sort_field == "comment_count"
        sort_order = "desc"
        sort_order_reverse = "asc"
      end
    end

    search_result = elastic.image_vector_query(record_id: @criteria[:search_value]['0'], page_size: page_size, page_from: page_from, sort_field: sort_field, sort_order: sort_order)
    number_of = elastic.counts
    search_fields = Indexing::IndexFields.search
    search_fields_selected = {"0" => "record_id", "1" => "artist", "2" => "title", "3" => "location"}
    search_values_text = {"0" => "", "1" => "", "2" => "", "3" => ""}
    search_values_text.merge!(@criteria[:search_value])
    boolean_fields = [['and', 'must'], ['and not', 'must_not'], ['or', 'should']]
    boolean_fields_selected = {"0" => "must", "1" => "must", "2" => "must", "3" => "must"}
    object_ids = []
    aspects = {}
    flash = {}

    r = {
      'type' => :search,
      'result' => search_result,
      'number_of' => number_of,
      'fields' => {
        'all' => search_fields,
        'selected' => search_fields_selected,
        'values' => search_values_text,
        'boolean' => boolean_fields,
        'boolean_selected' => boolean_fields_selected
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

  def elastic
    @elastic ||= Pandora::Elastic.new
  end

  private

    def indices_available
      counts_hash = elastic.counts

      counts_hash.delete('total')
      Source.pluck(:name) & counts_hash.select{|k, v| v && v['records'] && v['records'] > 0}.keys
    end

    def out_indices
      out_indices = {}
      source_lookup = Source.
        where.
        not(kind: "User database").
        includes(:institution, :keywords).
        map{|s| [s.name, s]}.
        to_h

      indices_available.each do |i|
        out_indices[i] = {
          'checked' => !@criteria[:indices] || !!@criteria[:indices][i],
          'source' => source_lookup[i]
        }
      end

      out_indices
    end
end
