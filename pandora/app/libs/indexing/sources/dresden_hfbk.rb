class Indexing::Sources::DresdenHfbk < Indexing::SourceSuper
  def records
    Indexing::XmlReaderNodeSet.new(document, "row", ".")
  end

  def record_id
    record.xpath('.//Bildidentifikationsvermerk/text()')
  end

  def path
    return miro if miro?

    "#{record.at_xpath('.//Bildidentifikationsvermerk/text()')}.jpg".gsub(/.tif/, '')
  end

  # künstler
  def artist
    ["#{record.xpath('.//Vorname/text()')} #{record.xpath('.//Name/text()')}"]
  end

  def artist_normalized
    super(artist)
  end

  # titel
  def title
    record.xpath('.//Titel/text()')
  end

  # standort
  def location
    record.xpath('.//Standort/text()')
  end

  # datierung
  def date
    record.xpath('.//Datierung/text()')
  end

  # bildnachweis
  def credits
    "#{record.xpath('.//Verfasser/text()')}: ".gsub(/\A: /, '') +
    "#{record.xpath('.//Buchtitel/text()')}.".gsub(/\A\./, '') +
    " #{record.xpath('.//Ort/text()')} #{record.xpath('.//Jahr/text()')}.".gsub(/ \./, '').gsub(/\A  /, '') +
    " S. #{record.xpath('.//Seite/text()')}.".gsub(/ S\. \./, '')
  end

  def size
    record.xpath('.//Groesse/text()')
  end

  def material
    record.xpath('.//Material/text()')
  end

  def genre
    record.xpath('.//Gattung/text()')
  end

  def technique
    record.xpath('.//Technik/text()')
  end

  def inventory_no
    record.xpath('.//Inventarnummer/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('.//Urheberrechtsvermerk/text()')
  end
end
