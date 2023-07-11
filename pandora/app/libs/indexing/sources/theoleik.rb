class Indexing::Sources::Theoleik < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//bildreferenz/text()')
  end

  def path
    record.at_xpath('.//bildreferenz/text()')
  end

  def s_location
    [record.xpath('.//standort/text()'), record.xpath('.//herkunft/text()')]
  end

  # künstler
  def artist
    record.xpath('.//kuenstlerin/text()')
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # herkunft
  def origin
    record.xpath('.//herkunft/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # material
  def material
    record.xpath('.//material/text()')
  end

  # gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  # maße
  def size
    record.xpath('.//masse/text()')
  end

  # bildrecht
  def credits
    record.xpath('.//abbildungsnachweis/text()')
  end
end
