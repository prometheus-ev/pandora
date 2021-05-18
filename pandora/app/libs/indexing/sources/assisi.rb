class Indexing::Sources::Assisi < Indexing::SourceSuper
  def records
    document.xpath('//dokument')
  end

  def record_id
    record.xpath('.//bildnr/text()')
  end

  def path
    record.at_xpath('.//bildnr/text()')
  end

  def s_title
    [record.xpath('.//bildtitel/text()'), record.xpath('.//untertitel/text()')]
  end

  def s_location
    [record.xpath('.//ort1/text()'), record.xpath('.//ort2/text()'), record.xpath('.//ort3/text()'), record.xpath('.//Aufbewahrungsort/text()')]
  end

  # künstler
  def artist
    ["#{record.xpath('.//Kuenstler/text()')}".gsub(/\Anull\z/, "").gsub(/ .\)/, "")]
  end

  # titel
  def title
    "#{record.xpath('.//bildtitel/text()')}".gsub(/\Anull\z/, '')
  end

  # untertitel
  def subtitle
    "#{record.xpath('.//untertitel/text()')}".gsub(/\Anull\z/, '')
  end

  # standort
  def location
    ("#{record.xpath('.//ort1/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//ort2/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//ort3/text()')}").gsub(/, \z/, '')
  end

  # datierung
  def date
    "#{record.xpath('.//Datierung/text()')}".gsub(/\Anull\z/, '')
  end

  # material
  def material
    "#{record.xpath('.//Farbe/text()')}".gsub(/\Anull\z/, '')
  end

  # gattung
  def genre
    "#{record.xpath('.//Technik/text()')}".gsub(/\Anull\z/, '')
  end

  # schlagwoerter
  def keyword
    "#{record.xpath('.//Suchworte/text()')}".gsub(/\Anull\z/, '')
  end

  # abbildungsnachweis
  def credits
    "#{record.xpath('.//Abildungsnachweis/text()')}".gsub(/\Anull\z/, '')
  end

  # bildrecht
  def rights_reproduction
    "#{record.xpath('.//copyright/text()')}".gsub(/\Anull\z/, '')
  end

  # aufbewahrungsort des negativs
  def depository
    "#{record.xpath('.//Aufbewahrungsort/text()')}".gsub(/\Anull\z/, '')
  end
end
