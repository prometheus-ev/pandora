class TestSourcePkndArtistAttributions < Indexing::SourceSuper
  def records
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

  def artist_normalized
    super(artist)
  end

  def title
    record.xpath('.//title/text()')
  end

  def location
    record.xpath('.//location/text()')
  end
end
