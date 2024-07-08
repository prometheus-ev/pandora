class Pandora::Indexing::Parser::GregorsmesseRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./pro_bildreferenz/text()')
  end

  def path
    record.at_xpath('./pro_bildreferenz/text()')
  end

  def artist
    (record.xpath('./pro_person_1/text()') + record.xpath('./pro_person_2/text()') + record.xpath('./pro_person_3/text()')).map {|a|
      a.to_s.strip.gsub(/\A,\z/, "")
    }
  end

  def title
    record.xpath('./pro_titel/text()')
  end

  def date
    record.xpath('./pro_datierung/text()')
  end

  def date_range
    return @date_range if @date_range

    d = date.to_s.strip

    @date_range = @date_parser.date_range(d)
  end

  def location
    record.xpath('./pro_standort/text()')
  end

  def material
    record.xpath('./pro_material/text()')
  end

  def size
    record.xpath('./pro_masse/text()')
  end

  def genre
    record.xpath('./pro_gattung/text()')
  end

  def credits
    record.xpath('./pro_abbildungsnachweis/text()')
  end

  def rights_reproduction
    record.xpath('./Sign__Copyright/text()')
  end

  def literature
    record.xpath('./pro_literatur/text()')
  end

  def description
    record.xpath('./pro_beschreibung/text()')
  end
end
