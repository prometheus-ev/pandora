class Indexing::Sources::Bpk < Indexing::SourceSuper
  # TODO Where is this expression in pandora? In pandora bpk has 17256 records, in athene only 13634
  def records
    document.xpath('//PHOTO[not(contains(OBJECTTYPE, "Fotografie") and contains(INSTITUTION, "Kunstbibliothek"))]')
  end

  def record_id
    record.xpath('.//FILENAME/text()')
  end

  def path
    return miro if miro?

    record.at_xpath('.//FILENAME/text()')
  end

  def records_to_exclude
    %w[21466 21468 21469 21470 21471 21472 21473 21474 21475 23204 43884 43887 44005 44148 75689]
  end

  def s_artist
    [record.xpath('.//ARTIST/@relation/text()'), record.xpath('.//ARTIST/FUNCTION/text()'), record.xpath('.//ARTIST/LIFE/text()'), record.xpath('.//ARTIST/NAME_andere_Schreibweise/text()'), record.xpath('.//ARTIST/NAME_Eigentlicher_Name/text()'), record.xpath('.//ARTIST/NAME_Eventuelle_Identität/text()'), record.xpath('.//ARTIST/NAME_Irrtümlicher_Name/text()'), record.xpath('.//ARTIST/NAME_Pseudonym/text()'), record.xpath('.//ARTIST/NAME_Sortierung/text()'), record.xpath('.//ARTIST/NAME_Standard/text()'), record.xpath('.//ARTIST/NAME_WeitererName/text()'), record.xpath('.//ARTIST/NAME_Zweitname/text()'), record.xpath('.//ARTIST/NAME_Akl-Name/text()'), record.xpath('.//ARTIST/NAME_Thieme-Becker-Name/text()'), record.xpath('.//ARTIST/NAME_Vollmer-Name/text()'), record.xpath('.//ARTIST/NAME_Geburtsname/text()'), record.xpath('.//ARTIST/NAME_Abkürzung/text()')]
  end

  def s_title
    [record.xpath('.//TITLE_Abweichender_Titel/text()'), record.xpath('.//TITLE_Übersetzung_engl/text()'), record.xpath('.//TITLE_bpk/text()'), record.xpath('.//TITLE_Museum/text()'), record.xpath('.//TITLE_Originaltitel/text()'), record.xpath('.//TITLE_RaO/text()'), record.xpath('.//TITLE_Zuordnung_RuB/text()'), record.xpath('.//TITLE_Zusatztitel/text()'), record.xpath('.//TITLE_Bearbeitertitel/text()'), record.xpath('.//TITLE_Übersetzung/text()')]
  end

  def s_location
    [record.xpath('.//INSTITUTION/text()'), record.xpath('.//GEOREL_Archipel/text()'), record.xpath('.//GEOREL_Atoll/text()'), record.xpath('.//GEOREL_Dorf/text()'), record.xpath('.//GEOREL_Inselgruppe/text()'), record.xpath('.//GEOREL_Kloster/text()'), record.xpath('.//GEOREL_Kolonie/text()'), record.xpath('.//GEOREL_Oase/text()'), record.xpath('.//GEOREL_Ortsteil/text()'), record.xpath('.//GEOREL_Provinz/text()'), record.xpath('.//GEOREL_Reservation/text()'), record.xpath('.//GEOREL_Schauplatz/text()'), record.xpath('.//GEOREL_Schauplatz_Ort/text()'), record.xpath('.//GEOREL_Schauplatz_Stadt/text()'), record.xpath('.//GEOREL_Stamm/text()'), record.xpath('.//GEOREL_Station/text()'), record.xpath('.//GEOREL_Territorium/text()'), record.xpath('.//GEOREL_Verwendungsort/text()'), record.xpath('.//GEOREL_Verwendungsort/text()'), record.xpath('.//GEOREL_Werkstatt/text()'), record.xpath('.//GEOREL_Archäologische_Region/text()'), record.xpath('.//GEOREL_Aufnahmeort/text()'), record.xpath('.//GEOREL_Bundesstaat/text()'), record.xpath('.//GEOREL_Entstehungsort_stilistisch/text()'), record.xpath('.//GEOREL_Ethnie/text()'), record.xpath('.//GEOREL_ETHNIE/text()'), record.xpath('.//GEOREL_Fluss/text()'), record.xpath('.//GEOREL_Insel/text()'), record.xpath('.//GEOREL_Königreich/text()'), record.xpath('.//GEOREL_Kontinent/text()'), record.xpath('.//GEOREL_Kultur/text()'), record.xpath('.//GEOREL_Land/text()'), record.xpath('.//GEOREL_Land_Region/text()'), record.xpath('.//GEOREL_Ort/text()'), record.xpath('.//GEOREL_Region/text()'), record.xpath('.//GEOREL_Stadt/text()'), record.xpath('.//GEOREL_Stadt_oder_Gemeinde/text()'), record.xpath('.//GEOREL_Stadtteil/text()'), record.xpath('.//GEOREL_Station/text()'), record.xpath('.//GEOREL_Tempel/text()')]
  end

  def s_credits
    [record.xpath('.//LITERATURE/text()'), record.xpath('.//RESTRICTION/text()'), record.xpath('.//COPYRIGHT/text()'), record.xpath('.//PHOTOGRAPHER/text()')]
  end

  def s_discoveryplace
    [record.xpath('.//GEOREL_Fundort/text()'), record.xpath('.//GEOREL_Fundort_Grab/text()'), record.xpath('.//GEOREL_Fundort_Landschaft/text()'), record.xpath('.//GEOREL_Fundort_Stadt/text()'), record.xpath('.//GEOREL_Fundort_Tempel/text()'), record.xpath('.//GEOREL_Fundort_Department/text()'), record.xpath('.//GEOREL_Fundort_Land_Region/text()'), record.xpath('.//GEOREL_Fundort_Ort/text()'), record.xpath('.//GEOREL_Fundort_Region/text()')]
  end

  # künstler
  def artist
    ["#{record.xpath('.//ARTIST/NAME_Standard/text()')} (#{record.xpath('.//ARTIST/@relation/text()')}) #{record.xpath('.//ARTIST/LIFE/text()')}".gsub(/ \(\)/, '')]
  end

  def artist_normalized
    super(record.xpath('.//ARTIST/NAME_Standard/text()'))
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

  # titel
  def title
    record.xpath('.//TITLE_bpk/text()')
  end

  # Titelvarianten
  def title_variants
    record.xpath('.//TITLE_Originaltitel/text()') +
    record.xpath('.//TITLE_Museum/text()') +
    record.xpath('.//TITLE_RaO/text()')
  end

  # datierung
  def date
    "#{record.xpath('.//YEARFROM/text()')} bis #{record.xpath('.//YEARTILL/text()')}".gsub(/\A bis /, '').gsub(/ bis \z/, '')
  end

  def date_range
    super(date)
  end

  # location
  def location
    ("#{record.xpath('.//INSTITUTION/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Land/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Land_Region/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Ort/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Region/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Stadt/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Stadt_oder_Gemeinde/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Stadtteil/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//GEOREL_Station/text()')}, ".gsub(/\A, /, '')  +
     "#{record.xpath('.//GEOREL_Tempel/text()')}").gsub(/, \z/, '')
  end

  # institution
  def institution
    record.xpath('.//INSTITUTION/text()')
  end

  # Bildformat-Foto
  def format_foto
    record.xpath('.//MEASURE_Bildformat_Foto/text()')
  end

  # Blattmaß
  def sheetsize
    record.xpath('.//MEASURE_Blattmaß/text()')
  end

  # Breite
  def width
    record.xpath('.//MEASURE_Breite/text()')
  end

  # Durchmesser
  def diameter
    record.xpath('.//MEASURE_Durchmesser/text()')
  end

  # Format
  def format
    record.xpath('.//MEASURE_Format/text()')
  end

  # Gewicht
  def weight
    record.xpath('.//MEASURE_Gewicht/text()')
  end

  # Höhe
  def height
    record.xpath('.//MEASURE_Höhe/text()')
  end

  # Größe
  def size
    "#{record.xpath('.//MEASURE_Bildmass/text()')}, #{record.xpath('.//MEASURE_Objektmass/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # Länge
  def length
    record.xpath('.//MEASURE_Länge/text()')
  end

  # Abmessungen_Reliefhöhe
  def height_relief
    record.xpath('.//MEASURE_Reliefhöhe/text()')
  end

  # Abmessungen_Tiefe
  def depth
    record.xpath('.//MEASURE_Tiefe/text()')
  end

  # Abmessungen_Umfang
  def circumference
    record.xpath('.//MEASURE_Umfang/text()')
  end

  # Herstellungsort
  def manufacture_place
    record.xpath('.//GEOREL_Herstellungsort/text()')
  end

  # Herstellungsort_Grab
  def manufacture_place_grave
    record.xpath('.//GEOREL_Herstellungsort_Grab/text()')
  end

  # Herstellungsort_Region
  def manufacture_place_region
    record.xpath('.//GEOREL_Herstellungsort_Region/text()')
  end

  # Herstellungsort_Stadt
  def manufacture_place_city
    record.xpath('.//GEOREL_Herstellungsort_Stadt/text()')
  end

  # Herkunft
  def origin
    "#{record.xpath('.//GEOREL_Herkunftsort/text()')}"
  end

  # material
  def material
    record.xpath('.//MATERIAL/text()')
  end

  # Gattung
  def genre
    record.xpath('.//OBJECTTYPE/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//LITERATURE/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//COPYRIGHT/text()')
  end

  # Fotograf
  def photographer
    record.xpath('.//PHOTOGRAPHER/text()')
  end

  # Restriktion
  def restriction
    record.xpath('.//RESTRICTION/text()')
  end

  # schlagwörter
  def keyword
    record.xpath('.//KEY/text()')
  end
end
