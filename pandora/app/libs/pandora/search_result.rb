class Pandora::SearchResult
  def initialize(result, criteria)
    @result = result
    @criteria = criteria

    #min_year = Date.parse(result['fields']['date_range']['aggregations']['date_range_from_stats']['min_as_string']).year
    #max_year = Date.parse(result['fields']['date_range']['aggregations']['date_range_to_stats']['max_as_string']).year

    if @criteria[:time] && @criteria['search_value']
      @date_range_from = @criteria['date']['from']
      @date_range_to = @criteria['date']['to']
    end

  end

  def result
    @result
  end

  # criteria accessors

  def pages
    (total.to_f / @criteria[:page][:size]).ceil
  end

  def sample
    @criteria[:sample]
  end

  def time
    @criteria[:time]
  end

  def objects
    @criteria[:objects]
  end

  def sample_size
    @criteria[:sample_size]
  end

  def db_group
    @criteria[:db_group]
  end

  def date
    @criteria[:date]
  end

  def source_name
    @criteria['source_name']
  end

  def previous_search_value
    @criteria['search_value'] ? @criteria['search_value']['0'] : ''
  end

  def per_page
    @criteria['page']['size']
  end

  def sort_order
    @criteria['sort']['order']
  end

  def sort_order_reverse
    @result['sort']['order_reverse']
  end

  def sort_field
    @result['sort']['field']
  end

  def flash
    @result['flash']
  end

  # result accessors

  def total_date_range_count
    if result['fields']['date_range']['aggregations']
      result['fields']['date_range']['aggregations']['date_range_from_stats']['count']
    else
      0
    end
  end

  def date_range_count
    hits.empty? ? 0 : result['result']['aggregations']['date_range_from_stats']['count']
  end

  def object_count
    hits.empty? ? 0 : result['result']['aggregations']['object_count']['value']
  end

  def date_range_from
    @date_range_from
  end

  def date_range_to
    @date_range_to
  end

  def field_selected
    result['fields']['selected']
  end

  def fields
    result['fields']['all']
  end

  def value_text
    result['fields']['values']
  end

  def boolean_fields
    result['fields']['boolean']
  end

  def boolean_fields_selected
    result['fields']['boolean_selected']
  end

  def number_of
    result['number_of']
  end

  def image_count(source)
    number_of[source]
  end

  def indices
    result['indices']
  end

  def sort_fields
    result['sort']['fields']
  end

  def hits
    return [] if result['result'].blank?

    result['result']['hits']['hits']
  end

  def pids
    hits.map{|h| h['_id']}
  end

  def indices_grouped
    field = @criteria[:db_group]
    indices_sorted = indices.sort_by do |key, value|
      value['source']['title']
    end

    if field == 'keywords'
      result = Hash.new
      indices_sorted.each do |key, value|
        value['source'].keywords.each do |keyword|
          if result[keyword.t]
            result[keyword.t].push [key, value]
          else
            result[keyword.t] = Array.new.push [key, value]
          end
        end
      end
    else
      result = indices_sorted.group_by do |key, value|
        case field
        when 'city' then value['source'].city
        when 'open_access'
          value['source'].open_access? ? 'Open Access' : 'Non Open Access'
        when 'kind'
          value['source']['kind'].pluralize
        when 'title'
          value["source"][field].split(" - ").first.strip if !value["source"][field].blank?
        else
          value["source"][field]
        end
      end
    end
    result.sort_by{|k, v| k}.to_h
  end

  def indices_checked
    result = {}
    indices.each do |key, value|
      result.merge! key => value['checked']
    end
    result
  end

  def checked_index_count
    indices.values.select{|i| i['checked']}.count
  end

  def indices_selected
    (@criteria[:indices] || []) &
    indices.keys &
    Source.open_access.pluck(:name)
  end

  def any_results?
    result['result'].present? &&
    result['result']['hits'].present? &&
    result['result']['hits']['hits'].present?
  end

  def total
    if result['result']['hits']['total'].is_a?(Hash)
      result['result']['hits']['total']['value']
    else
      result['result']['hits']['total']
    end
  end

  def total_hits
    total_hits = 0
    result['indices'].each_value do |index|
      total_hits += index['source']['record_count']
    end
    total_hits
  end

  def selected_total_hits
    total_hits = 0
    result['indices'].each_value do |index|
      if index['checked']
        total_hits += index['source']['record_count']
      end
    end
    total_hits
  end

  def object_ids
    result['object_ids']
  end

  def aspects
    result['aspects']
  end

  def aspects_for(pid, oid)
    (aspects[oid] || []).reject do |r|
      r['_id'] == pid
    end
  end
end
