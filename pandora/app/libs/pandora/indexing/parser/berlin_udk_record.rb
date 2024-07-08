class Pandora::Indexing::Parser::BerlinUdkRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//id/text()')
  end

  def path
    "#{record.xpath('.//filename/text()')}"
  end

  def artist
    record.xpath('.//name/text()')
  end

  def artist_normalized
    @artist_normalized ||= @artist_parser.normalize(artist)
  end

  def title
    record.xpath('.//title/text()')
  end

  def location
    "#{record.xpath('.//ort/text()')}, #{record.xpath('.//institution/text()')}".gsub(/\A-?, /, '').gsub(/, \z/, '')
  end

  def date
    record.xpath('.//dating/text()')
  end

  def date_range
    return @date_range if @date_range

    date = record.xpath('.//dating/text()').to_s.strip

    @date_range = @date_parser.date_range(date)
  end

  def credits
    ("#{record.xpath('.//literature/text()')}," +
     " S. #{record.xpath('.//page/text()')},".gsub(/ S\. ,/, '') +
    " Abb. #{record.xpath('.//figure/text()')}.".gsub(/ Abb\. \./, '') +
    " Taf. #{record.xpath('.//table/text()')}.".gsub(/ Taf\. \./, '')).gsub(/,\z/, '')
  end

  def rights_work
    if @warburg_parser.is_record_id_a_rights_work_warburg_record_id?(record_id, name)
      @warburg_parser.rights_work_warburg
    elsif @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def size
    record.xpath('.//format/text()')
  end

  def material
    record.xpath('.//material/text()')
  end

  def technique
    record.xpath('.//technique/text()')
  end

  def addition
    record.xpath('.//addition/text()')
  end
end
