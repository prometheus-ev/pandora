class TestSourceXmlReader < Indexing::SourceSuper
  def records
    Indexing::XmlReaderNodeSet.new(document, "row", ".")
  end

  def record_id
    record.at_xpath('.//id/text()')
  end

  def path
    record.at_xpath('.//path/text()')
  end

  def artist
    record.xpath('.//artist/text()')
  end

  def title
    record.xpath('.//titel/text()')
  end

  def location
    record.xpath('.//location/text()')
  end
end
