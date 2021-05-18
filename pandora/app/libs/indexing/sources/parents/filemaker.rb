class Indexing::Sources::Parents::Filemaker < Indexing::SourceSuper
  def records
    document.xpath('//datensatz')
  end

  def record_id
    record.xpath('.//gdest1/text()')
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      "#{record.at_xpath('.//gdest1/text()')}.jpg"
    end
  end

  def s_location
    record.xpath('.//ort/text()') + record.xpath('.//aufbewahrungsort/text()')
  end

  # künstler
  def artist
    ["#{record.xpath('.//vorname/text()')} #{record.xpath('.//nachname/text()')}"]
  end

  # titel
  def title
    "#{record.xpath('.//titel_original/text()')} (#{record.xpath('.//titel_uebersetzung/text()')})".gsub(/ \(\s*\)/, "")
  end

  # datierung
  def date
    "#{record.xpath('.//datierungsvermerk/text()')}"
  end

  # standort
  def location
    record.xpath('.//ort/text()')
  end

  # aufbewahrungsort
  def depository
    record.xpath('.//aufbewahrungsort/text()')
  end

  # gattung
  def genre
    record.xpath('.//medium/text()')
  end

  # technik
  def technique
    record.xpath('.//technik/text()')
  end

  # masse (Breite, Höhe, Tiefe)
  def size
    width = record.xpath('.//breite/text()').to_s.strip.gsub(/\Acm/, "")
    height = record.xpath('.//hoehe/text()').to_s.strip.gsub(/\Acm/, "")
    depth = record.xpath('.//tiefe/text()').to_s.strip.gsub(/\Acm/, "")
    size = width
    size << " (w)" unless width.blank?
    size << " x " unless height.blank?
    size << height
    size << " (h)" unless height.blank?
    size << " x " unless depth.blank?
    size << depth
    size << " (d)" unless depth.blank?
    size
  end

  # schlagwörter
  def keyword
    record.xpath('.//schlagwoerter/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//abbildungsnachweis/text()')
  end
end
