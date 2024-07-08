class Pandora::Indexing::Parser::AssisiRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//bildnr/text()')
  end

  def path
    record.at_xpath('.//bildnr/text()')
  end

  def artist
    ["#{record.xpath('.//Kuenstler/text()')}".gsub(/\Anull\z/, "").gsub(/ .\)/, "")]
  end

  def title
    "#{record.xpath('.//bildtitel/text()')}".gsub(/\Anull\z/, '')
  end

  def subtitle
    "#{record.xpath('.//untertitel/text()')}".gsub(/\Anull\z/, '')
  end

  def location
    ("#{record.xpath('.//ort1/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//ort2/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//ort3/text()')}").gsub(/, \z/, '')
  end

  def date
    "#{record.xpath('.//Datierung/text()')}".gsub(/\Anull\z/, '')
  end

  def date_range
    @date_parser.date_range(date)
  end

  def material
    "#{record.xpath('.//Farbe/text()')}".gsub(/\Anull\z/, '')
  end

  def genre
    "#{record.xpath('.//Technik/text()')}".gsub(/\Anull\z/, '')
  end

  def keyword
    "#{record.xpath('.//Suchworte/text()')}".gsub(/\Anull\z/, '')
  end

  def credits
    "#{record.xpath('.//Abildungsnachweis/text()')}".gsub(/\Anull\z/, '')
  end

  def rights_reproduction
    "#{record.xpath('.//copyright/text()')}".gsub(/\Anull\z/, '')
  end

  # Aufbewahrungsort des Negativs
  def depository
    "#{record.xpath('.//Aufbewahrungsort/text()')}".gsub(/\Anull\z/, '')
  end
end
