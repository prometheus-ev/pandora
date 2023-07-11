# https://data.rijksmuseum.nl/object-metadata/download/
class Pandora::Indexing::Parser::AmsterdamRijksmuseumRecord < Pandora::Indexing::Parser::Record
  def record_id
    "#{record.xpath('./lido:administrativeMetadata/lido:recordWrap/lido:recordInfoSet/lido:recordInfoID/text()')}".gsub(/\Aoai:rijksmuseum.nl:/, "")
  end

  def path
    "#{record.at_xpath('./lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet/lido:resourceRepresentation/lido:linkResource/text()')}".gsub(/https:\/\//, '')
  end

  def artist
=begin
    number = record.xpath('count(.//principalMakers)')
    (1..(number.to_i)).map { |index|
      ("#{record.xpath(".//principalMakers[#{index}]/name/text()")}" + " " +
      "(" +
      "#{record.xpath(".//principalMakers[#{index}]/placeOfBirth/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfBirthPrecision/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfBirth/text()")}" + " - " +
      "#{record.xpath(".//principalMakers[#{index}]/placeOfDeath/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfDeathPrecision/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfDeath/text()")}" +
      ") [" +
      "#{record.xpath(".//principalMakers[#{index}]/qualification/text()")}" +
      "]").squeeze(" ").strip.gsub(/\( - \)/, "").gsub(/\A\( - /, "").gsub(/- \)\z/, "").gsub(/ \(\)/, "").gsub(/ \[\]/, "").gsub(/\( /, "(")
    }.uniq
=end
    record.xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventActor/lido:actorInRole/lido:actor/lido:nameActorSet/lido:appellationValue/text()')
  end

  def title
    record.xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:titleWrap/lido:titleSet/lido:appellationValue/text()')
  end

  def date
    earliest_date = record.xpath("./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventType/lido:term[contains(text(),'Expression creation')]/../../lido:eventDate/lido:date/lido:earliestDate/text()").to_s
    latest_date = record.xpath("./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventType/lido:term[contains(text(),'Expression creation')]/../../lido:eventDate/lido:date/lido:latestDate/text()").to_s

    if earliest_date == latest_date
      earliest_date
    else
      "#{earliest_date} - #{latest_date}"
    end
  end

  def date_range
    @date_parser.date_range(date)
  end

  def location
    "Rijksmuseum, Amsterdam"
  end

  def production_place
    record.xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventPlace/lido:place/lido:namePlaceSet/lido:appellationValue/text()')
  end

  # Beschreibung
  def description
    record.xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:objectDescriptionWrap/lido:objectDescriptionSet/lido:descriptiveNoteValue/text()')
  end
=begin

  # Inscription elements do not seem to be available anymore.
  def inscription
    "#{record.xpath('.//inscriptions/inscription/text()')}"
  end

  def short_explanation
    (record.xpath('.//plaqueDescriptionDutch/text()') +
    record.xpath('.//plaqueDescriptionEnglish/text()') +
    record.xpath('.//label/description/text()')).map { |short_explanation_term|
      short_explanation_term.to_s.strip
    }.delete_if { |short_explanation_term|
      short_explanation_term.blank?
    }
  end
=end

  def material
    record.xpath("./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventType/lido:term[contains(text(),'Expression creation')]/../../lido:eventMaterialsTech/lido:materialsTech/lido:termMaterialsTech/lido:term/text()")
  end

  def size
    size_en = []
    size_nl = []
    measurements_set = record.xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:objectMeasurementsWrap/lido:objectMeasurementsSet/lido:objectMeasurements/lido:measurementsSet')

    measurements_set.each do |measurement_set|
      measurement_type = measurement_set.xpath('./lido:measurementType/text()')
      measurement_unit = measurement_set.xpath('./lido:measurementUnit/text()')
      measurement_value = measurement_set.xpath('./lido:measurementValue/text()')
      size_en << "#{measurement_type[0]}: #{measurement_value[0]} #{measurement_unit[0]}"
      size_nl << "#{measurement_type[1]}: #{measurement_value[0]} #{measurement_unit[1]}"
    end

    [size_en.join(', '), size_nl.join(', ')]
  end

=begin
  def technique
    technique = record.xpath('.//techniques/text()').to_a.join(' | ')

    if technique.strip == ""
      record.xpath('.//objectTypes/text()')
    else
      technique
    end
  end

  def genre
    record.xpath('.//objectTypes/text()')
  end

=end
  def credits
    credit_lines = record.xpath('./lido:administrativeMetadata/lido:rightsWorkWrap/lido:rightsWorkSet/lido:creditLine/text()')

    credit_lines.map { |credit_line|
      'Rijksmuseum, Amsterdam; ' + credit_line
    }
  end

  def acquisition_date
    earliest_date = record.xpath("./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventType/lido:term[contains(text(),'Acquisition')]/../../lido:eventDate/lido:date/lido:earliestDate/text()").to_s
    latest_date = record.xpath("./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventType/lido:term[contains(text(),'Acquisition')]/../../lido:eventDate/lido:date/lido:latestDate/text()").to_s

    if earliest_date == latest_date
      earliest_date
    else
      "#{earliest_date} - #{latest_date}"
    end
  end

  def rights_work
    record.xpath("./lido:administrativeMetadata/lido:rightsWorkWrap/lido:rightsWorkSet/lido:rightsType/lido:term[contains(text(),'copyright')]/../../lido:creditLine/text()").to_s
  end

  # Since rights_reproduction_nested exists, rights_reproduction is only used for sorting via rights_reproduction.raw.
  def rights_reproduction
    rights_reproduction_nested.map { |rights_reproduction|
      rights_reproduction['name']
    }.join(' | ')
  end

  def rights_reproduction
    (copyrightHolder = "#{record.xpath('.//copyrightHolder/text()')}").blank? ?
      "http://creativecommons.org/publicdomain/zero/1.0/" : copyrightHolder
  end

  def rights_reproduction_nested
    nested_rights_reproduction = {}
    name = record.at_xpath('./lido:administrativeMetadata/lido:recordWrap/lido:recordRights/lido:rightsHolder/lido:legalBodyName/lido:appellationValue/text()').to_s
    license = record.at_xpath('./lido:administrativeMetadata/lido:recordWrap/lido:recordRights/lido:rightsType/lido:term/text()').to_s
    license_url = record.at_xpath('./lido:administrativeMetadata/lido:recordWrap/lido:recordRights/lido:rightsType/lido:conceptID/text()').to_s

    nested_rights_reproduction['name'] = name
    nested_rights_reproduction['license'] = license
    nested_rights_reproduction['license_url'] = license_url

    [nested_rights_reproduction]
  end

=begin
  def literature
    record.xpath('.//documentation/text()')
  end

  def iconclass
    record.xpath('.//classification/iconClassIdentifier/text()')
  end

  def iconclass_description
    record.xpath('.//classification/iconClassDescription/text()')
  end

  def iconography
    ("#{record.xpath('.//classification/events/text()').to_a.join(' | ')} (Events); " +
     "#{record.xpath('.//classification/places/text()').to_a.join(' | ')} (Places); " +
     "#{record.xpath('.//classification/people/text()').to_a.join(' | ')} (People)").gsub(/\A \(Events\)/, "").gsub(/;  \(Places\)/, "").gsub(/;  \(People\)/, "").gsub(/\A; ; /, "").gsub(/; ; \z/, "").gsub(/\A; /, "").gsub(/; \z/, "")
  end
=end

  def source_url
    "https://www.rijksmuseum.nl/en/collection/#{record_id}"
  end
end
