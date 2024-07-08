class Indexing::Sources::Parents::Heidicon < Indexing::SourceSuper
  def records
    Indexing::XmlReaderNodeSet.new(document, "lido:lido", "//lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[contains(term[@label='Pool'], '#{pool_name}')]/../../../../administrativeMetadata/resourceWrap/resourceSet")
    # Indexing::XmlReaderNodeSet.new(document, "lido:lido", '//administrativeMetadata/resourceWrap/resourceSet')
  end

  def record_id
    @mapping ||= begin
      ids_file = File.open(File.join(Rails.configuration.x.dumps_path, "ressourcenIDs_heidicon.xml"))
      ids_document = Nokogiri::XML(File.open(ids_file)) do |config|
        config.noblanks
      end

      result = {}
      ids_document.xpath('//row').each do |e|
        old_id = e.xpath('record_ID_old').text
        new_id = e.xpath('record_ID_new').text
        if old_id.present? && new_id.present?
          result[new_id] = old_id
        end
      end
      result
    end
    current_id = "#{record.xpath('.//resourceID/text()')}".gsub(/.*lido-heidicon-/, '')
    @mapping[current_id] || current_id
  end

  def record_object_id
    object_id = "#{record.xpath('.//ancestor::administrativeMetadata/recordWrap/recordID/text()')}"

    [name, Digest::SHA1.hexdigest("#{object_id}")].join('-')
  end

  def path
    resource_id = "#{record.xpath('.//resourceID/text()')}".gsub(/.*lido-heidicon-/, '')
    "cgi-bin/prometheus.cgi?id=#{resource_id}&size=huge"
  end

  # künstler
  def artist
    number = record.xpath("count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventActor)")
    (1..(number.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventActor[#{index}]/actorInRole/actor/actorID/text()")}"
      gnd_file_id = gnd_file_url.to_s.gsub(/http.*\//, '')
      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventActor[#{index}]/actorInRole/attributionQualifierActor[@lang='de']/text()")}: #{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventActor[#{index}]/actorInRole/actor/nameActorSet/appellationValue/text()")} [#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventActor[#{index}]/actorInRole/roleActor/term[@lang='de']/text()")}] (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/^: /, '').gsub(/ \[\]/, '').gsub(/ \(GND: %,%\)/, '')
    }
  end

  def artist_normalized
    artists = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventActor/actorInRole/actor/nameActorSet/appellationValue/text()")
    an = artists.map{|a|
      HTMLEntities.new.decode(a.to_s.sub(/ \(.*/, '').strip.split(', ').reverse.join(' '))
    }
    super(an)
  end

  def modification
    number_modifications = record.xpath('count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()="Bearbeitung"])')
    (0..(number_modifications - 1.to_i)).map{|number|
      number_persons = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath('count(../../eventActor)')
      persons = (1..(number_persons.to_i)).map{|index|
        gnd_file_url = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../eventActor[#{index}]/actorInRole/actor/actorID/text()")
        gnd_file_id = gnd_file_url.to_s.gsub(/http.*\//, '')

        "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../eventActor[#{index}]/actorInRole/attributionQualifierActor[@lang='de']/text()")}: #{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../eventActor[#{index}]/actorInRole/actor/nameActorSet/appellationValue/text()")} [#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../eventActor[#{index}]/actorInRole/roleActor/term[@lang='de']/text()")}] (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/^: /, '').gsub(/ \[\]/, '').gsub(/ \(GND: ,\)/, '')
      }.join(", ")

      date = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../eventDate/displayDate/text()")} (#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../periodName/term/text()")})".gsub(/\(\)/, '')

      number_techniques = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath('count(../../eventMaterialsTech)')
      techniques = (1..(number_techniques.to_i)).map{|index|
        record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../eventMaterialsTech[#{index}]/materialsTech/termMaterialsTech/term/text()")
      }.join(", ")

      description = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Bearbeitung']")[number].xpath("../../eventDescriptionSet/descriptiveNoteValue/text()")

      "#{persons}, #{date}, #{techniques}, #{description}".gsub(/\A, /, '').gsub(/, \z/, '').gsub(/  /, ' ').gsub(/, , /, ', ')
    }
  end

  def commissioning
    number = record.xpath("count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Auftrag']/../../eventActor)")
    (1..(number.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Auftrag']/../../eventActor[#{index}]/actorInRole/actor/actorID/text()")}"
      gnd_file_id = gnd_file_url.to_s.gsub(/http.*\//, '')
      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Auftrag']/../../eventActor[#{index}]/actorInRole/actor/nameActorSet/appellationValue/text()")} (GND: %#{gnd_file_id},#{gnd_file_url}%), #{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Auftrag']/../../eventDate/displayDate/text()")} [#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Auftrag']/../../eventDescriptionSet/descriptiveNoteValue/text()")}]".gsub(/^: /, '').gsub(/ \[\]/, '').gsub(/ \(GND:\)/, '')
    }
  end

  # titel
  def title
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet)')
    (1..(number.to_i)).map{|index|
      perspective = "#{record.xpath('.//ancestor::administrativeMetadata/resourceWrap/resourceSet/resourcePerspective/term/text()')}"
      if !(type = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet[#{index}]/@type")}").blank?
        "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet[#{index}]/appellationValue/text()")} (#{type})".gsub(/\(\)/, '')
      else
        str = [record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet[#{index}]/appellationValue/text()")].join(" | ")
        str << " [#{perspective}]".gsub(/ \[\]/, '')
      end
    }
  end

  # datierung
  def date
    if (displayDate = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventDate/displayDate/text()")}").blank?
      date_start = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventDate/date/earliestDate/text()")}"
      date_end = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventDate/date/latestDate/text()")}"
      if date_start == date_end
        date_start
      else
        "#{date_start} - #{date_end}"
      end
    else
      displayDate
    end
  end

  def date_range
    if d = date
      d = d.strip
    end

    if d != ''
      super(d)
    end
  end

  # epoche
  def epoch
    record.xpath('.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/periodName/term/text()')
  end

  # groesse
  def size
    record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/objectMeasurementsWrap/objectMeasurementsSet/displayObjectMeasurements/text()')
  end

  # standort
  def location
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet)')

    (1..(number.to_i)).map{|index|
      location = record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet[#{index}]/repositoryName/legalBodyName/appellationValue/text()") | record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet[#{index}]/repositoryLocation/namePlaceSet/appellationValue/text()")
      authority_file_label = record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet[#{index}]/repositoryName/legalBodyID/@label") | record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet[#{index}]/repositoryLocation/placeID/@label")
      authority_file_url = record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet[#{index}]/repositoryName/legalBodyID/text()") | record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet[#{index}]/repositoryLocation/placeID/text()")
      authority_file_id = authority_file_url.to_s.gsub(/http.*\//, '')
      inventory_number = record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet[#{index}]/workID[@type='Inventarnummer']/text()")
      "#{location.to_s} (#{authority_file_label.to_s}: %#{authority_file_id},#{authority_file_url.to_s}%) [Inv.-Nr.: #{inventory_number}]".gsub(/ \[Inv.-Nr.: \]/, '').gsub(/ \(: %,%\)/, '')
    }
  end

  # herstellungsort
  def production_place
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()="Herstellung"]/../../eventPlace)')
    (1..(number.to_i)).map{|index|
      authority_file_label = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventPlace[#{index}]/place/placeID/@label")}".scan(/\(.*\)/).join.gsub(/[\(\)]/, '')
      authority_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventPlace[#{index}]/place/placeID/text()")}"
      authority_file_id = authority_file_url.gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventPlace[#{index}]/place/namePlaceSet/appellationValue/text()")} (#{authority_file_label}: %#{authority_file_id},#{authority_file_url}%)".gsub(/ \(: %,%\)/, '')
    }
  end

  def creation_context
    record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventDescriptionSet/descriptiveNoteValue[@label='Entstehungskontext']/text()")
  end

  # fundort
  def discoveryplace
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[starts-with(text(),"Fund")]/../../eventPlace)')
    (1..(number.to_i)).map{|index|
      authority_file_label = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[starts-with(text(),'Fund')]/../../eventPlace[#{index}]/place/placeID/@label")}".scan(/\(.*\)/).join.gsub(/[\(\)]/, '')
      authority_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[starts-with(text(),'Fund')]/../../eventPlace[#{index}]/place/placeID/text()")}"
      authority_file_id = authority_file_url.gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[starts-with(text(),'Fund')]/../../eventPlace[#{index}]/place/namePlaceSet/appellationValue/text()")} (#{authority_file_label}: %#{authority_file_id},#{authority_file_url}%)".gsub(/ \(: %,%\)/, '')
    }
  end

  # fundkontext
  def discoverycontext
    record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventDescriptionSet/descriptiveNoteValue[@label='Fundkontext']/text()")
  end

  def discovery_date
    record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[starts-with(text(),'Fund')]/../../eventDate/displayDate/text()")
  end

  def provenance
    number_provenances = record.xpath('count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()="Provenienz"])')
    (0..(number_provenances - 1.to_i)).map{|number|
      number_institutions = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath('count(../../eventPlace)')
      institutions = (1..(number_institutions.to_i)).map{|index|
        authority_file_label = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventPlace[#{index}]/place/placeID/@label")}".scan(/\(.*\)/).join.gsub(/[\(\)]/, '')
        authority_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventPlace[#{index}]/place/placeID/text()")}"
        authority_file_id = authority_file_url.gsub(/http.*\//, '')

        "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventPlace[#{index}]/place/namePlaceSet/appellationValue/text()")} (#{authority_file_label}: %#{authority_file_id},#{authority_file_url}%)".gsub(/ \(: %,%\)/, '')
      }.join(", ")

      number_persons = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath('count(../../eventActor)')
      persons = (1..(number_persons.to_i)).map{|index|
        gnd_file_url = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventActor[#{index}]/actorInRole/actor/actorID/text()")
        gnd_file_id = gnd_file_url.to_s.gsub(/http.*\//, '')

        "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventActor[#{index}]/actorInRole/actor/nameActorSet/appellationValue/text()")} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
      }.join(", ")

      date = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventDate/date/earliestDate/text()")} - #{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventDate/date/latestDate/text()")}".gsub(/\A - /, '').gsub(/ - \z/, '')

      description = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Provenienz']")[number].xpath("../../eventDescriptionSet/descriptiveNoteValue/text()")

      "#{institutions}, #{persons}, #{date}, #{description}".gsub(/\A, /, '').gsub(/, \z/, '').gsub(/, , /, '')
    }
  end

  def restauration
    number_restauration = record.xpath('count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()="Restaurierung"])')
    (0..(number_restauration - 1.to_i)).map{|index|
      record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Restaurierung']")[index].xpath("../../eventDate/displayDate/text()")
      record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Restaurierung']")[index].xpath("../../eventDescriptionSet/descriptiveNoteValue/text()")
    }
  end

  def acquisition
    arr = []
    arr <<  record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Erwerbung']/../../eventMethod/term[@lang='de']/text()")
    arr <<  "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Erwerbung']/../../eventDate/date/earliestDate/text()")} - #{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Erwerbung']/../../eventDate/date/latestDate/text()")}".gsub(/\A - /, '').gsub(/ - \z/, '')
    arr <<  record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Erwerbung']/../../eventDescriptionSet/descriptiveNoteValue/text()")
  end

  def publication
    number_publication = record.xpath('count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()="Publikation"])')
    (0..(number_publication - 1.to_i)).map{|index|
      actor = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Publikation']")[index].xpath("../../eventActor/actorInRole/actor/nameActorSet/appellationValue/text()")

      number_places = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Publikation']")[index].xpath('count(../../eventPlace)')
      places = (1..(number_places.to_i)).map{|number|
        gnd_file_url = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Publikation']")[index].xpath("../../eventPlace[#{number}]/place/placeID/text()")
        gnd_file_id = "#{gnd_file_url}".gsub(/http.*\//, '')
        place = record.
          xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Publikation']")[index].
          xpath("../../eventPlace[#{number}]/place/namePlaceSet/appellationValue/text()")
        "#{place} (GND: %#{gnd_file_id},#{gnd_file_url}%)"
      }.join(", ")
      date = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Publikation']")[index].xpath("../../eventDate/date/earliestDate/text()")} - #{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Publikation']")[index].xpath("../../eventDate/date/latestDate/text()")}"
      description = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Publikation']")[index].xpath("../../eventDescriptionSet/descriptiveNoteValue/text()")

      "#{actor}, #{places}, #{date}, #{description}".gsub(/\(GND: %,%\), /, '').gsub(/\A, /, '').gsub(/, \z/, '')
    }
  end

  def literature
    [record.xpath('.//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectNote[@type="Literatur"]/text()')].join(" | ")
  end

  def weblink_literature
    if !(link = record.xpath('.//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectWebResource[@label="Literatur Weblink"]/text()')).blank?
      "#{link},#{link}"
    end
  end

  def external_references
    if !(link = record.xpath('.//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectWebResource[@label="Verweis"]/text()')).blank?
      "#{link},#{link}"
    end
  end

  def exhibition
    number_exhibition = record.xpath('count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()="Ausstellung"])')
    (0..(number_exhibition - 1.to_i)).map{|index|
      title = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Ausstellung']")[index].xpath("../../eventName/appellationValue/text()")

      number_places = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Ausstellung']")[index].xpath('count(../../eventPlace)')
      places = (1..(number_places.to_i)).map{|number|
        gnd_file_url = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Ausstellung']")[index].xpath("../../eventPlace[#{number}]/place/placeID/text()")
        gnd_file_id = "#{gnd_file_url}".gsub(/http.*\//, '')
        place = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Ausstellung']")[index].xpath("../../eventPlace[#{number}]/place/namePlaceSet/appellationValue/text()")
        "#{place} (GND: %#{gnd_file_id},#{gnd_file_url}%)"
      }.join(", ")
      date = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Ausstellung']")[index].xpath("../../eventDate/date/earliestDate/text()")} - #{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Ausstellung']")[index].xpath("../../eventDate/date/latestDate/text()")}"
      source = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Ausstellung']")[index].xpath("../../eventName/sourceAppellation/text()")

      "#{title}, #{places}, #{date} (#{source})".gsub(/\(\)/, '').gsub(/\A, /, '').gsub(/, \z/, '')
    }
  end

  # material
  def material
    number = record.xpath("count(.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventMaterialsTech/materialsTech/termMaterialsTech)")
    (1..(number.to_i)).map{|index|
      authority_file_url = record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventMaterialsTech/materialsTech/termMaterialsTech[#{index}]/conceptID/text()")
      authority_file_id = authority_file_url.to_s.gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Herstellung']/../../eventMaterialsTech/materialsTech/termMaterialsTech[#{index}]/term/text()")} (GND: %#{authority_file_id},#{authority_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }
  end

  def technique
    record.xpath('.//ancestor::lido/descriptiveMetadata/eventWrap/eventSet/event/eventMaterialsTech/displayMaterialsTech/text()')
  end

  def objecttype
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/objectWorkTypeWrap/objectWorkType)')
    (1..(number.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectClassificationWrap/objectWorkTypeWrap/objectWorkType[#{index}]/conceptID/text()")}"
      gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectClassificationWrap/objectWorkTypeWrap/objectWorkType[#{index}]/term/text()")} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }
  end

  def genre
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type="Gattung"])')
    (0..(number - 1.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type='Gattung']")[index].xpath("./conceptID/text()")}"
      gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

      "#{record.xpath('.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type="Gattung"]')[index].xpath('./term/text()')} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }
  end

  def form
    gnd_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type='Form']/conceptID/text()")}"
    gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

    "#{record.xpath('.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type="Form"]/term/text()')} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
  end

  def classification
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type="Sachgruppe"])')
    (0..(number - 1.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type='Sachgruppe']")[index].xpath("./conceptID/text()")}"
      gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

      "#{record.xpath('.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type="Sachgruppe"]')[index].xpath('./term/text()')} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }
  end

  def language
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type="Sprache"])')
    (0..(number - 1.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type='Sprache']")[index].xpath("./conceptID/text()")}"
      gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

      "#{record.xpath('.//ancestor::lido/descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type="Sprache"]')[index].xpath('./term/text()')} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }
  end

  def iconography
    number_concepts = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectConcept)')
    concepts = (1..(number_concepts.to_i)).map{|index|
      authority_file_label = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectConcept[#{index}]/conceptID/@label")}"
      authority_file_url = "#{record.xpath(".//ancestor::lido//descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectConcept[#{index}]/conceptID/text()")}"
      authority_file_id = authority_file_url.gsub(/\/\z/, '').gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectConcept[#{index}]/term[1]/text()")} (#{authority_file_label}: %#{authority_file_id},#{authority_file_url}%)".gsub(/ \(: %,%\)/, '')
    }.join(", ")

    number_actors = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectActor)')
    actors = (1..(number_actors.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido//descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectActor[#{index}]/actor/actorID/text()")}"
      gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido//descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectActor[#{index}]/actor/nameActorSet/appellationValue/text()")} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }.join(", ")

    number_places = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectPlace)')
    places = (1..(number_places.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido//descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectPlace[#{index}]/place/placeID/text()")}"
      gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido//descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectPlace[#{index}]/place/namePlaceSet/appellationValue/text()")} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }.join(", ")

    number_objects = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectObject)')
    objects = (1..(number_objects.to_i)).map{|index|
      gnd_file_url = "#{record.xpath(".//ancestor::lido//descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectObject[#{index}]/object/objectID/text()")}"
      gnd_file_id = gnd_file_url.gsub(/http.*\//, '')

      "#{record.xpath(".//ancestor::lido//descriptiveMetadata/objectRelationWrap/subjectWrap/subjectSet/subject/subjectObject[#{index}]/object/objectNote/text()")} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/\(GND: %,%\)/, '')
    }.join(", ")

    "#{concepts}, #{actors}, #{places}, #{objects}".gsub(/ \(: %,%\)/, '').gsub(/\A, /, '').gsub(/, \z/, '').gsub(/, , /, ', ').split(", ")
  end

  def inscription
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/inscriptionsWrap/inscriptions[@type="Inschrift"])')
    (1..(number.to_i)).map {|index|
      location = [record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/inscriptionsWrap/inscriptions[#{index}]/inscriptionDescription/descriptiveNoteValue/text()")].join(" | ")
      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/inscriptionsWrap/inscriptions[#{index}]/inscriptionTranscription/text()")} (#{location})".gsub(/\(\)/, '')
    }
  end

  def watermark
    record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/inscriptionsWrap/inscriptions[@type="Wasserzeichen"]/inscriptionDescription/descriptiveNoteValue/text()')
  end

  # bildnachweis
  def credits
    "#{record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet/sourceAppellation/text()')}, #{record.xpath('.//ancestor::lido/administrativeMetadata/rightsWorkWrap/rightsWorkSet/rightsHolder/legalBodyName/legalBodyWeblink/text()')}, #{record.xpath('.//rightsResource/creditLine/text()')}".gsub(/\A(, )*/, '').gsub(/, \z/, '')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    else
      "#{record.xpath('.//ancestor::lido/administrativeMetadata/rightsWorkWrap/rightsWorkSet/rightsType/term[@lang="de"]/text()')}, #{record.xpath('.//ancestor::lido/administrativeMetadata/rightsWorkWrap/rightsWorkSet/rightsHolder/legalBodyName/appellationValue/text()')} #{record.xpath('.//ancestor::lido/administrativeMetadata/rightsWorkWrap/rightsWorkSet/rightsHolder/legalBodyName/legalBodyWeblink/text()')}, #{record.xpath('.//ancestor::lido/administrativeMetadata/rightsWorkWrap/rightsWorkSet/creditLine/text()')}".gsub(/\A, /, '').gsub(/, \z/, '').gsub(/, , /, ', ')
    end
  end

  # bildrecht
  def rights_reproduction
    str =  [record.xpath('.//resourceSource/legalBodyName/appellationValue/text()')].join(", ")
    str << " [#{record.xpath('.//rightsResource/rightsType/term[@lang="de"]/text()')}]".gsub(/ \[\]/, '')
  end

  # bechreibung
  def description
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet)')
    (1..(number.to_i)).map {|index|
      "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet[#{index}]/descriptiveNoteValue[@lang='de' and @label='Objektbeschreibung']/text()")} (Quelle: #{record.xpath(".//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet[#{index}]/sourceDescriptiveNote/text()")})".gsub(/\(Quelle: \)/, '').gsub(/: ,/, ':').gsub(/, \)/, '')
    }
  end

  # erhaltungszustand
  def condition
    record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet/descriptiveNoteValue[@label="Erhaltungszustand"]/text()')
  end

  def comment
    record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet/descriptiveNoteValue[@label="Kommentar"]/text()')
  end

  # Auflage/Editionsnummer
  def edition
    "#{record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/displayStateEditionWrap/displayEdition/text()')}; #{record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/displayStateEditionWrap/displayState/text()')}; #{record.xpath('.//ancestor::lido/descriptiveMetadata/objectIdentificationWrap/displayStateEditionWrap/sourceStateEditionend/text()')}".gsub(/\A; ; ;/, '').gsub(/\A; ;/, '').gsub(/\A; /, '').gsub(/; ;\z/, '')
  end

  # werkverzeichnis
  def catalogue
    record.xpath('.//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectID[@label="Werkverzeichnis + Nr."]/text()')
  end

  def related_works
    number = record.xpath('count(.//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object)')
    (1..(number.to_i)).map do |index|
      if !(related_works_id = "#{record.xpath(".//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet[#{index}]/relatedWork/object/objectID[@encodinganalog='lk_objekte'][1]/text()")}".gsub(/.*\//, '')).blank?
        object_id = [name, Digest::SHA1.hexdigest("#{related_works_id}")].join('-')
        relation = record.xpath(".//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet[#{index}]/relatedWorkRelType/term[@lang='de']/text()")
        title = record.xpath(".//ancestor::lido/descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet[#{index}]/relatedWork/object/objectNote[@label='Kurzbeschreibung']/text()")
        "#{relation}: #{title},#{object_id}".gsub(/\A: ,/, '').gsub(/\A: /, '').gsub(/: ,/, ':')
      end
    end
  end

  # Bild in Quelldatenbank
  def source_url
  end
end
