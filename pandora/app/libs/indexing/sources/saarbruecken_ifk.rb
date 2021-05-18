class Indexing::Sources::SaarbrueckenIfk < Indexing::SourceSuper
  def records
    document.xpath("//row/relationships/entities/media")
  end

  def record_id
    record.xpath(".//id/text()")
  end

  def path
    medium_location = sprintf("%06d", record.at_xpath(".//id/text()").to_s).scan(/.../).join("/")
    "000/#{medium_location}/image.jpg"
  end

  def artist
    artists = record.xpath("ancestor::row/relationships/relations[id=30]")
    artists.map { |i|
      "#{i.xpath('preceding-sibling::entities/name/text()')} (#{i.xpath('preceding-sibling::entities/entity_datings/dating_string/text()').to_a.join(" - ")})".gsub(/ \(\)/, '')
    }
  end

  def artist_normalized
    an = record.xpath('ancestor::row/relationships/relations[id=30]/preceding-sibling::entities/name/text()').map { |a|
      a.to_s.strip.split(/, /).reverse.join(" ")
    }
    super(an)
  end

  def title
    name = record.xpath('ancestor::row/name/text()').to_s
    distinct_name = record.xpath('ancestor::row/distinct_name/text()').to_s

    properties = record.at_xpath('ancestor::relationships/properties/text()').to_s
    # The raw properties string in XML is encoded with UTF-8 literals. YAML escapes theses literals again when the
    # string is loaded. In order to be displayed correctly, the UTF-8 literals have to be transformed to a byte string
    # and then be encoded to UTF-8 again to avoid escaping.
    properties_yaml = YAML.load(properties.gsub(/\\x../) {|s| [s[2..-1].hex].pack("C")}.force_encoding(Encoding::UTF_8))

    if (properties_yaml && properties_yaml.kind_of?(Array) && !properties_yaml.empty?)
      properties = ", " + properties_yaml.join("| ").force_encoding(Encoding::UTF_8)
    else
      properties = ""
    end

    "#{name} [#{distinct_name}]#{properties}".gsub(/ \[\]/, '')
  end

  def date
    record.xpath('ancestor::row/entity_datings/dating_string/text()')
  end

  def location
    locations = record.xpath('ancestor::row/relationships/relations[id=25]')
    locations.map { |i|
      "#{i.xpath('preceding-sibling::entities/name/text()')}, #{i.xpath('preceding-sibling::entities/distinct_name/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
    }
  end

  def material
    "#{record.xpath('ancestor::row/attachment/dataset/material-technique/text()')}, #{record.xpath('ancestor::row/attachment/dataset/material/text()')}".gsub(/\A, /, '').gsub(/, \Z/, '')
  end

  def size
    record.xpath('ancestor::row/attachment/dataset/dimensions/text()')
  end

  def addition
    record.xpath('ancestor::row/attachment/properties/property').map{ |property|
      property.children.to_a.reverse.join(": ")
    }
  end

  def credits
    credits = record.xpath('ancestor::row/relationships/relations[id=45]')
    credits.map{ |i|
      "#{i.xpath('preceding-sibling::entities/name/text()')}, #{i.xpath('preceding-sibling::entities/attachment/dataset/publisher/text()')} #{i.xpath('preceding-sibling::entities/attachment/dataset/year-of-publication/text()')}, #{i.xpath('preceding-sibling::entities/attachment/dataset/edition/text()')}, #{i.xpath('preceding-sibling::properties/text()')}".gsub(/, , /, ', ').gsub(/\A, /, '').gsub(/, \z/, '').gsub(/--- \n- /, '')
    }
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath('ancestor::row/relationships/relations[id=35]/preceding-sibling::entities/name[1]/text()')
  end

  def isbn
    record.xpath('ancestor::row/relationships/relations[id=45]/preceding-sibling::entities/attachment/dataset/isbn/text()')
  end

  def comment
    record.xpath('ancestor::row/comment/text()')
  end

  def based_on
    record.xpath('ancestor::row/relationships/relations[id=26]/preceding-sibling::entities/name[1]/text()')
  end

  def adopted_from
    record.xpath('ancestor::row/relationships/relations[id=21]/preceding-sibling::entities/name[1]/text()')
  end

  def costumer
    record.xpath('ancestor::row/relationships/relations[id=38]/preceding-sibling::entities/name[1]/text()')
  end

  def text
    unless (text = record.xpath('ancestor::row/relationships/relations[id=39]/preceding-sibling::entities/attachment/dataset/text/text()')).blank?
      "#{record.xpath('ancestor::row/relationships/relations[id=39]/preceding-sibling::entities/name[1]/text()')}: #{text}"
    end
  end

  def venue
    record.xpath('ancestor::row/relationships/relations[id=43]/preceding-sibling::entities/name[1]/text()')
  end

  def engraver
    record.xpath('ancestor::row/relationships/relations[id=58]/preceding-sibling::entities/name[1]/text()')
  end

  def group_works
    record.xpath('ancestor::row/relationships/relations[id=5]/preceding-sibling::entities/name[1]/text()')
  end

  def made_by
    record.xpath('ancestor::row/relationships/relations[id=37]/preceding-sibling::entities/name[1]/text()')
  end
end
