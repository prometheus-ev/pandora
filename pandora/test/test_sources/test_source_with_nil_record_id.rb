class TestSourceWithNilRecordId < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    if record.at_xpath('.//id')
      record.at_xpath('.//id/text()')
    end
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

  def location
    record.xpath('.//location/text()')
  end

  def rights_work
    record.xpath('.//rights-work/text()')
  end
end
