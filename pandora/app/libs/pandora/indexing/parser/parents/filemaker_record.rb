class Pandora::Indexing::Parser::Parents::FilemakerRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('./gdest1/text()')
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "#{record.at_xpath('./gdest1/text()')}.jpg"
  end

  def artist
    ["#{record.xpath('./vorname/text()')} #{record.xpath('./nachname/text()')}"]
  end

  def title
    "#{record.xpath('./titel_original/text()')} " \
    "(#{record.xpath('./titel_uebersetzung/text()')})".
      gsub(/ \(\s*\)/, "")
  end

  def date
    "#{record.xpath('./datierungsvermerk/text()')}"
  end

  def date_range
    return @date_range if @date_range

    d = date.strip.encode('iso-8859-1').encode('utf-8')

    @date_range = @date_parser.date_range(d)
  end

  def location
    record.xpath('./ort/text()')
  end

  def depository
    record.xpath('./aufbewahrungsort/text()')
  end

  def genre
    record.xpath('./medium/text()')
  end

  def technique
    record.xpath('./technik/text()')
  end

  # Breite, Höhe, Tiefe
  def size
    width = record.xpath('./breite/text()').to_s.strip.gsub(/\Acm/, "")
    height = record.xpath('./hoehe/text()').to_s.strip.gsub(/\Acm/, "")
    depth = record.xpath('./tiefe/text()').to_s.strip.gsub(/\Acm/, "")
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

  def keyword
    record.xpath('./schlagwoerter/text()')
  end

  def credits
    record.xpath('./abbildungsnachweis/text()')
  end
end
