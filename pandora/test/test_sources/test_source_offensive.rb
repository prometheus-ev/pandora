class TestSourceOffensive < Indexing::SourceSuper
  def records
    @node_name = 'row'
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def path
    record.at_xpath('.//path/text()')
  end

  def artist
    record.xpath('.//artist/text()')
  end

  def title
    record.xpath('.//title/text()')
  end

  def description
    record.xpath('.//location/text()')
  end
end
