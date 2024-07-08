class Pandora::Indexing::Parser::GenfRecord < Pandora::Indexing::Parser::Record
  def record_id
    @record_id ||= record.xpath('./HA_FICHES_ID/text()')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "HISBinObjH_P?ID1=#{record.xpath('./HA_FICHES_ID/text()')}"
  end

  def artist
    record.xpath('./HA_AUTEUR_NOM/text()').map {|artist|
      HTMLEntities.new.decode(artist).split("; ")
    }.flatten
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = artist.map {|a|
      a.sub(/ \(.*/, '').strip.gsub(/Ä/, 'ä').gsub(/Ö/, 'ö').gsub(/Ü/, 'ü').split(', ').reverse.join(" ")
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('./DESCRIPTION/text()')
  end

  def date
    record.xpath('./DATATION/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    if d == '1150 - 11660'
      d = '1150 - 1160'
    elsif d == '1836 -18463'
      d = '1836 -1846'
    end

    d.chomp!('.')

    @date_range = @date_parser.date_range(d)
  end

  def size
    record.xpath('./FORMAT/text()')
  end

  def location
    record.xpath('./HA_LOCALISATIONS/HA_LOCALISATIONS_ROW/LOCALISATION/text()')
  end

  def credits
    record.xpath('./SOURCE/text()')
  end
end
