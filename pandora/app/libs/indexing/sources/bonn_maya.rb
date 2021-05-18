class Indexing::Sources::BonnMaya < Indexing::SourceSuper
  def records
    document.xpath('//medium')
  end

  def record_id
    record.xpath('./entity/id/text()')
  end

  def record_object_id
    [name, Digest::SHA1.hexdigest(record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/id/text()').to_a.join('|'))].join('-')
  end


  def path
    "#{record.at_xpath('.//entity/image-path[@style="original"]/text()')}".gsub(/https:\/\/classicmayan.kor.de.dariah.eu\/media\/download\/original\//,'media/maximize/')
  end

  # titel
  def title
    "#{record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/title/text()')} (#{record.at_xpath('.//entity/fields/field[@name="image_description"]/text()')})".gsub(/ \(\)/,'')
  end

  # standort
  def location
   locations = (record.xpath('.//relationships/artefact-is-was-located-in-place/to/place/entity/title/text()') + record.xpath('.//relationships/collection-holds-held-artefact/from/collection/entity/title/text()')).to_a
   add_geodata(locations)
  end

  def discoveryplace
    places = record.xpath('.//relationships/artefact-originates-from-provenance/to/provenance/entity/title/text()').to_a
    add_geodata(places)
  end

  # datierung
  def date
    "#{record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="date"]/text()')} | Fotografie: #{record.xpath('.//entity/datings/dating/text()')}".gsub(/\A \| /,'').gsub(/Fotografie: \z/,'')
  end

  def photographer
	  "#{record.xpath('.//entity/fields/field[@name="creator"]/text()')} (#{record.xpath('.//entity/datings/dating/text()')})".gsub(/ \(\)/,'')
  end

  def size
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="dimensions"]/text()')
  end

  def material
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="material"]/text()')
  end

  def technique
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="technique"]/text()')
  end  

  def genre
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="artefact_type"]/text()')
  end

  def description	
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="description"]/text()')
  end

  def publication
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="artefact_publication"]/text()')
  end

  def annotation
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="note"]/text()')
  end

  def comment
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/comment/text()')
  end

  def rights_reproduction
    "#{record.at_xpath('.//entity/fields/field[@name="rights_holder"]/text()')} | #{record.at_xpath('.//entity/fields/field[@name="license"]/text()')}".gsub(/\A \| /,'').gsub(/ \| \z/,'')
  end

  def culture
    "#{record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="culture"]/text()')},http://vocab.getty.edu/page/aat/#{record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="culture_in_aat"]/text()')}"
  end

  def inventory_no
    record.xpath('.//relationships/artefact-is-depicted-by-medium/from/artefact/entity/fields/field[@name="inventory_no"]/text()')
  end
  
  def part_of
    number = record.xpath('count(.//relationships/artefact-has-artefact-part)')
    (1..(number.to_i)).map{ |index|
    "#{record.xpath(".//relationships/artefact-has-artefact-part[#{index}]/to/artefact/entity/title/text()")},https:\/\/classicmayan.kor.de.dariah.eu\/blaze#\/entities/#{record.xpath(".//relationships/artefact-has-artefact-part[#{index}]/to/artefact/entity/id/text()")}"
    }
  end

  def related_works
    number = record.xpath('count(.//relationships/artefact-is-related-with-artefact)')
    (1..(number.to_i)).map{ |index|	  
    "#{record.xpath(".//relationships/artefact-is-related-with-artefact[#{index}]/to/artefact/entity/title/text()")},https:\/\/classicmayan.kor.de.dariah.eu\/blaze#\/entities/#{record.xpath(".//relationships/artefact-is-related-with-artefact[#{index}]/to/artefact/entity/id/text()")}"
    }
  end

  def source_url
    "https:\/\/classicmayan.kor.de.dariah.eu\/blaze#\/entities/#{record.xpath('./entity/id/text()')}"	
  end

  private

  def add_geodata(values)
    values.map{ |value|
      geonames = record.xpath('.//relationships/artefact-is-was-located-in-place/to/place/entity/fields/field[@name="geo_names"]/text()')
      getty_tgn = record.xpath('.//relationships/artefact-is-was-located-in-place/to/place/entity/fields/field[@name="getty_tgn"]/text()') 
      if !geonames.blank? && !getty_tgn.blank?
        "#{value} (Geonames: %#{geonames},https://www.geonames.org/#{geonames}%) (Getty TGN: %#{getty_tgn},http://www.getty.edu/vow/TGNFullDisplay?find=&place=&nation=&english=Y&subjectid=#{getty_tgn}%)"
      elsif !geonames.blank? && getty_tgn.blank?
	"#{value} (Geonames: %#{geonames},https://www.geonames.org/#{geonames}%)" 
      elsif geonames.blank? && !getty_tgn.blank?
        "#{value} (Getty TGN: %#{getty_tgn},http://www.getty.edu/vow/TGNFullDisplay?find=&place=&nation=&english=Y&subjectid=#{getty_tgn}%)"
      else
        "#{value}"
      end
    }
  end
end
