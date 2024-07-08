class Pandora::Indexing::Parser::DresdenRecord < Pandora::Indexing::Parser::Record
  def record_id
    @record_id ||= record.xpath('./Dianummer/text()')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "#{record.at_xpath('./Dianummer/text()')}.jpg"
  end

  def title
    record.xpath('./Titel/text()')
  end

  def subtitle
    record.xpath('./Untertitel/text()')
  end

  def artist
    record.xpath('./Künstlername/text()') +
    record.xpath('./Architekt_Künstler/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = artist.map {|a|
      HTMLEntities.
        new.
        decode(a.
               to_s.
               sub(/ \(.*/, '').
               strip.
               split(', ').
               reverse.
               join(' ')).
        gsub(/Ö/, 'ö').
        gsub(/Ä/, 'ä').
        gsub(/Ü/, 'ü')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def date
    record.xpath('./Datierung/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    if d == '193419-36'
      d = '1934-36'
    elsif d == '1952-19253'
      d = '1952-1953'
    end

    @date_range = @date_parser.date_range(d)
  end

  def location
    locations = (record.xpath('./Ort/text()') + record.xpath('./Aufbewahrungsort/text()')).to_a
    locations.reject!{|location|
      location = location.to_s.strip
      location.blank?
    }
    locations.compact.join(', ')
  end

  def genre
    "#{record.xpath('./Katalog/text()')}, #{record.xpath('./Themenkategorie/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  def credits
    record.xpath('./Abbildungsnachweis/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('./Copyright/text()')
  end

  def catalogue
    record.xpath('./Katalog/text()')
  end
end
