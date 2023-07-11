class Indexing::Sources::ErlangenZeichnungen < Indexing::SourceSuper
  def records
    document.xpath('//bvb')
  end

  def record_id
    record.xpath('.//pid/text()')
  end

  def path
    "#{record.at_xpath('.//marc/record/controlfield[@tag="001"]/text()')}.jpg"
  end

  def s_unspecified
    ["Zeichnungen der Graphischen Sammlung"]
  end

  # künstler
  def artist
    record.xpath('.//marc/record/datafield[@tag="245"]/subfield[@code="c"]/text()')
  end

  # verfasser
  def artist
    record.xpath('.//marc/record/datafield[@tag="245"]/subfield[@code="c"]/text()')
  end


  # titel
  def title
    record.xpath('.//marc/record/datafield[@tag="245"]/subfield[@code="a"]/text()')
  end

  # Titelvarianten
  def title_variants
    "#{record.xpath('.//marc/record/datafield[@tag="740"]/subfield[@code="a"]/text()')}, #{record.xpath('.//marc/record/datafield[@tag="246"]/subfield[@code="a"]/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # datierung
  def date
    record.xpath('.//marc/record/datafield[@tag="260"]/subfield[@code="c"]/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # institution
  def location
    "Erlangen, Universitätsbibliothek, #{record.xpath('.//marc/record/datafield[@tag="852"]/subfield[@code="j"]/text()')} (Signatur)"
  end

  # Herkunftsort
  def origin
    record.xpath('.//marc/record/datafield[@tag="260"]/subfield[@code="a"]/text()')
  end

  # Gattung
  def genre
    "Zeichnung"
  end

  # Material/Technik
  def material
    record.xpath('.//marc/record/datafield[@tag="300"]/subfield[@code="b"]/text()')
  end

  # Maße
  def size
    record.xpath('.//marc/record/datafield[@tag="300"]/subfield[@code="c"]/text()')
  end

  # Zusatz
  def addition
    record.xpath('.//marc/record/datafield[@tag="500"]/subfield[@code="a"]/text()')
  end

  # Abbildungsnachweis
  def credits
    "Universitätsbibliothek Erlangen-Nürnberg"
  end

  # copyright
  def rights_reproduction
    "Alle Inhalte, insbesondere Fotografien und Grafiken, sind urheberrechtlich geschützt. Das Urheberrecht liegt, soweit nicht ausdrücklich anders gekennzeichnet, bei der Universitätsbibliothek Erlangen-Nürnberg.  Bitte holen Sie die Genehmigung zur Verwertung ein, insbesondere zur Weitergabe an Dritte, und übersenden Sie unaufgefordert ein kostenloses Belegexemplar."
  end

  def source_url
    record.xpath('.//viewer_url/text()')
  end
end
