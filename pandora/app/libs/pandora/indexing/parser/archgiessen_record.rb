class Pandora::Indexing::Parser::ArchgiessenRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//bilddatei/text()')
  end

  def s_credits
    [record.xpath('.//bildvorlage/text()'), record.xpath('.//literatur/text()')]
  end

  def path
    "#{record.xpath('.//bilddatei/text()')}"
  end

  def artist
    record.xpath('.//kuenstler/text()')
  end

  def title
    record.xpath('.//titel/text()')
  end

  def material
    record.xpath('.//material/text()')
  end

  def date
    record.xpath('.//datierung/text()')
  end

  def date_range
    @date_parser.date_range(date.to_s)
  end

  def location
    "#{record.xpath('.//standort_ort/text()')}, #{record.xpath('.//standort_land/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def discoveryplace
    "#{record.xpath('.//fundort_ort/text()')}, #{record.xpath('.//fundort_land/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def credits
    record.xpath('.//bildvorlage/text()')
  end

  def literature
    record.xpath('.//literatur/text()')
  end

  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  def keyword
    record.xpath('.//schlagwortreihe/text()')
  end
end
