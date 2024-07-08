class Pandora::Indexing::Parser::DesanhaltRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('@abbild_id')
  end

  def path
    "#{record.xpath('./Grosz/text()')}".
      sub(/http:\/\/db4.design.hs-anhalt.de/, '').
      delete("\n").
      sub(/^(\/*)/, '')
  end

  def artist
    record.xpath('./KuenstlerIn/text()').map {|a|
      a.to_s.strip.gsub(/\A,\z/, "")
    }
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('./KuenstlerIn/text()').map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('./Titel/text()')
  end

  def date
    "#{record.xpath('./Datierung/von/text()')} - " \
    "#{record.xpath('./Datierung/bis/text()')} " \
    "(#{record.xpath('./Datierung/Text/text()')})".
      gsub(/0* - 0* /, "").
      gsub(/\([0\-]*\)/, "")
  end

  def date_range
    return @date_range if @date_range

    @date_range = @date_parser.date_range(date)
  end

  def location
    record.xpath('./Ort/Standort/text()')
  end

  def origin_point
    record.xpath('./Ort/Entstehungsort/text()')
  end

  def manufacture_place
    "#{record.xpath('./Ort/Herstellungsort/text()')}, " \
    "#{record.xpath('./Ort/Herstellung/text()')}; ".
      gsub(/\A, /, '').
      gsub(/\A; /, '').
      gsub(/, \z/, '; ') +
    "#{record.xpath('./Institution/Herstellungsort/text()')}, " \
    "#{record.xpath('./Institution/Herstellung/text()')};".
      gsub(/\A, /, '').
      gsub(/\A; /, '').
      gsub(/, \z/, '; ').
      gsub(/\A;\z/, "")
  end

  def material
    record.xpath('./Material/text()')
  end

  def description
    record.xpath('./Beschreibung/text()')
  end

  def keyword
    record.xpath('./Schlagwort/KlEnt/text()')
  end

  # HxBxT
  def size
    "#{record.xpath('./Masze/Hoehe/text()')} x " \
    "#{record.xpath('./Masze/Breite/text()')} x " \
    "#{record.xpath('./Masze/Tiefe/text()')}".
      gsub(/0* x 0* x 0*/, '')
  end

  def genre
    record.xpath('./Gattung/text()')
  end

  def credits
    record.xpath('./Bildnachweis/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('./Abbildungsnachweis/text()')
  end
end
