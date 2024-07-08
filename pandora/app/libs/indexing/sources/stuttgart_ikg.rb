class Indexing::Sources::StuttgartIkg < Indexing::SourceSuper
  def records
    document.xpath('//Bild')
  end

  def record_id
    record.xpath('.//ID/text()')
  end

  def path
    "#{record.at_xpath('.//Datei/text()')}".sub(/https:\/\/plib.ub.uni-stuttgart.de\/eas\/partitions\//, '')
  end

  def s_location
    [record.xpath('.//Standort/text()'), record.xpath('.//Herstellungsort/text()')]
  end

  # künstler
  def artist
    record.xpath('.//KünstlerIn/text()')
  end

  def artist_normalized
    an = record.xpath('.//KünstlerIn/text()').map {|a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    "#{record.xpath('.//Titel/text()')}, #{record.xpath('.//Teilbereich/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # datierung
  def date
    if record.xpath('.//Datierung/text()')
      record.xpath('.//Datierung/text()')
    else
      record.xpath('.//Beschr._Datierung/text()')
    end
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  def epoch
    record.xpath('.//Epoche/text()')
  end

  # standort
  def location
    record.xpath('.//Standort/text()')
  end

  # Herstellungsort
  def manufacture_place
    record.xpath('.//Herstellungsort/text()')
  end

  def discoveryplace
    record.xpath('.//Fundort/text()')
  end

  # technik
  def technique
    record.xpath('.//Technik/text()')
  end

  # Gattung
  def genre
    record.xpath('.//Gattung/text()')
  end

  # Masse
  def size
    record.xpath('.//Maße/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//Abbildungsnachweis/text()')
  end

  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  # Bildvorlage
  def pattern
    record.xpath('.//Darstellungsform/text()')
  end

  def keyword
    record.xpath('.//Schlagworte/text()')
  end

  def comment
    record.xpath('.//Kommentar/text()')
  end

  def topic
    "#{record.xpath('.//Themenkomplex/text()')}, #{record.xpath('.//Thema/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end
end
