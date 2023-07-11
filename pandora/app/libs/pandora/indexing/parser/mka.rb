class Pandora::Indexing::Parser::Mka < Pandora::Indexing::Parser::XmlReader
  def initialize(source)
    super(
      source,
      record_node_name: 'lido:lido',
      namespaces: true,
      namespace_uri: 'http://www.lido-schema.org'
    )
  end

  def record_id
    record.at_xpath('./lido:administrativeMetadata/lido:recordWrap/lido:recordID/text()').to_s
  end

  def inventory_no
    record.at_xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:repositoryWrap/lido:repositorySet/lido:workID/text()').to_s
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
    artists = record.xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventActor/lido:actorInRole')
    return unless artists

    artists.each do |artist|
      a = {}
      a['name'] = artist.xpath('./lido:actor/lido:nameActorSet/lido:appellationValue').map(&:text).uniq.join(', ')
      a['gnd_url'] = artist.at_xpath("./lido:actor/lido:actorID[@lido:source='Gemeinsame Normdatei (GND)']/text()").to_s

      nested_artists << a
    end

    nested_artists
  end

  def artist_normalized
    super(artist_names)
  end

  def title
    record.xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:titleWrap/lido:titleSet/lido:appellationValue').text
  end

  def date
    record.at_xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventDate/lido:displayDate/text()').to_s
  end

  def date_range
    super(date)
  end

  def country
    record.at_xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventPlace/lido:displayPlace/text()').to_s
  end

  def genre
    genres = record.xpath("./lido:descriptiveMetadata/lido:objectClassificationWrap/lido:objectWorkTypeWrap/lido:objectWorkType/lido:term").map(&:text) + record.xpath("./lido:descriptiveMetadata/lido:objectClassificationWrap/lido:classificationWrap/lido:classification[@lido:type='Sachgruppe']/lido:term").map(&:text)

    genres.uniq
  end

  def duration
    duration = record.at_xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:objectMeasurementsWrap/lido:objectMeasurementsSet/lido:displayObjectMeasurements')

    duration.text.delete_prefix('Dauer: ') if duration
  end

  def material_technique
    record.xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventMaterialsTech/lido:displayMaterialsTech/text()').map(&:text).uniq
  end

  def keywords
    keywords = record.at_xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:objectDescriptionWrap/lido:objectDescriptionSet/lido:descriptiveNoteValue')

    keywords.text.split(', ') if keywords
  end

  def location
    'Stiftung IMAI - Inter Media Art Institute'
  end

  def rights_reproduction
    record.at_xpath('./lido:administrativeMetadata/lido:recordWrap/lido:recordRights/lido:rightsType/lido:term/text()').to_s
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
