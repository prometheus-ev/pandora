class Indexing::Sources::DdorfKa < Indexing::SourceSuper
  def records
    document.xpath('//bilder')
  end

  def record_id
    record.xpath('.//prometheus_id/text()')
  end

  def path
    record.xpath('.//bild/files/file/original_filename/text()')
  end

  # künstler
  def artist
    record.xpath('.//_nested__bilder__kuenstler/bilder__kuenstler/kuenstler/person/_standard/de-DE/text()')
  end

  def artist_normalized
    an = record.xpath('.//_nested__bilder__kuenstler/bilder__kuenstler/kuenstler/person/_standard/de-DE/text()').map { |a|
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
    from = record.xpath('.//datierung_range/from/text()')
    to = record.xpath('.//datierung_range/to/text()')

    if "#{from}" == "#{to}"
      "#{from}"
    else
      "#{from} - #{to}"
    end
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  # standort
  def location
    record.xpath('.//ort_id/ort/_standard/de-DE/text()')
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
