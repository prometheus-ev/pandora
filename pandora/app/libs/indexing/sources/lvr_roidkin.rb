class Indexing::Sources::LvrRoidkin < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//Bildidentifikationsvermerk/text()')
  end

  def path
    record.at_xpath('.//Bildidentifikationsvermerk/text()')
  end

  # künstler
  def artist
    record.xpath('.//KuenstlerIn/text()')
  end

  def artist_normalized
    super(artist)
  end

  # titel
  def title
    record.xpath('.//Titel/text()')
  end

  # standort
  def location
    record.xpath('.//Standort/text()')
  end

  # datierung
  def date
    record.xpath('.//Datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # bildnachweis
  def credits
    record.xpath('.//Bildnachweis/text()')
  end

  def size
    "#{record.xpath('.//Masse/text()')} cm"
  end

  def material
    record.xpath('.//Material/text()')
  end

  def genre
    record.xpath('.//Gattung/text()')
  end

  def description
    record.xpath('.//Beschreibung/text()')
  end

  def provenance
    record.xpath('.//Herkunft_Provenienz/text()')
  end

  def rights_reproduction
    record.xpath('.//Bildrecht/text()')
  end
end
