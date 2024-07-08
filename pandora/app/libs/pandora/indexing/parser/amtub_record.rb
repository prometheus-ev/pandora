class Pandora::Indexing::Parser::AmtubRecord < Pandora::Indexing::Parser::Record
  def record_id
    record.at_xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:repositoryWrap/lido:repositorySet/lido:workID/text()').to_s
  end

  def path
    record.xpath("./lido:administrativeMetadata/lido:resourceWrap/lido:resourceSet/lido:resourceRepresentation[@lido:type='provided_image']/lido:linkResource/text()").to_s.gsub(/https:\/\/architekturmuseum.ub.tu-berlin.de\//, '')
  end

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
      a['gnd_url'] = artist.at_xpath("./lido:actor/lido:actorID[@lido:source='GND']/text()").to_s

      a['dating'] = "#{artist.xpath('./lido:actor/lido:vitalDatesActor/lido:earliestDate/text()')} - #{artist.xpath('./lido:actor/lido:vitalDatesActor/lido:earliestDate/text()')}".sub(/( - )/, '')

      nested_artists << a
    end

    nested_artists
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    @artist_normalized = @artist_parser.normalize(artist_names)
  end

  def title
    record.xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:titleWrap/lido:titleSet/lido:appellationValue').text
  end

  def date
    record.xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventDate/lido:displayDate/text()').to_s
  end

  def date_range
    return @date_range if @date_range

    @date_range = @date_parser.date_range(date)
  end

  def location
    record.xpath('./lido:descriptiveMetadata/lido:objectRelationWrap/lido:subjectWrap/lido:subjectSet/lido:subject/lido:subjectPlace/lido:displayPlace/text()')
  end

  def institution
    "Architekturmuseum der Technischen Universität Berlin"
  end

  def material
    record.xpath('./lido:descriptiveMetadata/lido:eventWrap/lido:eventSet/lido:event/lido:eventMaterialsTech/lido:displayMaterialsTech/text()')
  end

  def size
    record.at_xpath('./lido:descriptiveMetadata/lido:objectIdentificationWrap/lido:objectMeasurementsWrap/lido:objectMeasurementsSet/lido:displayObjectMeasurements/text()')
  end

  def genre
    record.xpath('./lido:descriptiveMetadata/lido:objectClassificationWrap/lido:objectWorkTypeWrap/lido:objectWorkType/lido:term/text()')
  end

  def credits
    record.at_xpath('./lido:administrativeMetadata/lido:rightsWorkWrap/lido:rightsWorkSet/lido:creditLine/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  # Since rights_reproduction_nested exists, rights_reproduction
  # is only used for sorting via rights_reproduction.raw.
  def rights_reproduction
    rights_reproduction_nested.map {|rights_reproduction|
      rights_reproduction['license']
    }.join(' | ')
  end

  def rights_reproduction_nested
    nested_rights_reproduction = {}
    rights_type = record.at_xpath('./lido:administrativeMetadata/lido:rightsWorkWrap/lido:rightsWorkSet/lido:rightsType')

    rights_reproduction_license = rights_type.at_xpath('./lido:term/text()').to_s
    rights_reproduction_license_url = rights_type.at_xpath('./lido:conceptID/text()').to_s

    nested_rights_reproduction['license'] = rights_reproduction_license
    nested_rights_reproduction['license_url'] = rights_reproduction_license_url

    [nested_rights_reproduction]
  end

  def source_url
    record.at_xpath('./lido:objectPublishedID/text()')
  end

  private

    def artist_names
      artist_nested.map do |artist|
        artist['name']
      end
    end
end
