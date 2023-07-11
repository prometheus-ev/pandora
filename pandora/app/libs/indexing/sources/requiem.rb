class Indexing::Sources::Requiem < Indexing::SourceSuper
  def records
    document.xpath('//pict')
  end

  def record_id
    record.xpath('.//pictID/text()')
  end

  def path
    "#{record.at_xpath('.//Bildidentifikationsvermerk/text()')}".gsub(/http:\/\/www2.hu-berlin.de\/requiem\/images\//, '')
  end

  def s_credits
    [record.xpath('.//Abbildungsnachweis/text()'), record.xpath('.//Urheberrechtsvermerk/text()')]
  end

  # kuenstler
  def artist
    record.xpath('.//Kuenstler/text()')
  end

  # titel
  def title
    record.xpath('.//Titel/text()')
  end

  # standort
  def location
    record.xpath('.//Standort/text()')
  end

  def date
    "#{record.xpath('.//Datierung/text()')} - #{record.xpath('.//Datierung2/text()')}".gsub(/ - 0000-00-00/, '').gsub(/-00-00/, '').gsub(/0000/, '')
  end

  def date_range
    d = date.strip

    super(d)
  end

  # bildnachweis
  def credits
    record.xpath('.//Abbildungsnachweis/text()')
  end

  # copyright
  def rights_reproduction
    record.xpath('.//Urheberrechtsvermerk/text()')
  end

  # material
  def material
    record.xpath('.//Material/text()')
  end

  # gattung
  def genre
    record.xpath('.//Gattung/text()')
  end

  # herkunft
  def origin
    record.xpath('.//Herkunft/text()')
  end

  def description
    record.xpath('.//description/text()')
  end
end
