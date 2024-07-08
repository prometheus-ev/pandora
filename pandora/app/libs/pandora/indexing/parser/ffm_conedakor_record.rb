class Pandora::Indexing::Parser::FfmConedakorRecord < Pandora::Indexing::Parser::Record
  def record_id
    [record.xpath('./id/text()').to_s, object.xpath('./id/text()').to_s]
  end

  def record_object_id
    if !record.xpath("./parts/part/id/text()").empty?
      object_id = record.xpath("./parts/part/id/text()").to_s
    else
      if object.xpath("./mediums/medium").length > 1
        object_id = object.xpath("./id/text()").to_s
      end
    end

    if object_id.blank?
      nil
    else
      [name, Digest::SHA1.hexdigest(object_id)].join("-")
    end
  end

  def record_object_id_count
    @record_object_id_count[record_object_id]
  end

  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    "#{record.xpath('./imagePath/text()')}".sub(/https:\/\/kor.uni-frankfurt.de\/media\/images\/icon\//, '')
  end

  def artist
    if (number = object.xpath("./creators").length) > 0
      (1..(number.to_i)).map do |index|
        datings = if (dating = object.xpath("./creators[#{index}]/datings/dating[@event=\"Lebensdaten\"]/   text()")).blank?
          object.xpath("./creators[#{index}]/datings/dating[@event=\"Geburtsjahr\"]/            text()")
        else
          dating
        end

        str = "#{object.xpath("./creators[#{index}]/title/text()")} (#{datings})"

        if !(birthplace = object.xpath("./creators[#{index}]/birthPlace/title/text()")).empty?
          str << " * #{birthplace}"
        end

        if !(placeOfDeath = object.xpath("./creators[#{index}]/placeOfDeath/title/text()")).empty?
          str << " + #{placeOfDeath}"
        end

        if !(object.xpath("./creators[#{index}]/teachers/title/text()")).empty?
          teachers = [object.xpath("./creators[#{index}]/teachers/title/text()")].join(" | ")
          str << " | SchülerIn von #{teachers}"
        end

        if !(copy = object.xpath('./properties/property[@name="nach"]/text()') ||
            object.xpath('./properties/property[@name="Kopie nach"]/text()') ||
            object.xpath('./properties/property[@name="Nach"]/text()')).empty?
          str << " | nach #{copy}"
        end

        str
      end
    end
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = object.xpath('./creators/title/text()').map do |a|
      a.to_s.sub(/ \(.*/, '').split(', ').reverse.join(' ')
    end

    @artist_normalized = @artist_parser.normalize(an)
  end

  def artist_information
    object.xpath('./creators/comment/text()')
  end

  def authority_files_artist
    number = object.xpath('count(./creators)')
    (1..(number.to_i)).map do |index|
      "Wikidata: #{object.xpath("./creators[#{index}]/fields/field[@name=\"wikidata_id\"]/text()")},https:\/\/www.wikidata.org\/wiki\/#{object.xpath("./creators[#{index}]/fields/field[@name=\"wikidata_id\"]/text()")}"
    end
  end

  def title
    "#{object.xpath('./title/text()')} [#{object.xpath('./distinction/text()')} (#{object.xpath('./parts/part/title/text()')})], #{record.xpath('./properties/property[@name="title"][1]/text()')}".gsub(/ \(\)/, '').gsub(/ \[\]/, '').gsub(/, \z/, '')
  end

  def date
    if (number = object.xpath('./datings/dating').length) > 0
      (1..(number.to_i)).map{|index|
        "#{object.xpath("./datings/dating[#{index}]/text()")} (#{object.xpath("./datings/dating[#{index}]/@event")})".gsub(/ \(Datierung\)/, '')
      }.join(" | ")
    else
      object.xpath('./parts/part/datings/dating/text()').to_a.join(" | ")
    end
  end

  def date_range
    return @date_range if @date_range

    if !object.xpath("./datings/dating[1]").empty?
      from = object.xpath("./datings/dating[1]/@from-day").to_s.to_i
      to = object.xpath("./datings/dating[1]/@to-day").to_s.to_i

      from = Date.jd(from)
      to = Date.jd(to)

      if from.year > 9999 || to.year > 9999
        return nil
      end

      if from && to && from <= to
        @date_range = @date_parser.date_range(HistoricalDating::Range.new(from, to))
      end
    end
  end

  def location
    if !(object.xpath('./locatedIn') && object.xpath('./sites')).blank?
      ort = (stadt = (object.xpath('./locatedIn/location/title/text()'))).blank? ? object.xpath('./locatedIn/distinction/text()') : stadt

      location = if ort.blank?
        object.xpath('./sites/site/title/text()')
      else
        ort
      end

      "#{location}, #{object.xpath('./locatedIn/title/text()')} (#{object.xpath('./locatedIn/comment/text()')})".gsub(/_{3,}/, '').gsub(/ \(\)/, '').gsub(/ \( \)/, '').gsub(/, \z/, '').gsub(/\A, /, '') ||
        object.xpath('./properties/property[@name="Standort*"]/text()') ||
        object.xpath('./properties/property[@name="Aufbewahrung*"]/text()') ||
        object.xpath('./properties/property[@name="*Besitz*"]/text()') ||
        object.xpath('./properties/property[@name="Befindet sich in"]/text()') ||
        object.xpath('./properties/property[@name="Privatbesitz"]/text()')
    else
      object.xpath('./parts/part/location/text()')
    end
  end

  def material
    object.xpath('./fields/field[@name="material"]/text()')
  end

  def size
    object.xpath('./fields/field[@name="dimensions"]/text()')
  end

  def portrayal
    "#{object.xpath('./portrayal/title/text()')}, #{object.xpath('./portrayal/comment/text()')}".gsub(/, \z/, '')
  end

  def commissioner
    "#{object.xpath('./commissioner/title/text()')}, #{object.xpath('./commissioner/comment/text()')}".gsub(/, \z/, '')
  end

  def genre
    object.xpath('./subtype/text()')
  end

  def credits
    number = record.xpath('.//credits/credit').length

    (1..(number.to_i)).map do |index|
      ["#{record.xpath(".//credits/credit[#{index}]/author/text()")}".split(', ').reverse.join(' '), "#{record.xpath(".//credits/credit[#{index}]/title/text()")} (#{record.xpath(".//sources/source[#{index}]/literature/distinction/text()")})", record.xpath(".//credits/credit[#{index}]/volume/text()"), "hrsg. von " + "#{record.xpath(".//credits/credit[#{index}]/editor/text()")}".split(', ').reverse.join(' '), "#{record.xpath(".//credits/credit[#{index}]/placeOfPublication/text()")}: #{record.xpath(".//credits/credit[#{index}]/publisher/text()")}".gsub(/: \z/, '').gsub(/\A: /, '') + " #{record.xpath(".//credits/credit[#{index}]/yearOfPublication/text()")}", record.xpath(".//credits/credit[#{index}]/comment/text()"), record.xpath(".//credits/credit[#{index}]/internalReferences/internalReference/text()")].reject(&:empty?).join(", ").gsub(/ hrsg. von ,/, '').gsub(/, hrsg. von \z/, '').gsub(/  /, '').gsub(/ \(\)/, '').gsub(/,\z/, '').gsub(/ *\z/, '').gsub(/ , /, ', ') << ".".gsub(/..\z/, '.')
    end
  end

  def literature
    number = object.xpath('.//illustrations').length

    (1..(number.to_i)).map do |index|
      ["#{object.xpath("./illustrations[#{index}]/author/title/text()")}".split(', ').reverse.join(' '), "#{object.xpath("./illustrations[#{index}]/title/text()")} (#{object.xpath("./illustrations[#{index}]/distinction/text()")})", object.xpath("./illustrations[#{index}]/fields[1]/field[@name=\"Band\"]/text()"), "hrsg. von " + "#{object.xpath("./illustrations[#{index}]/publisher/title/text()")}".split(', ').reverse.join(' '), "#{object.xpath("./illustrations[#{index}]/publishedIn/title/text()")}: #{object.xpath("./illustrations[#{index}]/fields/field[@name=\"publisher\"]/text()")}".gsub(/: \z/, '').gsub(/\A: /, '') + " #{object.xpath("./illustrations[#{index}]/fields/field[@name=\"year_of_publication\"]/text()")}", object.xpath("./illustrations[#{index}]/comment/text()")].reject(&:empty?).join(", ").gsub(/ hrsg. von ,/, '').gsub(/, hrsg. von \z/, '').gsub(/  /, ' ').gsub(/ \(\)/, '').gsub(/,\z/, '').gsub(/ *\z/, '') << ".".gsub(/..\z/, '.')
    end
  end

  def rights_work
    if @warburg_parser.is_record_id_a_rights_work_warburg_record_id?(record_id, name)
      @warburg_parser.rights_work_warburg
    elsif @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    license = ''

    if record.xpath('contains(collection, "HS Media 4 CC-BY-SA")')
      license = "CC-BY-SA"
    elsif record.xpath('contains(collection, "HS Media 5 CC-BY-NC-ND")')
      license = "CC-BY-NC-ND"
    end

    "#{record.xpath('.//photographers/title/text()')} (#{license})".gsub(/ \(\)/, '')
  end

  def keyword
    object.xpath('.//tags/tag/text()')
  end

  def comment
    object.xpath('.//comment/text()')
  end

  def addition
    object.xpath('.//properties/property[@name="Zusatz"]/text()')
  end

  def origin
    object.xpath('.//properties/property[@name="Herkunft"]/text()')
  end

  def provenance
    object.xpath('.//properties/property[@name="Provenienz"]/text()')
  end

  def signature
    object.xpath('.//properties/property[@name="Sig*"]/text()')
  end

  def inventory_no
    object.xpath('.//properties/property[@name="Inv*"]/text()')
  end

  def labeled
    object.xpath('.//properties/property[@name="Bez.*"]/text()') ||
      object.xpath('.//properties/property[@name="Bezeichn*"]/text()')
  end

  def annotation
    object.xpath('.//properties/property[@name="Anmerkung"]/text()')
  end

  def origin_point
    object.xpath('.//properties/property[@name="Entstehung*"]/text()') ||
      object.xpath('.//properties/property[@name="Entstanden*"]/text()')
  end

  def inscription
    object.xpath('.//properties/property[@name="Inschrift"]/text()')
  end

  def text
    if !(text = object.xpath('.//properties/property[@name="Bibelstelle"]/text()')).empty?
      "#{text} (Bibelstelle)"
    end
  end

  def part_of
    number = object.xpath('.//parts/part/properties/property').length
    arr = []

    arr << "#{object.xpath('.//parts/part/title/text()')}"
    arr << "#{object.xpath('.//parts/part/datings/dating/text()')}"
    arr << "#{object.xpath('.//parts/part/location/text()')}"
    arr << "#{object.xpath('.//parts/part/distinction/text()')}"
    arr << "#{object.xpath('.//parts/part/fields/field[@name="google_maps"]/text()')}"

    arr << (1..(number.to_i)).map do |index|
      a = object.xpath(".//parts/part/properties/property[#{index}]/text()")
      b = object.xpath(".//parts/part/properties/property[#{index}]/@name")
      "#{a} (#{b})"
    end

    arr << "#{object.xpath('.//parts/part/fields/field[@name="material"]/text()')}"
    arr << "#{object.xpath('.//parts/part/fields/field[@name="dimensions"]/text()')}"
    arr << "#{object.xpath('.//parts/part/comment/text()')}"
    arr << object.xpath('.//parts/part/creators/text()').to_a.join(" | ")

    arr.flatten
  end
end
