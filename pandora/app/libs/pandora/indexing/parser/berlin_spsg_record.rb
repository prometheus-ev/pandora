class Pandora::Indexing::Parser::BerlinSpsgRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.xpath('.//administrativeMetadata/recordWrap/recordID/text()')
  end

  def path
    ERB::Util.url_encode(record.at_xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/workID[@type="Dateiname_1600"]/text()').to_s.strip)
  end

  def artist
    ["#{record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()')} (Fotograf)"]
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()').map { |a|
      a.to_s.strip
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    record.xpath('.//descriptiveMetadata/identificationWrap/titleWrap/titleSet/title/text()')
  end

  def date
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreationDate/text()')
  end

  def date_range
    return @date_range if @date_range

    date = record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreationDate/text()').to_s.strip

    if date == '31.9.1931'
      date = '30.9.1931'
    elsif date == '1890-19421'
      date = '1890-1942'
    elsif date == '1927-19435'
      date = '1927-1943'
    elsif date == '1890-19420'
      date = '1890-1942'
    end

    @date_range = @date_parser.date_range(date)
  end

  def location
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryLocationName/text()')
  end

  def format
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayMeasurements/text()')
  end

  def material
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayMaterialsTech/text()')
  end

  def genre
    record.xpath('.//descriptiveMetadata/objectClassificationWrap/objectWorkTypeWrap/objectWorkType/text()') +
    record.xpath('.//descriptiveMetadata/objectClassificationWrap/classificationWrap/classification/text()')
  end

  def credits
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryLocationName/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryName/text()')
  end

  def photographer
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()')
  end

  def keyword
    record.xpath('.//descriptiveMetadata/relationWrap/indexingSubjectWrap/indexingSubjectSet/subjectTerm[@type="allg. Schlagwort"]/text()')
  end

  def keyword_location
    record.xpath('.//descriptiveMetadata/relationWrap/indexingSubjectWrap/indexingSubjectSet/subjectTerm[@type="topogr. Schlagwort"]/text()')
  end

  def inventory_no
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/workID[@type="Foto-Inventar-Nr"]/text()')
  end

  def source_url
    record.xpath('.//administrativeMetadata/recordWrap/recordInfoSet/recordInfoLink/text()')
  end
end
