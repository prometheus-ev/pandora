class Pandora::Indexing::Parser::EichstaettUbRecord < Pandora::Indexing::Parser::Record
  def record_id
    @record_id ||= record.xpath('@id')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    record.at_xpath('@thumbnail')
  end

  def artist
    record.xpath('./meta[@name="DC.creator"]/@content')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('./meta[@name="DC.creator"]/@content').map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('./meta[@name="DC.title"]/@content')
  end

  def date
    record.xpath('./meta[@name="DC.date"]/@content')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def location
    "#{record.xpath('./meta[@name="DC.coverage"]/@content')}, #{record.xpath('./meta[@name="DC.institution"]/@content')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def description
    record.xpath('./meta[@name="DC.description"]/@content')
  end

  def size
    record.xpath('./meta[@name="DC.format"]/@content')
  end

  def credits
    "#{record.xpath('./meta[@name="DC.source"]/@content')}. S. #{record.xpath('./meta[@name="DC.format-pages"]/@content')}. Abb. #{record.xpath('./meta[@name="DC.format-illustration"]/@content')}. Taf. #{record.xpath('./meta[@name="DC.format-table"]/@content')}.".gsub(/ S\. \./, '').gsub(/ Abb\. \./, '').gsub(/ Taf\. \./, '')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end
end
