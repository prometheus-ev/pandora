class Indexing::Sources::Amtub < Indexing::SourceSuper
  def records
    document.xpath('//datensatz')
  end

  def record_id
    record.xpath('.//inventar_nr')
  end

  def path
    "#{record.at_xpath('.//inventar_nr/text()')}.jpg"
  end

  # künstler
  def artist
    ["#{record.xpath('.//verfasser/text()')} (#{record.xpath('.//funktion_verfasser/text()')})".gsub(/ \(\)/, "")]
  end

  def artist_normalized
    super(record.xpath('.//verfasser/text()'))
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # datierung
  def date
    "#{record.xpath('.//objektdatierung/text()')} (Projekt: #{record.xpath('.//projektdatierung/text()')})".gsub(/ \(Projekt: \)/, "")
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
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
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
