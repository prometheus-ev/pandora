class Indexing::Sources::Desanhalt < Indexing::SourceSuper
  def records
    document.xpath('//Werk')
  end

  def record_id
    record.xpath('@abbild_id')
  end

  def path
    "#{record.xpath('.//Grosz/text()')}".sub(/http:\/\/db4.design.hs-anhalt.de/, '').delete("\n").sub(/^(\/*)/,'')
  end

  def s_artist
    [record.xpath('.//KuenstlerIn/text()'), record.xpath('.//Person/KuenstlerIn/text()')]
  end

  def s_location
    [record.xpath('.//Ort/Standort/text()'), record.xpath('.//Ort/Entstehungsort/text()'), record.xpath('.//Ort/Herstellungsort/text()'), record.xpath('.//Ort/Firmensitz/text()'), record.xpath('.//Ort/Herkunftsort/text()'), record.xpath('.//Ort/Entwurf/text()'), record.xpath('.//Ort/Herstellung/text()'), record.xpath('.//Ort/Produktion/text()'), record.xpath('.//Ort/AuftraggeberIn/text()'), record.xpath('.//Ort/Ausfuehrung/text()'), record.xpath('.//Ort/EigentuemerIn/text()'), record.xpath('.//Ort/Abbildungsbesitzer/text()'), record.xpath('.//Ort/Studienort/text()'), record.xpath('.//Ort/Veranstaltungsort/text()')]
  end

  def s_unspecified
    [record.xpath('.//Person/Entwurf/text()'), record.xpath('.//Person/Herstellung/text()'), record.xpath('.//Person/Ausfuehrung/text()'), record.xpath('.//Person/Produktion/text()'), record.xpath('.//Person/AuftraggeberIn/text()'), record.xpath('.//Person/Entstehungsort/text()'), record.xpath('.//Person/FotografIn/text()'), record.xpath('.//Person/HerausgeberIn/text()'), record.xpath('.//Person/Standort/text()'), record.xpath('.//Person/Herkunftsort/text()'), record.xpath('.//Person/Vertrieb/text()'), record.xpath('.//Person/Abbildungsbesitzer/text()'), record.xpath('.//Person/GruenderIn/text()'), record.xpath('.//Person/EigentuemerIn/text()'), record.xpath('.//Person/LeiterIn/text()'), record.xpath('.//Person/Gestaltung/text()'), record.xpath('.//Person/RechteinhaberIn/text()'), record.xpath('.//Person/Ausfuehrung_beteiligt/text()'), record.xpath('.//Person/Mitglied/text()'), record.xpath('.//Person/Objektbesitzer/text()'), record.xpath('.//Person/AutorIn/text()'), record.xpath('.//Person/Entwurf_beteiligt/text()'), record.xpath('.//Institution/Produktion/text()'), record.xpath('.//Institution/Herstellung/text()'), record.xpath('.//Institution/AuftraggeberIn/text()'), record.xpath('.//Institution/Entwurf/text()'), record.xpath('.//Institution/Ausfuehrung/text()'), record.xpath('.//Institution/Entstehungsort/text()'), record.xpath('.//Institution/standort/text()'), record.xpath('.//Institution/vertrieb/text()'), record.xpath('.//Institution/HerausgeberIn/text()'), record.xpath('.//Institution/Herstellungsort/text()'), record.xpath('.//Institution/Herkunftsort/text()'), record.xpath('.//Institution/Firmensitz/text()'), record.xpath('.//Institution/FotografIn/text()'), record.xpath('.//Institution/GruenderIn/text()'), record.xpath('.//Institution/Abbildungsbesitzer/text()'), record.xpath('.//Institution/EigentuemerIn/text()'), record.xpath('.//Institution/RechteinhaberIn/text()'), record.xpath('.//Institution/Gestaltung/text()'), record.xpath('.//Institution/Ausfuehrung_beteiligt/text()'), record.xpath('.//Institution/KuenstlerIn/text()'), record.xpath('.//Institution/MitbegruenderIn/text()'), record.xpath('.//Institution/Objektbesitzer/text()'), record.xpath('.//Institution/Mitentwicklung/text()'), record.xpath('.//Institution/veranstaltungsort/text()'), record.xpath('.//Institution/Funktion/text()')]
  end

  # künstler
  def artist
    record.xpath('.//KuenstlerIn/text()').map { |a|
      a.to_s.strip.gsub(/\A,\z/, "")
    }
  end

  def artist_normalized
    an = record.xpath('.//KuenstlerIn/text()').map { |a|
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
    "#{record.xpath('.//Datierung/von/text()')} - #{record.xpath('.//Datierung/bis/text()')} (#{record.xpath('.//Datierung/Text/text()')})".gsub(/0* - 0* /, '').gsub(/\([0\-]*\)/, "")
  end

  # standort
  def location
    record.xpath('.//Ort/Standort/text()')
  end

  # entstehungsort
  def origin_point
    record.xpath('.//Ort/Entstehungsort/text()')
  end

  # herstellungsort
  def manufacture_place
    "#{record.xpath('.//Ort/Herstellungsort/text()')}, #{record.xpath('.//Ort/Herstellung/text()')}; ".gsub(/\A, /, '').gsub(/\A; /, '').gsub(/, \z/, '; ') +
    "#{record.xpath('.//Institution/Herstellungsort/text()')}, #{record.xpath('.//Institution/Herstellung/text()')};".gsub(/\A, /, '').gsub(/\A; /, '').gsub(/, \z/, '; ').gsub(/\A;\z/, "")
  end

  # material
  def material
    record.xpath('.//Material/text()')
  end

  # beschreibung
  def description
    record.xpath('.//Beschreibung/text()')
  end

  # schlagwort
  def keyword
    record.xpath('.//Schlagwort/KlEnt/text()')
  end

  # maße (HxBxT)
  def size
    "#{record.xpath('.//Masze/Hoehe/text()')} x #{record.xpath('.//Masze/Breite/text()')} x #{record.xpath('.//Masze/Tiefe/text()')}".gsub(/0* x 0* x 0*/, '')
  end

  # gattung
  def genre
    record.xpath('.//Gattung/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//Bildnachweis/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//Abbildungsnachweis/text()')
  end
end
