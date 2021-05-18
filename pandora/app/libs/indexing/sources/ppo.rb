class Indexing::Sources::Ppo < Indexing::SourceSuper
  def records(file)
    document(file).xpath('//metadata/lido')
  end

  def record_id
   #record.xpath('.//bildnr/text()')
   # to get same record_id like in the former version we have to re-create the "bildnr", which has been something like "JpegClip/ad_000182/ad_000182_13b"
    ppo_object_id = "#{record.xpath('.//descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectID[@type="PPO-GS-ID"]/text()')}"
    ppo_object_folder_elements = ppo_object_id.split("_")
    count_elements = ppo_object_folder_elements.count
    ppo_object_folder_elements.delete_at(count_elements-1)
    ppo_object_folder = ppo_object_folder_elements.join("_")
    "JpegClip/#{ppo_object_folder}/#{ppo_object_id}"
  end

  def path
    path_convert="#{record.xpath('.//administrativeMetadata/resourceWrap/resourceSet/resourceRepresentation/linkResource/text()')}".gsub(/\//,'U002F')
    "viewer/api/v1/image/-/#{path_convert}/full/!3000,3000/0/default.jpg"
  end
  

  # künstler
  def artist
    number = record.xpath("count(.//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../eventActor)")
    (1..(number.to_i)).map{ |index|
      gnd_file_url = "#{record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../eventActor[#{index}]/actorInRole/actor/actorID/text()")}"
      gnd_file_id = gnd_file_url.to_s.gsub(/http.*\//,'')
      "#{record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../eventActor[#{index}]/actorInRole/actor/nameActorSet/appellationValue/text()")} [#{record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../eventActor[#{index}]/actorInRole/roleActor/term/text()")}] (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/^: /,'').gsub(/ \[\]/,'').gsub(/ \(GND: %,%\)/,'')
    }
  end

  def artist_normalized
    artists = record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../eventActor/actorInRole/actor/nameActorSet/appellationValue/text()")
    an = artists.map{ |a|
      HTMLEntities.new.decode(a.to_s.sub(/ \(.*/, '').strip.split(', ').reverse.join(' '))
    }
    super(an)

  end

  # titel
  def title
    "#{record.xpath('.//descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet/appellationValue/text()')} (#{record.xpath('.//descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet/@type')})".gsub(/\(\)/,'')
  end

  # datierung
  def date
   date_start = record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../eventDate/date/earliestDate/text()")
   date_end = record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../eventDate/date/latestDate/text()")

    if date_end.blank?
      date_start
    else
      "#{date_start} - #{date_end}"
    end
  end

  # epoche
  def epoch
    record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventType/term[text()='Entstehung']/../../periodName/term/text()")
  end

  # standort
  def location
    record.xpath('.//administrativeMetadata/recordWrap/recordSource/legalBodyName/appellationValue/text()')
  end

  # technik
  def technique
    record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventMaterialsTech/materialsTech/termMaterialsTech[@type='Technique']/term/text()")
  end

  def material 
    record.xpath(".//descriptiveMetadata/eventWrap/eventSet/event/eventMaterialsTech/materialsTech/termMaterialsTech[@type='Material']/term/text()")
  end

  def size
    record.xpath(".//descriptiveMetadata/objectIdentificationWrap/objectMeasurementsWrap/objectMeasurementsSet/displayObjectMeasurements/text()")
  end

  # bildsignatur
  def signature
    record.xpath(".//descriptiveMetadata/objectIdentificationWrap/inscriptionsWrap/inscriptions[@type='Künstlersignatur']/inscriptionTranscription/text()")
  end

  # bildunterschrift/~überschrift
  def caption
    record.xpath('.//descriptiveMetadata/objectIdentificationWrap/inscriptionsWrap/inscriptions[starts-with(@type, "Über")]/inscriptionTranscription/text()')
  end

  # bildinschrift
  def inscription
    record.xpath(".//descriptiveMetadata/objectIdentificationWrap/inscriptionsWrap/inscriptions[@type='Inschrift']/inscriptionTranscription/text()")
  end

  # bildbeschreibung (quelle)
  def description_source
    record.xpath(".//descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet[@type='originalebeschreibung']/descriptiveNoteValue/text()")
  end

  # schlagwort
  def keyword
    number = record.xpath("count(.//descriptiveMetadata/objectClassificationWrap/classificationWrap/classification)")
    (1..(number.to_i)).map{ |index|
      gnd_file_url = "#{record.xpath(".//descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[#{index}]/conceptID/text()")}"
      gnd_file_id = gnd_file_url.to_s.gsub(/http.*\//,'')
      "#{record.xpath(".//descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[#{index}]/term/text()")} (GND: %#{gnd_file_id},#{gnd_file_url}%)".gsub(/^: /,'').gsub(/ \[\]/,'').gsub(/ \(GND: %,%\)/,'')
    }
  end

  # abbildungsnachweis
  def credits
    record.xpath(".//descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet/sourceDescriptiveNote/text()")
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht (kürzel)
  def rights_reproduction
    record.xpath(".//administrativeMetadata/rightsWorkWrap/rightsWorkSet/creditLine/text()")
  end

  def source_url
	  "#{record.xpath('.//descriptiveMetadata/objectRelationWrap/relatedWorksWrap/relatedWorkSet/relatedWork/object/objectWebResource[@label="VollansichtSeite"]/text()')}".gsub(/amp;/, '')
  end
end
