class Indexing::Sources::ZiMuc < Indexing::SourceSuper
  def records
    document.xpath('//row')
  end

  def record_id
    record.xpath('.//bildnummer/text()')
  end

  def path
    "#{record.at_xpath('.//bildnummer/text()')}.jpg"
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstler/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  # material
  def material
    record.xpath('.//material/text()')
  end

  # Gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  # beschreibung
  def description
    record.xpath('.//beschreibung/text()')
  end

  def source_url
    "http://digilib2.gwdg.de/khi/digitallibrary/digilib.jsp?#{record.xpath('.//objektnummer/text()')}/#{record.xpath('.//bildnummer/text()')}"
  end
end
