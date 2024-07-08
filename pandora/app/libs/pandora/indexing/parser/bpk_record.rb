class Pandora::Indexing::Parser::BpkRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//FILENAME/text()')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    record.at_xpath('.//FILENAME/text()')
  end

  def artist
    ["#{record.xpath('.//ARTIST/NAME_Standard/text()')} (#{record.xpath('.//ARTIST/@relation/text()')}) #{record.xpath('.//ARTIST/LIFE/text()')}".gsub(/ \(\)/, '')]
  end

  def artist_normalized
    @artist_normalized ||= @artist_parser.normalize(record.xpath('.//ARTIST/NAME_Standard/text()'))
  end

  def identity_artist
    identity_artist = []

    unless record.xpath('.//ARTIST/NAME_Pseudonym/text()').to_s.blank?
      pseudonym = record.xpath('.//ARTIST/NAME_Pseudonym/text()').to_s.encode("UTF-8")
      identity_artist += [pseudonym + " (Pseudonym)"]
    end

    unless record.xpath('.//ARTIST/NAME_Zweitname/text()').to_s.blank?
      second_name = record.xpath('.//ARTIST/NAME_Zweitname/text()').to_s.encode("UTF-8")
      identity_artist += [second_name + " (Zweitname)"]
    end

    unless record.xpath('.//ARTIST/NAME_Eigentlicher_Name/text()').to_s.blank?
      actual_name = record.xpath('.//ARTIST/NAME_Eigentlicher_Name/text()').to_s.encode("UTF-8")
      identity_artist += [actual_name + " (Eigentlicher Name)"]
    end

    unless record.xpath('.//ARTIST/NAME_Geburtsname/text()').to_s.blank?
      birth_name = record.xpath('.//ARTIST/NAME_Geburtsname/text()').to_s.encode("UTF-8")
      identity_artist += [birth_name + " (Geburtsname)"]
    end

    unless record.xpath('.//ARTIST/NAME_Eventuelle_Identität/text()').to_s.blank?
      potential_identity = record.xpath('.//ARTIST/NAME_Eventuelle_Identität/text()').to_s.encode("UTF-8")
      identity_artist += [potential_identity + " (Eventuelle Identität)"]
    end

    identity_artist.join(", ")
  end

  def title
    record.xpath('.//TITLE_bpk/text()')
  end

  def title_variants
    record.xpath('.//TITLE_Originaltitel/text()') +
    record.xpath('.//TITLE_Museum/text()') +
    record.xpath('.//TITLE_RaO/text()')
  end

  def date
    "#{record.xpath('.//YEARFROM/text()')} bis #{record.xpath('.//YEARTILL/text()')}".gsub(/\A bis /, '').gsub(/ bis \z/, '')
  end

  def date_range
    @date_range ||= @date_parser.date_range(date)
  end

  def location
    ("#{record.xpath('.//INSTITUTION/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Land/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Land_Region/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Ort/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Region/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Stadt/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Stadt_oder_Gemeinde/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Stadtteil/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Station/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Tempel/text()')}").gsub(/, \z/, '')
  end

  def institution
    record.xpath('.//INSTITUTION/text()')
  end

  def format_foto
    record.xpath('.//MEASURE_Bildformat_Foto/text()')
  end

  def sheetsize
    record.xpath('.//MEASURE_Blattmaß/text()')
  end

  def width
    record.xpath('.//MEASURE_Breite/text()')
  end

  def diameter
    record.xpath('.//MEASURE_Durchmesser/text()')
  end

  def format
    record.xpath('.//MEASURE_Format/text()')
  end

  def weight
    record.xpath('.//MEASURE_Gewicht/text()')
  end

  def height
    record.xpath('.//MEASURE_Höhe/text()')
  end

  def size
    "#{record.xpath('.//MEASURE_Bildmass/text()')}, #{record.xpath('.//MEASURE_Objektmass/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def length
    record.xpath('.//MEASURE_Länge/text()')
  end

  def height_relief
    record.xpath('.//MEASURE_Reliefhöhe/text()')
  end

  def depth
    record.xpath('.//MEASURE_Tiefe/text()')
  end

  def circumference
    record.xpath('.//MEASURE_Umfang/text()')
  end

  def manufacture_place
    record.xpath('.//GEOREL_Herstellungsort/text()')
  end

  def manufacture_place_grave
    record.xpath('.//GEOREL_Herstellungsort_Grab/text()')
  end

  def manufacture_place_region
    record.xpath('.//GEOREL_Herstellungsort_Region/text()')
  end

  def manufacture_place_city
    record.xpath('.//GEOREL_Herstellungsort_Stadt/text()')
  end

  def origin
    "#{record.xpath('.//GEOREL_Herkunftsort/text()')}"
  end

  def material
    record.xpath('.//MATERIAL/text()')
  end

  def genre
    record.xpath('.//OBJECTTYPE/text()')
  end

  def credits
    record.xpath('.//LITERATURE/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('.//COPYRIGHT/text()')
  end

  def photographer
    record.xpath('.//PHOTOGRAPHER/text()')
  end

  def restriction
    record.xpath('.//RESTRICTION/text()')
  end

  def keyword
    raw = record.xpath('.//KEY/text()').text || ''
    raw.split(/\s*;\s*/)
  end
end
