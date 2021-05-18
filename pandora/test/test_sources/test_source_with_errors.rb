class TestSourceWithErrors < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//Kennung/text()')
  end

  def path
    "#{record.at_xpath('.//Kennung/text()')}.jpg"
  end

  def artist
    record.xpath('.//Kuenstler/text()')
  end

  def title
    record.xpath('.//Objektname/text()')
  end

  def location
    "#{record.xpath('.//Land/text()')}, #{record.xpath('.//Standort/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end
end
