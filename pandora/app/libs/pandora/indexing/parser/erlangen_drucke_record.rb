class Pandora::Indexing::Parser::ErlangenDruckeRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./pid/text()')
  end

  def path
    "#{record.at_xpath('./premis/object/objectIdentifier/objectIdentifierValue/text()')}".gsub(/urn:nbn:de:bvb:29-/, '').sub(/-.\z/, '.jpg').sub(/-/, '_').capitalize
  end

  def artist
    record.xpath('//mods/mods/name[@type="personal" and role/roleTerm[text()="creator"]]/namePart').map(&:text)
  end

  def title
    record.xpath('./mods/mods/titleInfo/title/text()')
  end

  def date
    record.xpath('./mods/mods/originInfo/dateIssued[@keyDate="yes"]/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def location
    "#{record.xpath('./note/text()')}".gsub(/Einblattdrucke der /, '')
  end

  def publicationplace
    record.xpath('./mods/mods/originInfo/place/placeTerm[@type="text"]/text()')
  end

  def description
    record.xpath('./mods/mods/physicalDescription/form/text()')
  end

  def publisher
    record.xpath('./mods/mods/originInfo/publisher/text()')
  end

  def annotation
    if !(note = "#{record.xpath('./note/text()')}").include?("Literatur:")
      note
    end
  end

  def literature
    if (literatur = "#{record.xpath('./note/text()')}").include?("Literatur:")
      literatur
    end
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
