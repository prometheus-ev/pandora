class Pandora::Indexing::Parser::AmtubRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//inventar_nr')
  end

  def path
    "#{record.at_xpath('.//inventar_nr/text()')}.jpg"
  end

  def artist
    ["#{record.xpath('.//verfasser/text()')} (#{record.xpath('.//funktion_verfasser/text()')})".gsub(/ \(\)/, "")]
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    @artist_normalized = @artist_parser.normalize(record.xpath('.//verfasser/text()'))
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  def date
    "#{record.xpath('.//objektdatierung/text()')} (Projekt: #{record.xpath('.//projektdatierung/text()')})".gsub(/ \(Projekt: \)/, "")
  end

  def date_range
    return @date_range if @date_range

    objektdatierung = record.xpath('.//objektdatierung/text()').to_s
    projektdatierung = record.xpath('.//projektdatierung/text()').to_s
    date = ''

    if !objektdatierung.blank?
      date = objektdatierung
    end

    if date.blank? && !projektdatierung.blank?
      date = projektdatierung
    end

    if date == '31.02.1902'
      date = '28.02.1902'
    elsif date == '1841-18429'
      date = '1841-1842'
    end

    @date_range = @date_parser.date_range(date)
  end

  # standort
  def location
    record.xpath('.//ort/text()')
  end

  # institution
  def institution
    record.xpath('.//institution/text()')
  end

  # material
  def material
    record.xpath('.//material_technik/text()')
  end

  # groesse
  def size
    record.xpath('.//masse/text()')
  end

  # schlagworte
  def keyword
    record.xpath('.//schlagworte/text()')
  end

  # Gattung
  def genre
    "Architektur"
  end

  # abbildungsnachweis
  def credits
    "zu erfragen beim Architekturmuseum der Technischen Universität Berlin in der Universitätsbibliothek"
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//institution/text()')
  end

  # Datensatz in Quelldatenbank
  def source_url
    "#{record.xpath('.//url_sammlung/text()')}".gsub(/http:\/\/130.149.103.245\/offen\/sammlung\/datensatz.php/, 'http://architekturmuseum.ub.tu-berlin.de/index.php')
  end
end
