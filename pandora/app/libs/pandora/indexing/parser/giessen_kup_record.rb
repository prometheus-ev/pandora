class Pandora::Indexing::Parser::GiessenKupRecord < Pandora::Indexing::Parser::Parents::FilemakerRecord
  def artist
    record.xpath('./nachname/text()').map {|artist|
      artist.to_s.split(" / ")
    }.flatten
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = artist.map {|a|
      a.gsub(/ \(.*/, '')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end
end
