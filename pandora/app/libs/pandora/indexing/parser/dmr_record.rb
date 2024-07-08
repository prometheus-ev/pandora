class Pandora::Indexing::Parser::DmrRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./bildnummer/text()')
  end

  def path
    record.at_xpath('./bildnummer/text()')
  end

  def artist
    record.xpath('./kuenstler/text()')
  end

  def title
    record.xpath('./kurzbezeichnung/text()')
  end

  def inscription
    record.xpath('./inschrift/text()')
  end

  def date
    "#{record.xpath('./datierung_von/text()')} - " \
    "#{record.xpath('./datierung_bis/text()')} " \
    "(#{record.xpath('./bemerkg_datierung/text()')})".
      gsub(/0* - 0* /, '').
      gsub(/\([0\-]*\)/, "")
  end

  def date_range
    return @date_range if @date_range

    d = "#{record.xpath('./datierung_von/text()')} - " \
        "#{record.xpath('./datierung_bis/text()')}"
    d = d.strip.encode('iso-8859-1').encode('utf-8')

    @date_range = @date_parser.date_range(d)
  end

  def location
    record.xpath('./standort/text()')
  end

  def size
    record.xpath('./masse/text()')
  end

  def material
    record.xpath('./material/text()')
  end

  def technique
    record.xpath('./technik/text()')
  end

  def genre
    record.xpath('./gattung/text()')
  end

  def origin_point
    record.xpath('./entstehungsort/text()')
  end

  def literature
    record.xpath('./literatur/text()')
  end

  def description
    record.xpath('./beschreibung/text()')
  end

  def keyword
    record.xpath('./ikonog_Stichwort/text()')
  end

  def rights_reproduction
    'zu erfragen beim Diözesanmuseum, Regensburg'
  end
end
