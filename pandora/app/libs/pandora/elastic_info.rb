module Pandora::ElasticInfo
  def version
    data = request
    require_ok!
    if data['version'] && data['version']['number'] && data['version']['lucene_version']
      "Elasticsearch #{data['version']['number']} (based on Lucene #{data['version']['lucene_version']})"
    else
      "Elasticsearch (based on Lucene)"
    end
  end

  def info(sort_by_time: false)
    info_data = []
    info = []
    alias_count = aliases.count
    total_record_count = 0
    total_date_record_count = 0
    total_parsed_date_record_count = 0

    aliases.sort.each do |a|
      info_data_row = []
      source = Source.find_by_name(a)
      index_name = index_name_from(alias_name: a)

      if source
        total_record_count += source.record_count

        date_record_count = date_aggregations([source.name])['aggregations']['date_count']['value']
        total_date_record_count += date_record_count

        if source.is_time_searchable?
          parsed_date_record_count = date_aggregations([source.name])['aggregations']['date_range_from_stats']['count']
          total_parsed_date_record_count += parsed_date_record_count
          unparsed_date_record_count = date_record_count - date_aggregations([source.name])['aggregations']['date_range_from_stats']['count']
          parsed_date_record_percentage = parsed_date_record_count.to_d / (date_record_count.nonzero? || 1).to_d * 100.0
        end
      end

      info_data_row << source.name
      info_data_row << index_name
      info_data_row << source.record_count
      info_data_row << date_record_count
      info_data_row << parsed_date_record_count
      info_data_row << unparsed_date_record_count
      info_data_row << (parsed_date_record_percentage || 0.0)

      info_data << info_data_row
    end

    if sort_by_time
      info_data = info_data.sort{|a, b| a[6].nil? && b[6].nil? ? a[0] <=> b[0] : (a[6].nil? ? 1 : (b[6].nil? ? -1 : b[6] <=> a[6]))}
    else
      info_data.sort{|a, b| a[0] <=> b[0]}
    end

    info << '|_.alias_name|_.index_name|_.total records|_.date records|_.parsed date records|_.unparsed date records|_.parsed date record percentage|'

    info_data.each do |info_data_row|
      info_row = ''

      if info_data_row[3] == 0
        info_row += '{color:grey}. '
      elsif info_data_row[6] && info_data_row[6] < 95.0
        info_row += '{color:red}. '
      elsif info_data_row[6] && info_data_row[6] >= 95.0
        info_row += '{color:green}. '
      end

      info_row += "|#{info_data_row[0]}|" +
        "#{info_data_row[1]}|" +
        ">.#{ActiveSupport::NumberHelper::number_to_delimited(info_data_row[2])}|" +
        ">.#{ActiveSupport::NumberHelper::number_to_delimited(info_data_row[3])}|" +
        ">.#{ActiveSupport::NumberHelper::number_to_delimited(info_data_row[4]) || '-'}|" +
        ">.#{ActiveSupport::NumberHelper::number_to_delimited(info_data_row[5]) || '-'}|"

      if info_data_row[6] && info_data_row[6] < 95.0
        info_row += ">.*#{ActiveSupport::NumberHelper::number_to_rounded(info_data_row[6], precision: 2)}*|"
      else
        info_row += ">.#{ActiveSupport::NumberHelper::number_to_rounded(info_data_row[6], precision: 2)}|"
      end

      info << info_row
    end

    info << "|Counts: #{alias_count}||#{total_record_count}|#{total_date_record_count}|#{total_parsed_date_record_count}|||"

    Pandora.puts 'Redmine Textile table markup language:'
    Pandora.puts info
  end

  def object_indices
    source_files = Dir.glob("app/libs/indexing/sources/*.rb")
    sources = source_files.filter_map {|source_file|
      source_file = File.basename(source_file, ".rb")
      source = source_file.camelize.constantize.new
      source if source
    }
    sources = sources.delete_if {|source|
      !source.respond_to?('record_object_id_count')
    }
    sources = sources.filter_map {|source|
      source = Source.find_by_name(source.name)
      source if source
    }
    sources.sort_by{|source| source.title}
  end
end
