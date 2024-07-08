class Pandora::Indexing::Parser::DdorfKaRecord < Pandora::Indexing::Parser::Record
  def record_id
    if !(prom_id = record.xpath('.//prometheus_id/text()')).empty?
      prom_id
    else
      record.xpath('.//_system_object_id/text()')
    end
  end

  def path
    record.xpath('.//bild/files/file/original_filename/text()')
  end

  # künstler
  def artist
    record.xpath('.//_nested__bilder__kuenstler/bilder__kuenstler/kuenstler/person/_standard/de-DE/text()')
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('.//_nested__bilder__kuenstler/bilder__kuenstler/kuenstler/person/_standard/de-DE/text()').map do |a|
      a.to_s.split(', ').reverse.join(' ')
    end

    @artist_normalized = @artist_parser.normalize(an)
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
    return @date_range if @date_range

    date = date.to_s.strip

    @date_range = @date_parser.date_range(date)
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
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  # Kommentar
  def comment
    record.xpath('.//kommentar/text()')
  end
end
