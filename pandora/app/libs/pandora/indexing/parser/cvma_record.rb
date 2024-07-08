class Pandora::Indexing::Parser::CvmaRecord < Pandora::Indexing::Parser::Record
  def record_id
    record['@id'].sub(/https:\/\/corpusvitrearum.de\/id\//, '')
  end

  def path
    record['@id'].sub(/https:\/\/corpusvitrearum.de\/id\/F/, '') << ".jpg"
  end

  def source_url
    record['@id']
  end

  def artist
    # kann dezeit noch nicht ausgespielt werden; wird später ergänzt
  end

  def title
    title = record['dc:Title']
    relation = record['dc:Relation']
    "#{title} (#{relation})".sub(/ \(\)/, '')
  end

  def iconclass
    if record['cvma:IconclassNotation']
      record['cvma:IconclassNotation'].map{|notation|
        "#{notation}".sub(/https:\/\/iconclass.org\//, '')
      }
    end
  end

  def iconclass_description
    record['cvma:IconclassDescription']
  end

  # Since location_nested exists, location is only used for sorting via location.raw.
  def location
    location_nested.map {|location|
      location['name']
    }.join(' | ')
  end

  def location_nested
    world_region = record['Iptc4xmpExt:LocationCreated']['Iptc4xmpExt:WorldRegion']
    country = record['Iptc4xmpExt:LocationCreated']['Iptc4xmpExt:CountryName']
    province = record['Iptc4xmpExt:LocationCreated']['Iptc4xmpExt:ProvinceState']
    geonames = record['Iptc4xmpExt:LocationCreated']['Iptc4xmpExt:LocationId']
    latitude = record['exif:GPSLatitude']
    longitude = record['exif:GPSLongitude']
    name = "#{world_region}, #{country}, #{province}, #{city}, #{sublocation} (#{latitude}, #{longitude})"

    nested_location = {}
    nested_location['name'] = "#{name}"
    nested_location['link_text'] = "#{geonames}".sub(/http:\/\/sws.geonames.org\//, '')
    nested_location['link_url'] = "#{geonames}"
    [nested_location]
  end

  def building
    a = []
    a << "#{city}"
    a << "#{sublocation}"
    a << record['cvma:PartOfBuilding']
    a << record['cvma:Direction']
    a << record['cvma:Pane']
    a << record['cvma:Row']
    a << record['cvma:Column']

    a.reject(&:blank?).join(", ")
  end

  def former_location
    record['cvma:FormerLocation']
  end

  def date
    "#{record['Iptc4xmpExt:AOCircaDateCreated']} (Foto: #{record['xmp:CreateDate']})".sub(/\(Foto: \)/, '')
  end

  def date_range
    if (from = record['cvma:AgeDeterminationStart']) && (to = record['cvma:AgeDeterminationEnd']) && (from <= to)
      @date_parser.date_range("#{from} - #{to}")
    end
  end

  def restoration_history
    record['cvma:RestorationHistory']
  end

  def credits
    "CVMA-Buchreihe: #{record['cvma:Volume']}, #{record['cvma:Figure']}".sub(/\A, /, '').sub(/, \z/, '')
  end

  def rights_work
    "Gemeinfrei"
  end

  # Since rights_reproduction_nested exists, rights_reproduction is only used for sorting via rights_reproduction.raw.
  def rights_reproduction
    rights_reproduction_nested.map {|rights_reproduction|
      rights_reproduction['name']
    }.join(' | ')
  end

  def rights_reproduction_nested
    nested_rights_reproduction = {}
    a = []
    a << record['dc:creator']
    a << record['photoshop:Credit']

    nested_rights_reproduction['name'] = a.reject(&:blank?).join(", ")
    nested_rights_reproduction['license'] = record['xmpRights:UsageTerms']
    nested_rights_reproduction['license_url'] = record['xmpRights:WebStatement']
    [nested_rights_reproduction]
  end

  def inventory_no
    record['dc:Identifier']
  end

  def publisher
    record['dc:Publisher']
  end

  def source_type
    record['Iptc4xmpExt:DigitalSourceType']
  end

  def photographic_context
    record['cvma:PhotographicContext']
  end

  def photographic_type
    record['cvma:PhotographicType']
  end

  def technique
    record['dc:Type']
  end

  def genre
    record['dc:Type']
  end

  def size
    a = []
    unless record['cvma:ObjectDiameter'].blank?
      a << "#{record['cvma:ObjectDiameter']} (Durchmesser)"
    end
    unless record['cvma:ObjectHeight'].blank?
      a << "#{record['cvma:ObjectHeight']} cm (Höhe)"
    end
    unless record['cvma:ObjectWidth'].blank?
      a << "#{record['cvma:ObjectWidth']} cm (Breite)"
    end

    a.join(" | ")
  end

  private

    def city
      @city ||= record['Iptc4xmpExt:LocationCreated']['Iptc4xmpExt:City']
    end

    def sublocation
      @sublocation ||= record['Iptc4xmpExt:LocationCreated']['Iptc4xmpExt:Sublocation']
    end
end
