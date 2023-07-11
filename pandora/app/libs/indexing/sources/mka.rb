class Indexing::Sources::Mka < Indexing::SourceSuper
  def records
    Indexing::XmlReaderNodeSet.new(document, "lido:lido", '.')
  end

  def record_id
    record.at_xpath('./administrativeMetadata/recordWrap/recordID/text()').to_s
  end

  def inventory_no
    record.at_xpath('./descriptiveMetadata/objectIdentificationWrap/repositoryWrap/repositorySet/workID/text()').to_s
  end

  def path
    "https://api.stiftung-imai.de/api/v1/vid/#{inventory_no}"
  end

  # Since artist_nested exists, artist is only used for sorting via artist.raw.
  def artist
    artist_names.join(' | ')
  end

  def artist_nested
    nested_artists = []
    artists = record.xpath('./descriptiveMetadata/eventWrap/eventSet/event/eventActor/actorInRole')
    return unless artists

    artists.each do |artist|
      a = {}
      a['name'] = artist.xpath('./actor/nameActorSet/appellationValue').map(&:text).uniq.join(', ')
      a['gnd_url'] = artist.at_xpath("./actor/actorID[@source='Gemeinsame Normdatei (GND)']/text()").to_s

      nested_artists << a
    end

    nested_artists
  end

  def artist_normalized
    super(artist_names)
  end

  def title
    record.xpath('./descriptiveMetadata/objectIdentificationWrap/titleWrap/titleSet/appellationValue').text
  end

  def date
    record.at_xpath('./descriptiveMetadata/eventWrap/eventSet/event/eventDate/displayDate/text()').to_s
  end

  def date_range
    super(date)
  end

  def country
    record.at_xpath('./descriptiveMetadata/eventWrap/eventSet/event/eventPlace/displayPlace/text()').to_s
  end

  def genre
    genres = record.xpath("./descriptiveMetadata/objectClassificationWrap/objectWorkTypeWrap/objectWorkType/term").map(&:text) + record.xpath("./descriptiveMetadata/objectClassificationWrap/classificationWrap/classification[@type='Sachgruppe']/term").map(&:text)

    genres.uniq
  end

  def duration
    duration = record.at_xpath('./descriptiveMetadata/objectIdentificationWrap/objectMeasurementsWrap/objectMeasurementsSet/displayObjectMeasurements')

    duration.text.delete_prefix('Dauer: ') if duration
  end

  def material_technique
    record.xpath('./descriptiveMetadata/eventWrap/eventSet/event/eventMaterialsTech/displayMaterialsTech/text()').map(&:text).uniq
  end

  def keywords
    keywords = record.at_xpath('./descriptiveMetadata/objectIdentificationWrap/objectDescriptionWrap/objectDescriptionSet/descriptiveNoteValue')

    keywords.text.split(', ') if keywords
  end

  def location
    'Stiftung IMAI - Inter Media Art Institute'
  end

  def rights_reproduction
    record.at_xpath('./administrativeMetadata/recordWrap/recordRights/rightsType/term/text()').to_s
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    else
      artist
    end
  end

  def credits
    location
  end

  def source_url
    i_n = inventory_no.delete_prefix('IMAI.W.')

    if i_n.size < 4
      i_n = i_n.rjust(4, '0')
    end

    "https://stiftung-imai.de/videos/katalog/medium/#{i_n}"
  end

  private

  def artist_names
    artist_nested.map { |artist|
      artist['name']
    }
  end
end
