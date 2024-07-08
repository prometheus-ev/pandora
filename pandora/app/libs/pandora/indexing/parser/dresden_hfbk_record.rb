class Pandora::Indexing::Parser::DresdenHfbkRecord < Pandora::Indexing::Parser::Record
  def record_id
    @record_id ||= record.xpath('./Bildidentifikationsvermerk/text()')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "#{record.at_xpath('./Bildidentifikationsvermerk/text()')}.jpg".gsub(/.tif/, '')
  end

  def artist
    @artist ||= ["#{record.xpath('./Vorname/text()')} #{record.xpath('./Name/text()')}"]
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    @artist_normalized = @artist_parser.normalize(artist)
  end

  def title
    record.xpath('./Titel/text()')
  end

  def location
    record.xpath('./Standort/text()')
  end

  def date
    record.xpath('./Datierung/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def credits
    "#{record.xpath('./Verfasser/text()')}: ".gsub(/\A: /, '') +
    "#{record.xpath('./Buchtitel/text()')}.".gsub(/\A\./, '') +
    " #{record.xpath('./Ort/text()')} #{record.xpath('./Jahr/text()')}.".gsub(/ \./, '').gsub(/\A  /, '') +
    " S. #{record.xpath('./Seite/text()')}.".gsub(/ S\. \./, '')
  end

  def size
    record.xpath('./Groesse/text()')
  end

  def material
    record.xpath('./Material/text()')
  end

  def genre
    record.xpath('./Gattung/text()')
  end

  def technique
    record.xpath('./Technik/text()')
  end

  def inventory_no
    record.xpath('./Inventarnummer/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('./Urheberrechtsvermerk/text()')
  end
end
