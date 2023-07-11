class TestSourceMultiWordSynonymsRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//id/text()')
  end

  def record_object_id
    [name, Digest::SHA1.hexdigest(record.xpath('.//object-id/text()').to_a.join('|'))].join('-')
  end

  def path
    record.at_xpath('.//path/text()')
  end

  def artist
    record.xpath('.//artist/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    @artist_normalized = @artist_parser.normalize(artist)
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
