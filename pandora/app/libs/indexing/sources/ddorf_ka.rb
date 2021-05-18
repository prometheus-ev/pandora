class Indexing::Sources::DdorfKa < Indexing::SourceSuper
  def records
    document.xpath('//objekt')
  end

  def record_id
    record.xpath('.//id/text()')
  end

  def path
    record.xpath('.//filename/text()')
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

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  # standort
  def location
    record.xpath('.//ort/text()')
  end

  # technik
  def material
    record.xpath('.//technik/text()')
  end

  # Masse
  def size
    record.xpath('.//masse/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//bildnachweis/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # Kommentar
  def comment
    record.xpath('.//kommentar/text()')
  end
end
