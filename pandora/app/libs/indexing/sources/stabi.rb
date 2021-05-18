class Indexing::Sources::Stabi < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//bildnummer/text()')
  end

  def path
    "#{record.at_xpath('.//bildnummer/text()')}.jpg"
  end

  def s_artist
    [record.xpath('.//verfasser/text()'), record.xpath('.//namensvariante/text()')]
  end

  def s_title
    [record.xpath('.//titel/text()'), record.xpath('.//untertitel/text()'), record.xpath('.//titel_zusatz/text()'), record.xpath('.//titelform/text()')]
  end

  def s_location
    [record.xpath('.//institution/text()'), record.xpath('.//erscheinungsort/text()'), record.xpath('.//druckort/text()'), record.xpath('.//herkunftsbibliothek/text()')]
  end

  def s_credits
    [record.xpath('.//literatur/text()'), record.xpath('.//verlag/text()'), record.xpath('.//drucker/text()'), record.xpath('.//copyright/text()'), record.xpath('.//andereausgaben/text()')]
  end

  def s_genre
    [record.xpath('.//stichwort/text()'), record.xpath('.//gattung/text()')]
  end

  def s_keyword
    [record.xpath('.//stichwortort/text()'), record.xpath('.//stichwort_bildinhalt/text()'), record.xpath('.//stichwortperson_/text()'), record.xpath('.//stichwort2/text()')]
  end

  # künstler
  def artist
    ["#{record.xpath('.//verfasser/text()')} (#{record.xpath('.//verfasserermittlung/text()')})".gsub(/ \(\)/, '')]
  end

  # titel
  def title
    "#{record.xpath('.//titel/text()')}" +
      ", #{record.xpath('.//untertitel/text()')} (Untertitel)".gsub(/, \(Untertitel\)/, "") +
    ", #{record.xpath('.//titel_zusatz/text()')} (Zusatz)".gsub(/,  \(Zusatz\)/, "") +
    ", #{record.xpath('.//titel_ermittlung/text()')} (Bemerkung)".gsub(/,  \(Bemerkung\)/, "") +
    ", #{record.xpath('.//titelform/text()')} (Form)".gsub(/,  \(Form\)/, "")
  end

  # institution
  def institution
    record.xpath('.//institution/text()')
  end

  # erscheinungsort
  def publicationplace
    record.xpath('.//erscheinungsort/text()')
  end

  # druckort
  def printingplace
    record.xpath('.//druckort/text()')
  end

  # herkunft
  def origin
    record.xpath('.//provenienz/text()')
  end

  # herkunftsbibliothek
  def library_origin
    record.xpath('.//herkunftsbibliothek/text()')
  end

  # verlag
  def publisher
    record.xpath('.//verlag/text()')
  end

  # drucker
  def printer
    record.xpath('.//drucker/text()')
  end

  # datierung
  def date
    record.xpath('.//erschJahr/text()')
  end

  # format
  def format
    record.xpath('.//format/text()')
  end

  # umfang
  def measure
    record.xpath('.//umfang/text()')
  end

  # rahmen
  def frame
    record.xpath('.//rahmen/text()')
  end

  # blattmass
  def sheetsize
    record.xpath('.//blattmass/text()')
  end

  # vorlage
  def pattern
    record.xpath('.//vorlage/text()')
  end

  # textform
  def textform
    record.xpath('.//textform/text()')
  end

  # schlagwoerter
  def keyword
    "#{record.xpath('.//stichwort/text()')}; #{record.xpath('.//stichwort2/text()')}".gsub(/\A; /, '').gsub(/; \z/, '')
  end

  # stichwortort
  def keyword_location
    record.xpath('.//stichwortort/text()')
  end

  # stichwortperson
  def keyword_person
    record.xpath('.//stichwortperson/text()')
  end

  # stichwortbildinhalt
  def keyword_content
    record.xpath('.//stichwort_bildinhalt/text()')
  end

  # literatur
  def literature
    record.xpath('.//literatur/text()')
  end

  # weitere Ausgaben
  def editions
    record.xpath('.//andereausgaben/text()')
  end

  # Szene
  def scene
    record.xpath('.//szene/text()')
  end

  # technik
  def technique
    record.xpath('.//material/text()')
  end

  # Gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  # Bemerkung
  def annotation
    record.xpath('.//bemerkung/text()')
  end

  # Bermerkung (technisch)
  def annotation_technical
    record.xpath('.//bemerkung_technisch/text()')
  end

  # Notationsbemerkung
  def notationnote
    record.xpath('.//notationsbemerkung/text()')
  end

  # sprache
  def language
    record.xpath('.//sprache/text()')
  end

  # fussnoten
  def footnote
    record.xpath('.//fussnote/text()')
  end

  # signatur
  def signature
    record.xpath('.//signatur/text()')
  end

  # siegelung
  def sealing
    record.xpath('.//siegelung/text()')
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//institution/text()')
  end
end
