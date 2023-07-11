class Indexing::Sources::BerlinUdk < Indexing::SourceSuper
  def records
    document.xpath('//objekt')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def path
    "#{record.xpath('.//filename/text()')}"
  end

  def s_location
    [record.xpath('.//ort/text()'), record.xpath('.//institution/text()')]
  end

  # künstler
  def artist
    record.xpath('.//name/text()')
  end

  def artist_normalized
    super(record.xpath('.//name/text()'))
  end

  # titel
  def title
    record.xpath('.//title/text()')
  end

  # standort
  def location
    "#{record.xpath('.//ort/text()')}, #{record.xpath('.//institution/text()')}".gsub(/\A-?, /, '').gsub(/, \z/, '')
  end

  # datierung
  def date
    record.xpath('.//dating/text()')
  end

  def date_range
    date = record.xpath('.//dating/text()').to_s.strip

    super(date)
  end

  # bildnachweis
  def credits
    ("#{record.xpath('.//literature/text()')}," +
     " S. #{record.xpath('.//page/text()')},".gsub(/ S\. ,/, '') +
    " Abb. #{record.xpath('.//figure/text()')}.".gsub(/ Abb\. \./, '') +
    " Taf. #{record.xpath('.//table/text()')}.".gsub(/ Taf\. \./, '')).gsub(/,\z/, '')
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
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
