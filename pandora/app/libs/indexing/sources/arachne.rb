class Indexing::Sources::Arachne < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//data')
  end

  def s_keyword
    [record.xpath('.//wwwKunsthistorEinordnung/text()'), record.xpath('.//wwwBeschreibung/text()'), record.xpath('.//wwwMetasuche/text()')]
  end

  def s_credits
    [record.xpath('.//wwwFotodaten/text()'), record.xpath('.//wwwLiteraturangaben/text()')]
  end

  def s_unspecified
    [record.xpath('.//wwwKunsthistorEinordnung/text()'), record.xpath('.//wwwFunktionen/text()')]
  end

  def path
    "Abbildungen/#{record.at_xpath('.//data/text()')}".gsub(/:/, '/')
  end

  # künstler
  def artist
    [""]
  end

  # titel
  def title
    "#{record.xpath('.//wwwBenennung/text()')}, #{record.xpath('.//Kurzbeschreibung/text()')}".gsub(/\A, /, "").gsub(/, \z/, "")
  end

  # datierung
  def date
    record.xpath('.//wwwDatierung/text()')
  end

  def date_range
    super(date.to_s)
  end

  # standort
  def location
    record.xpath('.//wwwAufbewahrung/text()')
  end

  # fundort
  def discoveryplace
    record.xpath('.//wwwFundort/text()')
  end

  # einordnung
  def classification
    record.xpath('.//wwwKunsthistoreinordnung/text()')
  end

  # beschreibung
  def description
    record.xpath('.//wwwBeschreibung/text()')
  end

  # funktion
  def function
    record.xpath('.//wwwFunktionen/text()')
  end

  # literatur
  def credits
    record.xpath('.//wwwLiteraturangaben/text()')
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//wwwFotodaten/text()')
  end
end
