class Indexing::Sources::Smk < Indexing::SourceSuper

  # language of data: danish; 
  # only in some cases exist translations (some artwork titles, artist names, etc.)
  # using language parameter (lang=en) for api art requests returns incomplete datasets (compared to default [dk])

  # art fields
  # "id":"The ID from collection DB.",
  # "modified":"Last modified date, great for updating data.",
  # "object_number":"The objects number.",
  # "responsible_department":"The department which is responsible for the object.",
  # "copy_number":"?",
  # "distinguishing_features":"The features can be stains, cracks, folds and so on",
  # "collection":"The original collection.",
  # "frame":"If the object is framed or not",
  # "public_domain":"If the object is in public domain or not.",
  # "on_display":"If the object is on display in the museum.",
  # "has_image":"If there is an image attached to the work.",
  # "description":"Objects description.",
  # "notes":"Notes about the object.",
  # "production_date_notes":"Notes about the production date.",
  # "alternative_numbers":"Objects numbers in other systems.",
  # "dimensions":"Objects dimensions.",
  # "documentation":"Documentation", # in which shelf, etc.
  # "inscriptions":"Different inscriptions, signatures, text a.o.",
  # "object_name":"Type of object, painting, sculpture a.o.",
  # "production":"Info about who produced the objects.",
  # "production_date":"The dates when the object was produced.",
  # "techniques":"Techniques used to produce the object.",
  # "titles":"The object title, or titles.",
  # "reproduction":"Info about object reproduction.",
  # "materials":"Materials used to produce the object.",
  # "labels":"Labels connected to the object.",
  # "object_history_note":"Objects notes on history.",
  # "number_of_parts":"Objects history of location.",
  # "exhibitions":"What exhibitions has the object been a part of.",
  # "acquisition_document_description":"Document describing the acquisition.",
  # "acquisition_date":"The acquisition date.",
  # "acquisition_date_precision":"The acquisition date as text.",
  # "credit_line":"How to credit the object.",
  # "similar_images_url":"Get similar images.",
  # "iiif_manifest":"Link to IIIF manifest.",
  # "image_mime_type":"The mime type of the image.",
  # "image_iiif_id":"The ID of the IIIF image.",
  # "image_iiif_info":"The info of the IIIF image.",
  # "image_width":"Width of the image.",
  # "image_height":"Height of the image.",
  # "image_size":"Size of image, in KB.",
  # "image_thumbnail":"URL to thumbnail.",
  # "image_native":"URL to largest available image.",
  # "image_type":"Image mime type",
  # "image_cropped":"If the image is cropped.",
  # "image_orientation":"Orientation of the image, landscape or portrait.",
  # "image_legacy":"Old style images, used for fallback if no IIIF image is available.",
  # "alternative_images":"Alternative images.", # not ideal representation of image
  # "content_person":"Portraited person.",
  # "content_subject":"Subject on work.",
  # "birth_place":"Artist birth place.",
  # "death_place":"Artist death place.",
  # "birth_date_start":"Artist birth date, start.",
  # "birth_date_end":"Artist birth date, end.",
  # "death_date_start":"Artist death date, start.",
  # "death_date_end":"Artist death date, end.",
  # "birth_date_prec":"Artist birth date, text.",
  # "death_date_prec":"Artist death date, text.",
  # "forename":"Artist forename.",
  # "surname":"Artist surname.",
  # "name":"Artist full name.",
  # "parts":"Parts in this work.",
  # "part_of":"This work is part of.",
  # "current_location_name":"Current location of work.", # in which room of museum
  # "current_location_date":"The date for last change of location.",
  # "work_status":"Status."

  # host differs for iiif and legacy images
  # IIIF_IMAGES_URL = /https:\/\/iip\.smk\.dk\/iiif\//
  # API_IMAGES_URL = /https:\/\/api\.smk\.dk\/api\/v1\//)
  HTTPS_PROTOCOL = /https:\/\//

  PUBLIC_DOMAIN_LINE = "Public Domain, https://www.smk.dk"
  CREATIVE_COMMONS_0_LINE = "Creative Commons Zero (CC0),https://creativecommons.org/publicdomain/zero/1.0/"

  SMK_LOCATION = "Statens Museum for Kunst (SMK), Copenhagen"

  # only records with image and reproduction in public domain
  # currently[2019-07-17] ca. 36501 records
  def records
    Indexing::XmlReaderNodeSet.new(document, "art", "//art[has-image=\"true\"][public-domain=\"true\"]")
  end

  def record_id
    record.xpath('./object-number/text()').to_s
  end

  def record_object_id
    if !record.xpath('./part-of/part-of').empty?
      # smk records have a n:m relation between records (parts | part-of); 
      # prometheus records only have 1:n relation between record_object and record
      # we reduce n:m relation to 1:n relation by unequivocally choosing one part as object_record
      [name, Digest::SHA1.hexdigest(record.xpath('./part-of/part-of/text()').to_a.map(&:to_s).sort.first)].join('-')
    else
      [name, Digest::SHA1.hexdigest(record.xpath('./object-number/text()').to_s)].join('-')
    end
  end

  # e.g. https://iip.smk.dk/iiif/jp2/KKS14024-62.tif.jp2/full/full/0/native.jpg
  def path
    record.xpath('./image-native/text()').to_s.gsub(/(#{HTTPS_PROTOCOL})/, "")
  end

  def artist
    if !record.xpath('./production/production/creator').empty? # artist data from person repo
      record.xpath('./production/production/creator').map{ |creator|
        creator.xpath('./items/item').map{ |item|
          [item.xpath('./name/text()').to_s, artist_date(
            item.xpath('./birth-date-prec/birth-date-prec/text()').to_a.join(" | "), 
            item.xpath('./death-date-prec/death-date-prec/text()').to_a.join(" | ")
            )].join(" ")
        }.to_a.join('; ')
      }.to_a.join(' | ')
    else # artist data from art repo
      record.xpath('./production/production').map{ |production|
        [production.xpath('./craftsman/text()').to_s, artist_date(
          production.xpath('./creator-date-of-birth/text()').to_a.join(" | "), 
          production.xpath('./creator-date-of-death/text()').to_a.join(" | ")
        )].join(" ")
      }.to_a.join(' | ')
    end
  end

  # artist name has to be: FIRSTNAMES LASTNAME
  def artist_normalized
    if !record.xpath('./production/production/creator').empty? # artist data from person repo
      an = record.xpath('./production/production/creator/items/item/name/text()').map { |a|
        a.to_s.split(', ').reverse.join(' ')
      }
    else # artist data from art repo
      an = record.xpath('./production/production/craftsman/text()').map { |a|
        a.to_s.split(', ').reverse.join(' ')
      }
    end

    super(an)
  end

  def title
    record.xpath('./titles/title/title/text() | ./titles/title/translation/text()').to_a.join(" | ")
  end

  # only images in public domain, cf. def records
  def rights_reproduction 
    CREATIVE_COMMONS_0_LINE
  end

  # some works are under copyright
  def rights_work
    credit_line = record.xpath('./credit-line/credit-line/text()').to_a.join(" | ")
    if !credit_line.empty?
      credit_line
    else
      PUBLIC_DOMAIN_LINE
    end
  end

  def department
    record.xpath('./responsible-department/text()').to_s
  end

  def material
    record.xpath('./materials/material/material/text()').to_a.join(" | ")
  end

  def technique
    record.xpath('./techniques/technique/technique/text()').to_a.join(" | ")
  end

  def acquisition
    [acquisition_date(record.xpath('./acquisition-date/text()').to_s, 
        record.xpath('./acquisition-date-precision/text()').to_s
      ), 
      record.xpath('./acquisition-document-description/text()').to_s
    ].reject(&:blank?).join(" | ")
  end

  # object-name not in fields list
  def classification 
    record.xpath('./object-name/object-name/name/text()').to_a.join(" | ")
  end

  def marks
    record.xpath('./distinguishing-features/distinguishing-feature/text()').to_a.join(" | ")
  end

  def date
    record.xpath('./production-date/production-date').map { |date|
      production_date(date.xpath('./start/text()').to_s, date.xpath('./end/text()').to_s)
    }.to_a.join(' | ')
  end

  def date_range
    super(date.split(' | ').first)
  end

  def literature 
    record.xpath('./notes/note/text()').to_a.join(" | ")
  end

  def text
    [record.xpath('./object-history-note/object-history-note/text()').to_a.join(" | "),
      record.xpath('./labels/label/text/text() | 
        ./labels/label/source/text() | 
        ./labels/label/date/text()').to_a.join(" | ")
    ].reject(&:empty?).join(' | ')
  end

  def size
    record.xpath('./dimensions/dimension').map { |dimension|
      dimension.xpath('./type/text()').to_s + ": " + dimension.xpath('./value/text()').to_s + dimension.xpath('./unit/text()').to_s + 
        " (" + dimension.xpath('./part/text()').to_s + ")"
    }.to_a.join(', ')
  end

  def inscription
    record.xpath('./inscriptions/inscription/*/text()').to_a.join(' | ')
  end

  # NEW display field
  def exhibition 
    record.xpath('./exhibitions/exhibition/exhibition/text()').to_a.join(' | ')
  end

  def function
    record.xpath('./work-status/work-status/text()').to_a.join(" | ")
  end

  def credits
    [SMK_LOCATION, department
      ].reject(&:empty?).join(", ")
  end

  def location
    [SMK_LOCATION, record.xpath('./current-location-name/text()').to_s
      ].reject(&:empty?).join(", ")
  end

  # NEW display field
  def collection
    record.xpath('./collection/collection/text()').to_a.join(' | ')
  end

  private

  def artist_date(birth_date, death_date)
    if !birth_date.empty? && !death_date.empty?
      "(" + birth_date.split('-')[0] + " - " + death_date.split('-')[0] + ")"
    elsif !birth_date.empty?
      "(*" + birth_date.split('-')[0] + ")"
    elsif !death_date.empty?
      "(\u2020" + death_date.split('-')[0] + ")"
    end
  end

  def acquisition_date(acquisition_date_precision, acquisition_date)
    if !acquisition_date_precision.blank?
      if acquisition_date_precision.index('-')
        acquisition_date_precision.split('-')[0]
      else
        acquisition_date_precision
      end
    elsif !acquisition_date.blank?
      if acquisition_date.index('-')
        acquisition_date.split('-')[0]
      else
        acquisition_date
      end
    end
  end

  def production_date(start_date, end_date)
    if !start_date.empty? && !end_date.empty?
      start_year = start_date.split('-')[0]
      end_year = end_date.split('-')[0]
      if start_year == end_year
        start_year
      else
      start_year + " - " + end_year
      end
    elsif !start_date.empty?
      start_date.split('-')[0]
    elsif !end_date.empty?
      end_date.split('-')[0]
    end
  end

end
