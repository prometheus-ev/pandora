class Indexing::Sources::Caerlangen < Indexing::Sources::Parents::Erlangen
  def s_location
    [record.xpath('.//Standort/text()'), record.xpath('.//Fundort/text()'), record.xpath('.//Land/text()')]
  end

  def s_unspecified
    [record.xpath('.//Ikonographie/text()'), record.xpath('.//Kommentar/text()')]
  end

  def artist_normalized
    super.map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
  end

  # Herkunft
  def origin
    record.xpath('.//Provenienz/text()')
  end

  # standort
  def location
    "#{record.xpath('.//Land/text()')}, #{record.xpath('.//Standort/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # Fundort
  def discoveryplace
    record.xpath('.//Fundort/text()')
  end

  def iconography
    record.xpath('.//Ikonographie/text()')
  end

  # Bildnachweis
  def credits
    ("#{record.xpath('.//Buchautor/text()')}: ".gsub(/\A: /, '') +
     "#{record.xpath('.//Titel/text()')}, ".gsub(/\A, /, '') +
     "#{record.xpath('.//Jahr/text()')}. ".gsub(/\A\. /, '') +
     "#{record.xpath('.//Verweis/text()')}.".gsub(/\A\. /, '')).gsub(/: \z/, '').gsub(/, \z/, '').gsub(/^: /, '')
  end

  # bildrecht
  def rights_reproduction
    "#{record.xpath('.//Fotograf/text()')} (#{record.xpath('.//Jahr_Foto/text()')})".gsub(/ \(\)/, '').gsub(/\( \)/)
  end
end
