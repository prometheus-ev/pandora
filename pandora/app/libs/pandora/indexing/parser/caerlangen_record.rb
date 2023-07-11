class Pandora::Indexing::Parser::CaerlangenRecord < Pandora::Indexing::Parser::Parents::ErlangenRecord
  def s_location
    [record.xpath('.//Standort/text()'), record.xpath('.//Fundort/text()'), record.xpath('.//Land/text()')]
  end

  def s_unspecified
    [record.xpath('.//Ikonographie/text()'), record.xpath('.//Kommentar/text()')]
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = artist.map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def origin
    record.xpath('.//Provenienz/text()')
  end

  def location
    "#{record.xpath('.//Land/text()')}, #{record.xpath('.//Standort/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def discoveryplace
    record.xpath('.//Fundort/text()')
  end

  def iconography
    record.xpath('.//Ikonographie/text()')
  end

  def credits
    ("#{record.xpath('.//Buchautor/text()')}: ".gsub(/\A: /, '') +
     "#{record.xpath('.//Titel/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//Jahr/text()')}. ".gsub(/\A\. /, '') +
     "#{record.xpath('.//Verweis/text()')}.".gsub(/\A\. /, '')).gsub(/: \z/, '').gsub(/, \z/, '').gsub(/^: /, '')
  end

  def rights_reproduction
    "#{record.xpath('.//Fotograf/text()')} (#{record.xpath('.//Jahr_Foto/text()')})".strip.gsub(/ \(\)/, '').delete("\n").delete("()")
  end
end
