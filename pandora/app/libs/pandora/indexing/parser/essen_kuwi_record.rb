class Pandora::Indexing::Parser::EssenKuwiRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./Werkdaten/Identifikationsvermerk/text()')
  end

  def path
    "#{record.xpath('./Bilder/Bild/text()')}".gsub(/http:\/\/pixx.kunst-design.uni-due.de\//, '')
  end

  def artist
    record.xpath('./Zusatzinformationen/Kuenstler/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('./Zusatzinformationen/Kuenstler/text()').map{|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('./Werkdaten/Titel/text()')
  end

  def date
    if !(datierungvon = record.xpath('./Zusatzinformationen/Datierungvon/text()')).blank?
      "#{datierungvon} - #{record.xpath('./Zusatzinformationen/Datierungbis/text()')} (#{record.xpath('./Zusatzinformationen/Datierung/text()')})".gsub(/\(\)/, '')
    else
      record.xpath('./Zusatzinformationen/Datierung/text()')
    end
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def size
    record.xpath('./Zusatzinformationen/Groesse/text()')
  end

  def location
    "#{record.xpath('./Zusatzinformationen/Standort/text()')}, #{record.xpath('./Zusatzinformationen/Standort/text()')}".gsub(/\A ,/, '').gsub(/, \z/, '')
  end

  def genre
    record.xpath('./Zusatzinformationen/Gattung/text()')
  end

  def material
    record.xpath('./Zusatzinformationen/Material/text()')
  end

  def credits
    record.xpath('./Werkdaten/Abbildungsnachweis/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('./Werkdaten/Urheberrechtsvermerk/text()')
  end
end
