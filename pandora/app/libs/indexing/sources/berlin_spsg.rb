class Indexing::Sources::BerlinSpsg < Indexing::SourceSuper
  def records
    document.xpath('//museumdat')
  end

  def record_id
    record.xpath('.//administrativeMetadata/recordWrap/recordID/text()')
  end

  def path
    ERB::Util.url_encode(record.at_xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/workID[@type="Dateiname_1600"]/text()').to_s.strip)
  end

  # künstler
  def artist
    ["#{record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()')} (Fotograf)"]
  end

  def artist_normalized
    an = record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()').map { |a|
      a.to_s.strip
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//descriptiveMetadata/identificationWrap/titleWrap/titleSet/title/text()')
  end

  # datierung
  def date
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreationDate/text()')
  end

  # standort
  def location
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryLocationName/text()')
  end

  # Format
  def format
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayMeasurements/text()')
  end

  # material
  def material
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayMaterialsTech/text()')
  end

  # Gattung
  def genre
    record.xpath('.//descriptiveMetadata/objectClassificationWrap/objectWorkTypeWrap/objectWorkType/text()') +
    record.xpath('.//descriptiveMetadata/objectClassificationWrap/classificationWrap/classification/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryLocationName/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryName/text()')
  end

  # Fotograf
  def photographer
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()')
  end

  # schlagwörter
  def keyword
    record.xpath('.//descriptiveMetadata/relationWrap/indexingSubjectWrap/indexingSubjectSet/subjectTerm[@type="allg. Schlagwort"]/text()')
  end

  # topographie
  def keyword_location
    record.xpath('.//descriptiveMetadata/relationWrap/indexingSubjectWrap/indexingSubjectSet/subjectTerm[@type="topogr. Schlagwort"]/text()')
  end

  def inventory_no
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/workID[@type="Foto-Inventar-Nr"]/text()')
  end

  # Bild in Quelldatenbank
  def source_url
    record.xpath('.//administrativeMetadata/recordWrap/recordInfoSet/recordInfoLink/text()')
  end
end
