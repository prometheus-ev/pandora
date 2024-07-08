class Pandora::Indexing::Parser::GoettingenArchRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./bildnummer/text()')
  end

  def path
    record.at_xpath('./bildnummer/text()')
  end

  def artist
    record.xpath('./kuenstler/text()')
  end

  def title
    record.xpath('./titel/text()')
  end

  def date
    record.xpath('./datierung/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def location
    record.xpath('./standort/text()')
  end

  def discovery_place
    record.xpath('./fundort/text()')
  end

  def credits
    record.xpath('./bildnachweis/text()')
  end
end
