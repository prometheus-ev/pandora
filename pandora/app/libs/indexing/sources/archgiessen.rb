class Indexing::Sources::Archgiessen < Indexing::SourceSuper
  def records
    document.xpath('//datensatz')
  end

  def record_id
    record.xpath('.//bilddatei/text()')
  end

  def s_credits
    [record.xpath('.//bildvorlage/text()'), record.xpath('.//literatur/text()')]
  end

  def path
    "#{record.xpath('.//bilddatei/text()')}"
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # material/technik
  def material
    record.xpath('.//material/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  # standort
  def location
    "#{record.xpath('.//standort_ort/text()')}, #{record.xpath('.//standort_land/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # fundort
  def discoveryplace
    "#{record.xpath('.//fundort_ort/text()')}, #{record.xpath('.//fundort_land/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # bildnachweis
  def credits
    record.xpath('.//bildvorlage/text()')
  end

  # literatur
  def literature
    record.xpath('.//literatur/text()')
  end

  # copyright
  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  def keyword
    record.xpath('.//schlagwortreihe/text()')
  end
end
