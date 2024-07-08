class Pandora::Indexing::Parser::BeeskowKunstarchivRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//Ob_f41/text()')
  end

  def path
    "#{record.xpath('.//Ob_f41/text()')}.jpg"
  end

  def artist
    record.xpath('.//KünstlerIn/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('.//KünstlerIn/text()').map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('.//Titel/text()')
  end

  def date
    record.xpath('.//Datierung/text()')
  end

  def date_range
    return @date_range if @date_range

    date = record.xpath('.//Datierung/text()').to_s
    date.encode!('iso-8859-1').encode!('utf-8')

    if date == '1976*'
      date = '1976'
    elsif date.start_with?('o. J.')
      date = ''
    end

    @date_range = @date_parser.date_range(date)
  end

  def location
    record.xpath('.//Standort/text()')
  end

  def genre
    record.xpath('.//Gattung/text()')
  end

  def size
    "#{record.xpath('.//Höhe/text()')} x #{record.xpath('.//Breite/text()')} #{record.xpath('.//Einheit/text()')}"
  end

  def credits
    record.xpath('.//Standort/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    "zu erfragen bei #{record.xpath('.//Standort/text()')}"
  end
end
