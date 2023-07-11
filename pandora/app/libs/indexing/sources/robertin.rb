class Indexing::Sources::Robertin < Indexing::SourceSuper
  def records
    document.xpath("//row")
  end

  def record_id
    record.xpath(".//grossbildnummer/text()")
  end

  def path
    record.at_xpath(".//grossbildnummer/text()")
  end

  def description
    record.xpath(".//darstellung/text()", ".//gestaltung/text()")
  end

  def artist
    record.xpath(".//werkstatt/text()")
  end

  def title
    record.xpath(".//titel/text()").to_a.join(' | ')
  end

  def date
    record.xpath(".//datierung/text()")
  end

  def date_range
    date = record.xpath(".//datierung/text()").to_s
    date.encode!('iso-8859-1').encode!('utf-8')

    super(date)
  end

  def genre
    record.xpath(".//form/text()")
  end

  def location
    record.xpath(".//standort/text()")
  end

  def discoveryplace
    record.xpath(".//fundort/text()")
  end

  def credits
    record.xpath(".//bildrecht/text()")
  end
end
