class Indexing::Sources::Dmr < Indexing::SourceSuper
  def records
    document.xpath('//entry')
  end

  def record_id
    record.xpath('.//bildnummer/text()')
  end

  def path
    record.at_xpath('.//bildnummer/text()')
  end

  def s_unspecified
    [record.xpath('.//entstehungsort/text()'), record.xpath('.//technik/text()'), record.xpath('.//inschrift/text()')]
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  # titel
  def title
    record.xpath('.//kurzbezeichnung/text()')
  end

  # Inschrift
  def inscription
    record.xpath('.//inschrift/text()')
  end

  # datierung
  def date
    "#{record.xpath('.//datierung_von/text()')} - #{record.xpath('.//datierung_bis/text()')} (#{record.xpath('.//bemerkg_datierung/text()')})".gsub(/0* - 0* /, '').gsub(/\([0\-]*\)/, "")
  end

  def date_range
    d = "#{record.xpath('.//datierung_von/text()')} - #{record.xpath('.//datierung_bis/text()')}"
    d = d.strip.encode('iso-8859-1').encode('utf-8')

    super(d)
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # abmessungen
  def size
    record.xpath('.//masse/text()')
  end

  # material
  def material
    record.xpath('.//material/text()')
  end

  # technik
  def technique
    record.xpath('.//technik/text()')
  end

  # gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  # entstehungsort
  def origin_point
    record.xpath('.//entstehungsort/text()')
  end

  # literatur
  def literature
    record.xpath('.//literatur/text()')
  end

  # beschreibung
  def description
    record.xpath('.//beschreibung/text()')
  end

  # Ikonog. Stichwort
  def keyword
    record.xpath('.//ikonog_Stichwort/text()')
  end

  # copyright
  def rights_reproduction
    'zu erfragen beim Diözesanmuseum, Regensburg'
  end
end
