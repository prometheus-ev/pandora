class Indexing::Sources::GoettingenArch < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//bildnummer/text()')
  end

  def path
    record.at_xpath('.//bildnummer/text()')
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # fundort
  def discovery_place
    record.xpath('.//fundort/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//bildnachweis/text()')
  end
end
