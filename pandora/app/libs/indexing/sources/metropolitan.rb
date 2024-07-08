class Indexing::Sources::Metropolitan < Indexing::SourceSuper
  IMAGES_URL = /https:\/\/images\.metmuseum\.org\/CRDImages\/.*\/original\//
  CRD_IMAGES_URL = /https:\/\/images\.metmuseum\.org\/CRDImages\//
  IMAGES_EXT = /\.jpg/
  CREATIVE_COMMONS_0_LINE = "Creative Commons Zero (CC0),https://creativecommons.org/publicdomain/zero/1.0/"
  PUBLIC_DOMAIN_LINE = "Public Domain,https://www.metmuseum.org/about-the-met/policies-and-documents/image-resources"

  def records
    Indexing::XmlReaderNodeSet.new(document, "object", "//object[isPublicDomain=\"true\"]/primaryImage[text()] | //object[isPublicDomain=\"true\"]/additionalImages/additionalImage[text()]")
  end

  def record_id
    record.xpath('./text()').to_s.gsub(/(#{IMAGES_URL})|(#{IMAGES_EXT})/, "")
  end

  def record_object_id
    if record_object_id_count > 1
      [name, Digest::SHA1.hexdigest(object.xpath('./objectID/text()').to_s)].join('-')
    end
  end

  def record_object_id_count
    object.xpath('.//additionalImage').count + 1
  end

  def path
    record.xpath('./text()').to_s.gsub(/(#{CRD_IMAGES_URL})/, "")
  end

  def date
    object.xpath('./objectDate/text()').to_s
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  def artist
    if object.xpath('./artistDisplayBio/text()').to_s.blank?
      [object.xpath('./artistDisplayName/text()').to_s + "(" + object.xpath('./artistDisplayBio/text()').to_s + ")"]
    else
      [object.xpath('./artistDisplayName/text()').to_s]
    end
  end

  def constituents
    _constituents = Array.new
    object.xpath('./constituents/constituent').each do |constituent|
      _constituents.push (constituent.xpath('./name/text()').to_s + "(" + constituent.xpath('./role/text()').to_s + ")")
    end
    _constituents.join(" | ")
  end

  def biographical_data
    object.xpath('./artistDisplayBio/text()').to_s
  end

  def title
    object.xpath('./title/text()').to_s
  end

  def location
    object.xpath('./repository/text()').to_s
  end

  def department
    compose_field(
      ", ",
      object.xpath('./repository/text()').to_s,
      object.xpath('./department/text()').to_s
    )
  end

  def classification
    compose_field(
      " | ",
      object.xpath('./classification/text()').to_s,
      object.xpath('./objectName/text()').to_s
    )
  end

  def group_works
    object.xpath('./portfolio/text()').to_s
  end

  def material
    object.xpath('./medium/text()').to_s
  end

  def culture
    object.xpath('./culture/text()').to_s
  end

  def epoch
    compose_field(
      ", ",
      object.xpath('./period/text()').to_s,
      object.xpath('./dynasty/text()').to_s, object.xpath('./reign/text()').to_s
    )
  end

  def credits
    object.xpath('./repository/text()').to_s
  end

  def provenance
    object.xpath('./creditLine/text()').to_s
  end

  def rights_reproduction
    # only objects that are in the public domain are indexed (cf. supra)
    # for information on the Metropolitan Museum's Open Access policy,
    #   cf. https://www.metmuseum.org/about-the-met/policies-and-documents/image-resources
    CREATIVE_COMMONS_0_LINE
  end

  def rights_work
    # only objects that are in the public domain are indexed (cf. supra)
    # for information on the Metropolitan Museum's Open Access policy,
    #   cf. https://www.metmuseum.org/about-the-met/policies-and-documents/image-resources
    PUBLIC_DOMAIN_LINE
  end

  def source_url
    object.xpath('./objectURL/text()').to_s
  end

  def size
    object.xpath('./dimensions/text()').to_s
  end

  def place
    compose_field(
      ", ",
      object.xpath('./geographyType/text()').to_s,
      object.xpath('./city/text()').to_s, object.xpath('./state/text()').to_s,
      object.xpath('./county/text()').to_s, object.xpath('./subregion/text()').to_s,
      object.xpath('./region/text()').to_s, object.xpath('./country/text()').to_s
    )
  end

  def country
    object.xpath('./country/text()').to_s
  end

  def state
    object.xpath('./state/text()').to_s
  end

  def discoverplace
    compose_field(
      " | ",
      (
        compose_field(
          ", ",
          object.xpath('./excavation/text()').to_s,
          object.xpath('./locale/text()').to_s, object.xpath('./locus/text()').to_s
        )
      ),
      object.xpath('./river/text()').to_s
    )
  end

  def inventory_no
    object.xpath('./accessionNumber/text()').to_s
  end


  private

    def compose_field(separator, *field_elements)
      field_elements.reject(&:blank?).join(separator)
    end

    def object
      if is_primary_image?
        record.xpath('..')
      elsif is_additional_image?
        record.xpath('../..')
      end
    end

    def is_primary_image?
      record.name == "primaryImage"
    end

    def is_additional_image?
      record.name == "additionalImage"
    end
end
