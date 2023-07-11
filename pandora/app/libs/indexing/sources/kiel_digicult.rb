class Indexing::Sources::KielDigicult < Indexing::SourceSuper
  def records
    document.xpath('//museumdat')
  end

  def record_id
    "#{record.xpath('.//administrativeMetadata/recordWrap/recordID/text()')}##{_id}".gsub(/#.*\//, '').gsub(/\.JPG/, '').gsub(/\.jpg/, "")
  end

  def path
    _id
  end

  def _id
    "#{record.at_xpath('.//administrativeMetadata/resourceWrap/resourceSet/linkResource[@type="image_detail"]/text()')}"
  end

  def s_keyword
    record.xpath('.//descriptiveMetadata/relationWrap/indexingSubjectWrap/indexingSubjectSet/subjectTerm[@imported="no"]/text()')
  end

  def s_unspecified
    [record.xpath('.//descriptiveMetadata/eventWrap/styleWrap/style[@imported="no"]/text()'), record.xpath('.//descriptiveMetadata/descriptionWrap/descriptiveNoteWrap/descriptiveNoteSet[@type="objectHistory"]/descriptiveNote/text()'), record.xpath('.//descriptiveMetadata/eventWrap/indexingEventWrap/indexingEventSet/indexingLocationWrap/indexingLocationSet/nameLocationSet/nameLocation[@imported="no"]/text()'), record.xpath('.//descriptiveMetadata/identificationWrap/inscriptionsWrap/inscriptions/text()'), record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/workID/text()')]
  end

  def s_material
    [record.xpath('.//descriptiveMetadata/eventWrap/indexingMaterialsTechWrap/indexingMaterialsTechSet[@type="material"]/termMaterialsTech[@imported="no"]/text()'), record.xpath('.//descriptiveMetadata/eventWrap/indexingMaterialsTechWrap/indexingMaterialsTechSet[@type="technique"]/termMaterialsTech[@imported="no"]/text()')]
  end

  # künstler
  def artist
    if record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()').empty?
      record.xpath('.//descriptiveMetadata/eventWrap/indexingEventWrap/indexingEventSet/indexingActorSet/nameActorSet/nameActor[@termsource="xTree"]/text()')
    else
      record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreator/text()')
    end
  end

  def artist_normalized
    an = artist.map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//descriptiveMetadata/identificationWrap/titleWrap/titleSet/title/text()')
  end

  # datierung
  def date
    date         = "#{record.xpath('.//descriptiveMetadata/descriptionWrap/displayCreationDate/text()')}"
    earliestDate = "#{record.xpath('.//descriptiveMetadata/eventWrap/indexingEventWrap/indexingEventSet/indexingDates/earliestDate/text()')}"
    latestDate   = "#{record.xpath('.//descriptiveMetadata/eventWrap/indexingEventWrap/indexingEventSet/indexingDates/latestDate/text()')}"

    if date.blank?
      if earliestDate == latestDate
        earliestDate
      else
        "#{earliestDate} - #{latestDate}".gsub(/\A - /, '').gsub(/ - \z/, '')
      end
    else
      date
    end
  end

  def date_range
    d = date.delete_suffix(' ?').strip

    super(d)
  end

  # standort
  def location
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryName/text()')
  end

  # Format
  def size
    record.xpath('.//descriptiveMetadata/descriptionWrap/displayMeasurements/text()')
  end

  # material
  def material
    record.xpath('.//descriptiveMetadata/eventWrap/indexingMaterialsTechWrap/indexingMaterialsTechSet[@type="material"]/termMaterialsTech[@imported="no"]/text()')
  end

  def technique
    record.xpath('.//descriptiveMetadata/eventWrap/indexingMaterialsTechWrap/indexingMaterialsTechSet[@type="technique"]/termMaterialsTech[@imported="no"]/text()')
  end

  # Ikonographie
  def iconography
    record.xpath('.//descriptiveMetadata/relationWrap/indexingSubjectWrap/indexingSubjectSet/subjectTerm[@imported="no"]/text()')
  end

  # Stil
  def epoch
    record.xpath('.//descriptiveMetadata/eventWrap/styleWrap/style[@imported="no"]/text()')
  end

  def addition
    record.xpath('.//descriptiveMetadata/descriptionWrap/descriptiveNoteWrap/descriptiveNoteSet[@type="objectHistory"]/descriptiveNote/text()')
  end

  def description
    record.xpath('.//descriptiveMetadata/descriptionWrap/descriptiveNoteWrap/descriptiveNoteSet[@type="description"]/descriptiveNote/text()')
  end

  def genre
    record.xpath('.//descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@imported="no"]/text()') +
    record.xpath('.//descriptiveMetadata/objectClassificationWrap/objectWorkTypeWrap/objectWorkType/text()')
  end

  # Bildnachweis
  def credits
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/repositoryName/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//administrativeMetadata/rightsWork/text()')
  end

  # topographie
  def origin
    record.xpath('.//descriptiveMetadata/eventWrap/indexingEventWrap/indexingEventSet/indexingLocationWrap/indexingLocationSet/nameLocationSet/nameLocation[@imported="no"]/text()')
  end

  def inscription
    record.xpath('.//descriptiveMetadata/identificationWrap/inscriptionsWrap/inscriptions').text
  end

  def inventory_no
    record.xpath('.//descriptiveMetadata/identificationWrap/repositoryWrap/repositorySet/workID/text()')
  end

  # Bild in Quelldatenbank
  def source_url
    record.xpath('.//administrativeMetadata/recordWrap/recordInfoSet/recordInfoLink/text()')
  end
end
