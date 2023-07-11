class Indexing::Sources::Gregorsmesse < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//pro_bildreferenz/text()')
  end

  def path
    record.at_xpath('.//pro_bildreferenz/text()')
  end

  def _fix_dump!(d, f)
    iconv = Iconv.new('latin1', 'utf8')
    d.each { |l| f.puts iconv.iconv(l) }
  end

  def s_credits
    [record.xpath('.//pro_abbildungsnachweis/text()'), record.xpath('.//Sign__Copyright/text()')]
  end

  # künstler
  def artist
    (record.xpath('.//pro_person_1/text()') + record.xpath('.//pro_person_2/text()') + record.xpath('.//pro_person_3/text()')).map { |a|
      a.to_s.strip.gsub(/\A,\z/, "")
    }
  end

  # titel
  def title
    record.xpath('.//pro_titel/text()')
  end

  # datierung
  def date
    record.xpath('.//pro_datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # standort
  def location
    record.xpath('.//pro_standort/text()')
  end

  # material
  def material
    record.xpath('.//pro_material/text()')
  end

  # maße
  def size
    record.xpath('.//pro_masse/text()')
  end

  # gattung
  def genre
    record.xpath('.//pro_gattung/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//pro_abbildungsnachweis/text()')
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//Sign__Copyright/text()')
  end

  # literatur
  def literature
    record.xpath('.//pro_literatur/text()')
  end

  # beschreibung
  def description
    record.xpath('.//pro_beschreibung/text()')
  end
end
