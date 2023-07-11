class Indexing::Sources::EssenKuwi < Indexing::SourceSuper
  def records
    document.xpath('//Werk')
  end

  def record_id
    record.xpath('.//Werkdaten/Identifikationsvermerk/text()')
  end

  def path
    "#{record.xpath('.//Bilder/Bild/text()')}".gsub(/http:\/\/pixx.kunst-design.uni-due.de\//, '')
  end

  # künstler
  def artist
    record.xpath('.//Zusatzinformationen/Kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//Zusatzinformationen/Kuenstler/text()').map{ |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//Werkdaten/Titel/text()')
  end

  # datierung
  def date
    if !(datierungvon = record.xpath('.//Zusatzinformationen/Datierungvon/text()')).blank?
    "#{datierungvon} - #{record.xpath('.//Zusatzinformationen/Datierungbis/text()')} (#{record.xpath('.//Zusatzinformationen/Datierung/text()')})".gsub(/\(\)/, '')
    else
      record.xpath('.//Zusatzinformationen/Datierung/text()')
    end
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # groesse
  def size
    record.xpath('.//Zusatzinformationen/Groesse/text()')
  end

  # standort
  def location
    "#{record.xpath('.//Zusatzinformationen/Standort/text()')}, #{record.xpath('.//Zusatzinformationen/Standort/text()')}".gsub(/\A ,/, '').gsub(/, \z/,'')
  end

  # gattung
  def genre
    record.xpath('.//Zusatzinformationen/Gattung/text()')
  end

  # material
  def material
    record.xpath('.//Zusatzinformationen/Material/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//Werkdaten/Abbildungsnachweis/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
  
  def rights_reproduction
     record.xpath('.//Werkdaten/Urheberrechtsvermerk/text()')
  end

end
