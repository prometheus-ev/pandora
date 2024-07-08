class Pandora::Indexing::Parser::HalleKgRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./column[@name="bildident"]/text()')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "#{record.at_xpath('./column[@name="name"]/text()')}"
  end

  def artist
    record.xpath('./column[@name="kuenstler"]/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = "#{record.xpath('.//column[@name="kuenstler"]/text()')}".split("; ").map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('./column[@name="titel"]/text()')
  end

  def addition
    record.xpath('./column[@name="zusatz"]/text()')
  end

  def location
    record.xpath('./column[@name="ort"]/text()')
  end

  def discoveryplace
    record.xpath('./column[@name="fundort"]/text()')
  end

  def date
    record.xpath('./column[@name="datierung"]/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    if d == 'vor 1585.'
      d = 'vor 1585'
    elsif d == '18568-69'
      d = '1868-69'
    elsif d == '1958.'
      d = '1958'
    elsif d == '1959.'
      d = '1959'
    end

    @date_range = @date_parser.date_range(d)
  end

  def credits
    record.xpath('./column[@name="quelle"]/text()')
  end

  def size
    record.xpath('./column[@name="format"]/text()')
  end

  def material
    record.xpath('./column[@name="material"]/text()')
  end

  def genre
    record.xpath('./column[@name="gattung"]/text()')
  end

  def annotation
    record.xpath('./column[@name="bemerkungen"]/text()')
  end

  def isbn
    record.xpath('./column[@name="isbn"]/text()')
  end

  def technique
    record.xpath('./column[@name="technik"]/text()')
  end
end
