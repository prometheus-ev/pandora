class Indexing::Sources::BeeskowKunstarchiv < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//Ob_f41/text()')
  end

  def path
    "#{record.xpath('.//Ob_f41/text()')}.jpg"
  end

  # künstler
  def artist
    record.xpath('.//KünstlerIn/text()')
  end

  def artist_normalized
    an = record.xpath('.//KünstlerIn/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//Titel/text()')
  end

  # datierung
  def date
    record.xpath('.//Datierung/text()')
  end

  def date_range
    date = record.xpath('.//Datierung/text()').to_s
    date.encode!('iso-8859-1').encode!('utf-8')

    if date == '1976*'
      date = '1976'
    elsif date.start_with?('o. J.')
      date = ''
    end

    super(date)
  end

  # standort
  def location
    record.xpath('.//Standort/text()')
  end

  # Gattung
  def genre
    record.xpath('.//Gattung/text()')
  end

  # Masse
  def size
    "#{record.xpath('.//Höhe/text()')} x #{record.xpath('.//Breite/text()')} #{record.xpath('.//Einheit/text()')}"
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//Standort/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # Anmerkung
  def rights_reproduction
    "zu erfragen bei #{record.xpath('.//Standort/text()')}"
  end
end
