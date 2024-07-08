class Pandora::Indexing::Parser::DigidianeuRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./bildreferenz/text()')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    record.xpath('./bildreferenz/text()')
  end

  def artist
    record.xpath('./kuenstlerin/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('./kuenstlerin/text()').map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('./titel/text()')
  end

  def location
    record.xpath('./standort/text()')
  end

  def date
    record.xpath('./datierung/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def material
    record.xpath('./material/text()')
  end

  def genre
    record.xpath('./gattung/text()')
  end

  def credits
    record.xpath('./abbildungsnachweis/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end
end
