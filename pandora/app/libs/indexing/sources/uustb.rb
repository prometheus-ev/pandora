class Indexing::Sources::Uustb < Indexing::SourceSuper
  def records
    document.xpath('//obj')
  end

  def record_id
    record.xpath('.//a8450/a8540/text()')
  end

  def path
    ("#{record.at_xpath('.//a5000/text()')}".gsub(/\A0*/, '') << "/landschaft_web.jpg").sub(/^(\/*)/, '')
  end

  def s_location
    [record.xpath('.//aob28/a2864/text()'), record.xpath('.//aob28/a2900/text()')]
  end

  def s_material
    [record.xpath('.//a5650/a5674/text()'), record.xpath('.//a5650/a5676/text()'), record.xpath('.//a5260/text()'), record.xpath('.//a5280/text()')]
  end

  def s_unspecified
    record.xpath('.//aob28/a2950/text()')
  end

  # künstler
  def artist
    record.xpath('.//aob30/a3100/text()')
  end

  # titel
  def title
    record.xpath('.//a5200/text()')
  end

  # datierung
  def date
    record.xpath('.//a5060/a5064/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # gattung
  def genre
    "#{record.xpath('.//a5220/text()')}, #{record.xpath('.//a5222/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # material
  def material
    "#{record.xpath('.//a5260/text()')}, #{record.xpath('.//a5280/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # technik
  def technique
    record.xpath('.//a5300/text()')
  end

  # maße (höhe x breite)
  def size
    record.xpath('.//a5360/text()')
  end

  # standort
  def location
    record.xpath('.//aob28/a2900/text()')
  end

  # signatur
  def signature
    record.xpath('.//aob28/a2950/text()')
  end
end
