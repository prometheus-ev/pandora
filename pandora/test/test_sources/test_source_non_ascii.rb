class TestSourceNonAscii < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//object-id/text()')
  end

  def path
    "#{record.at_xpath('.//path/text()')}.jpg"
  end

  def artist
    record.xpath('.//artist/text()')
  end

  def title
    record.xpath('.//title/text()')
  end

  def location
    record.xpath('.//location/text()')
  end
end
