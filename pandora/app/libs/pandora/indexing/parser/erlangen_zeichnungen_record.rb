class Pandora::Indexing::Parser::ErlangenZeichnungenRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./pid/text()')
  end

  def path
    "#{record.at_xpath('./marc/record/controlfield[@tag="001"]/text()')}.jpg"
  end

  def artist
    record.xpath('./marc/record/datafield[@tag="245"]/subfield[@code="c"]/text()')
  end

  def title
    record.xpath('./marc/record/datafield[@tag="245"]/subfield[@code="a"]/text()')
  end

  def title_variants
    "#{record.xpath('./marc/record/datafield[@tag="740"]/subfield[@code="a"]/text()')}, #{record.xpath('./marc/record/datafield[@tag="246"]/subfield[@code="a"]/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def date
    record.xpath('./marc/record/datafield[@tag="260"]/subfield[@code="c"]/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def location
    "Erlangen, Universitätsbibliothek, #{record.xpath('./marc/record/datafield[@tag="852"]/subfield[@code="j"]/text()')} (Signatur)"
  end

  def origin
    record.xpath('./marc/record/datafield[@tag="260"]/subfield[@code="a"]/text()')
  end

  def genre
    "Zeichnung"
  end

  def material
    record.xpath('./marc/record/datafield[@tag="300"]/subfield[@code="b"]/text()')
  end

  def size
    record.xpath('./marc/record/datafield[@tag="300"]/subfield[@code="c"]/text()')
  end

  def addition
    record.xpath('./marc/record/datafield[@tag="500"]/subfield[@code="a"]/text()')
  end

  def credits
    "Universitätsbibliothek Erlangen-Nürnberg"
  end

  def rights_reproduction
    "Alle Inhalte, insbesondere Fotografien und Grafiken, sind urheberrechtlich geschützt. Das Urheberrecht liegt, soweit nicht ausdrücklich anders gekennzeichnet, bei der Universitätsbibliothek Erlangen-Nürnberg.  Bitte holen Sie die Genehmigung zur Verwertung ein, insbesondere zur Weitergabe an Dritte, und übersenden Sie unaufgefordert ein kostenloses Belegexemplar."
  end

  def source_url
    record.xpath('./viewer_url/text()')
  end
end
