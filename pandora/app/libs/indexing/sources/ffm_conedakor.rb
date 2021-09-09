class Indexing::Sources::FfmConedakor < Indexing::SourceSuper
  def records
    Indexing::XmlReaderNodeSet.new(document, "work", "//mediums/medium")
  end

  def record_id
    [record.xpath('.//id/text()'), record.xpath('.//ancestor::work/id/text()')]
  end

  def record_object_id
    if !record.xpath('.//ancestor::work/parts/part/id/text()').empty?
      object_id = record.xpath('.//ancestor::work/parts/part/id/text()')
    else
      object_id = record.xpath('.//ancestor::work/id/text()')
    end
    [name, Digest::SHA1.hexdigest((object_id).to_a.join('|'))].join('-')
  end

  def path
    return miro if miro?

    "#{record.xpath('.//imagePath/text()')}".sub(/https:\/\/kor.uni-frankfurt.de\/media\/download\/icon\//, '')
  end

  # künstler
  def artist
    if (number = record.xpath('.//ancestor::work/creators').length) > 0
      (1..(number.to_i)).map{ |index| 
        datings = (dating = record.xpath(".//ancestor::work/creators[#{index}]/datings/dating[@event=\"Lebensdaten\"]/text()")).blank? ? record.xpath(".//ancestor::work/creators[#{index}]/datings/dating[@event=\"Geburtsjahr\"]/text()") : dating

        str = "#{record.xpath(".//ancestor::work/creators[#{index}]/title/text()")} (#{datings})" 
       
        if !(birthplace = record.xpath(".//ancestor::work/creators[#{index}]/birthPlace/title/text()")).empty?
          str << " * #{birthplace}" 
        end 
        if !(placeOfDeath = record.xpath(".//ancestor::work/creators[#{index}]/placeOfDeath/title/text()")).empty?
          str << " + #{placeOfDeath}" 
        end 
        if !(record.xpath(".//ancestor::work/creators[#{index}]/teachers/title/text()")).empty?
          teachers = [record.xpath(".//ancestor::work/creators[#{index}]/teachers/title/text()")].join(" | ")
          str << " | SchülerIn von #{teachers}" 
        end
        if !(copy = record.xpath('.//ancestor::work/properties/property[@name="nach"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="Kopie nach"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="Nach"]/text()')).empty?
        str << " | nach #{copy}" 
        end
      str
      }
    end
  end

  def artist_normalized
    an = record.xpath('.//ancestor::work/creators/title/text()').map { |a|
      a.to_s.sub(/ \(.*/, '').split(', ').reverse.join(' ')
    }
    super(an)
  end

  def artist_information
    record.xpath('.//ancestor::work/creators/comment/text()')
  end

  def authority_files_artist
    number = record.xpath('count(.//ancestor::work/creators)')
    (1..(number.to_i)).map{ |index|
      "Wikidata: #{record.xpath(".//ancestor::work/creators[#{index}]/fields/field[@name=\"wikidata_id\"]/text()")},https:\/\/www.wikidata.org\/wiki\/#{record.xpath(".//ancestor::work/creators[#{index}]/fields/field[@name=\"wikidata_id\"]/text()")}"
    }
  end


  # titel
  def title
    "#{record.xpath('.//ancestor::work/title/text()')} [#{record.xpath('.//ancestor::work/distinction/text()')} (#{record.xpath('.//ancestor::work/parts/part/title/text()')})], #{record.xpath('.//properties/property[@name="title"][1]/text()')}".gsub(/ \(\)/,'').gsub(/ \[\]/,'').gsub(/, \z/,'')
  end

  # datierung
  def date
    if (number = record.xpath('.//ancestor::work/datings/dating').length) > 0
      (1..(number.to_i)).map{ |index| "#{record.xpath(".//ancestor::work/datings/dating[#{index}]/text()")} (#{record.xpath(".//ancestor::work/datings/dating[#{index}]/@event")})".gsub(/ \(Datierung\)/,'')  
      }.join(" | ")
    else
      record.xpath('.//ancestor::work/parts/part/datings/dating/text()').to_a.join(" | ")
    end
  end

  def date_range
    if !record.xpath(".//ancestor::work/datings/dating[1]").empty?
      from = record.xpath(".//ancestor::work/datings/dating[1]/@from-day").to_s.to_i
      to = record.xpath(".//ancestor::work/datings/dating[1]/@to-day").to_s.to_i

      from = Date.jd(from)
      to = Date.jd(to)

      if from.year > 9999 || to.year > 9999
        return nil
      end

      if from && to && from <= to
        super(HistoricalDating::Range.new(from, to))
      end
    end
  end

  # standort
  def location
    if !(record.xpath('.//ancestor::work/locatedIn') && record.xpath('.//ancestor::work/sites')).blank?
     ort = (stadt = (record.xpath('.//ancestor::work/locatedIn/location/title/text()'))).blank? ? record.xpath('.//ancestor::work/locatedIn/distinction/text()') : stadt
     location = ort.blank? ? record.xpath('.//ancestor::work/sites/site/title/text()') : ort
    "#{location}, #{record.xpath('.//ancestor::work/locatedIn/title/text()')} (#{record.xpath('.//ancestor::work/locatedIn/comment/text()')})".gsub(/_{3,}/, '').gsub(/ \(\)/,'').gsub(/ \( \)/,'').gsub(/, \z/,'').gsub(/\A, /,'') || record.xpath('.//ancestor::work/properties/property[@name="Standort*"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="Aufbewahrung*"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="*Besitz*"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="Befindet sich in"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="Privatbesitz"]/text()')
    else
      record.xpath('.//ancestor::work/parts/part/location/text()')
    end
  end

  # material
  def material
    record.xpath('.//ancestor::work/fields/field[@name="material"]/text()')
  end

  # groesse
  def size
    record.xpath('.//ancestor::work/fields/field[@name="dimensions"]/text()')
  end

  def portrayal
    "#{record.xpath('.//ancestor::work/portrayal/title/text()')}, #{record.xpath('.//ancestor::work/portrayal/comment/text()')}".gsub(/, \z/,'')
  end

  def commissioner
    "#{record.xpath('.//ancestor::work/commissioner/title/text()')}, #{record.xpath('.//ancestor::work/commissioner/comment/text()')}".gsub(/, \z/,'')
  end

  # gattung
  def genre
    record.xpath('.//ancestor::work/subtype/text()')
  end

  # abbildungsnachweis
  def credits
     number = record.xpath('.//credits/credit').length
    (1..(number.to_i)).map{ |index|
      ["#{record.xpath(".//credits/credit[#{index}]/author/text()")}".split(', ').reverse.join(' '), "#{record.xpath(".//credits/credit[#{index}]/title/text()")} (#{record.xpath(".//sources/source[#{index}]/literature/distinction/text()")})", record.xpath(".//credits/credit[#{index}]/volume/text()"), "hrsg. von " + "#{record.xpath(".//credits/credit[#{index}]/editor/text()")}".split(', ').reverse.join(' '), "#{record.xpath(".//credits/credit[#{index}]/placeOfPublication/text()")}: #{record.xpath(".//credits/credit[#{index}]/publisher/text()")}".gsub(/: \z/,'').gsub(/\A: /,'') + " #{record.xpath(".//credits/credit[#{index}]/yearOfPublication/text()")}", record.xpath(".//credits/credit[#{index}]/comment/text()"), record.xpath(".//credits/credit[#{index}]/internalReferences/internalReference/text()")].reject(&:empty?).join(", ").gsub(/ hrsg. von ,/, '').gsub(/, hrsg. von \z/,'').gsub(/  /,'').gsub(/ \(\)/,'').gsub(/,\z/,'').gsub(/ *\z/,'').gsub(/ , /,', ') << ".".gsub(/..\z/, '.')
    }
  end

  def literature 
    number = record.xpath('.//ancestor::work/illustrations').length
    (1..(number.to_i)).map{ |index|
      ["#{record.xpath(".//ancestor::work/illustrations[#{index}]/author/title/text()")}".split(', ').reverse.join(' '), "#{record.xpath(".//ancestor::work/illustrations[#{index}]/title/text()")} (#{record.xpath(".//ancestor::work/illustrations[#{index}]/distinction/text()")})", record.xpath(".//ancestor::work/illustrations[#{index}]/fields[1]/field[@name=\"Band\"]/text()"), "hrsg. von " + "#{record.xpath(".//ancestor::work/illustrations[#{index}]/publisher/title/text()")}".split(', ').reverse.join(' '), "#{record.xpath(".//ancestor::work/illustrations[#{index}]/publishedIn/title/text()")}: #{record.xpath(".//ancestor::work/illustrations[#{index}]/fields/field[@name=\"publisher\"]/text()")}".gsub(/: \z/,'').gsub(/\A: /,'') + " #{record.xpath(".//ancestor::work/illustrations[#{index}]/fields/field[@name=\"year_of_publication\"]/text()")}", record.xpath(".//ancestor::work/illustrations[#{index}]/comment/text()")].reject(&:empty?).join(", ").gsub(/ hrsg. von ,/, '').gsub(/, hrsg. von \z/,'').gsub(/  /,' ').gsub(/ \(\)/,'').gsub(/,\z/,'').gsub(/ *\z/,'') << ".".gsub(/..\z/, '.')
    }
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def rights_reproduction
    if record.xpath('contains(collection, "HS Media 4 CC-BY-SA")')
      license = "CC-BY-SA"
    elsif record.xpath('contains(collection, "HS Media 5 CC-BY-NC-ND")')
      license = "CC-BY-NC-ND"
    else
      license = ""
    end

    "#{record.xpath('.//photographers/title/text()')} (#{license})".gsub(/ \(\)/, '')
  end

  def keyword
    record.xpath('.//ancestor::work/tags/tag/text()')
  end

  def comment
    record.xpath('.//ancestor::work/comment/text()')
  end

  def addition
    record.xpath('.//ancestor::work/properties/property[@name="Zusatz"]/text()')
  end

  def origin
    record.xpath('.//ancestor::work/properties/property[@name="Herkunft"]/text()')
  end

  def provenance
    record.xpath('.//ancestor::work/properties/property[@name="Provenienz"]/text()')
  end

  def signature
    record.xpath('.//ancestor::work/properties/property[@name="Sig*"]/text()')
  end
  
  def inventory_no
    record.xpath('.//ancestor::work/properties/property[@name="Inv*"]/text()')
  end

  def labeled
    record.xpath('.//ancestor::work/properties/property[@name="Bez.*"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="Bezeichn*"]/text()')
  end

  def annotation
    record.xpath('.//ancestor::work/properties/property[@name="Anmerkung"]/text()')
  end

  def origin_point
    record.xpath('.//ancestor::work/properties/property[@name="Entstehung*"]/text()') || record.xpath('.//ancestor::work/properties/property[@name="Entstanden*"]/text()')
  end

  def inscription
    record.xpath('.//ancestor::work/properties/property[@name="Inschrift"]/text()')
  end

  def text
    if !(text = record.xpath('.//ancestor::work/properties/property[@name="Bibelstelle"]/text()')).empty?
      "#{text} (Bibelstelle)"
    end
  end
 
  def part_of
    number = record.xpath('.//ancestor::work/parts/part/properties/property').length
    arr = []
    arr << "#{record.xpath('.//ancestor::work/parts/part/title/text()')}"
    arr << "#{record.xpath('.//ancestor::work/parts/part/datings/dating/text()')}"
    arr << "#{record.xpath('.//ancestor::work/parts/part/location/text()')}"
    arr << "#{record.xpath('.//ancestor::work/parts/part/distinction/text()')}"
    arr << "#{record.xpath('.//ancestor::work/parts/part/fields/field[@name="google_maps"]/text()')}"
    arr << (1..(number.to_i)).map{ |index| 
    "#{record.xpath(".//ancestor::work/parts/part/properties/property[#{index}]/text()")} (#{record.xpath(".//ancestor::work/parts/part/properties/property[#{index}]/@name")})"}
    arr << "#{record.xpath('.//ancestor::work/parts/part/fields/field[@name="material"]/text()')}"
    arr << "#{record.xpath('.//ancestor::work/parts/part/fields/field[@name="dimensions"]/text()')}"
    arr << "#{record.xpath('.//ancestor::work/parts/part/comment/text()')}"
    arr << record.xpath('.//ancestor::work/parts/part/creators/text()').to_a.join(" | ")
    arr.flatten
  end

end
