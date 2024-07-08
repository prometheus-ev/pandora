class Indexing::Sources::Mainz < Indexing::SourceSuper
  def records
    document.xpath('//bildname_ims')
  end

  def record_object_id
    record.xpath('ancestor::bilder/_system_object_id/text()')
  end

  def record_id
    if record.parent.xpath("boolean(name()='file')")
      [record.xpath('.//text()'), record.xpath('ancestor::bilder/_system_object_id/text()')]
    else
      record.xpath('.//text()')
    end
  end

  def path
    "#{record.at_xpath('.//text()')}"
  end

  # künstler
  def artist
    record.xpath('ancestor::bilder/_nested__bilder__kuenstler_kuenstlerinnen/bilder__kuenstler_kuenstlerinnen/kuenstler_kuenstlerin/kuenstler_kuenstlerin/name/text()')
  end

  def artist_normalized
    an = record.xpath('ancestor::bilder/_nested__bilder__kuenstler_kuenstlerinnen/bilder__kuenstler_kuenstlerinnen/kuenstler_kuenstlerin/kuenstler_kuenstlerin/name/text()').map {|a|
      a.to_s.gsub(/ \(.*/, '').split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('ancestor::bilder/titel/text()')
  end

  def date
    record.xpath('ancestor::bilder/datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  def size
    record.xpath('ancestor::bilder/masse/text()')
  end

  # standort
  def location
    location = record.xpath('ancestor::bilder/_nested__bilder__orte/bilder__orte/ort/orte/_path/orte/_standard/de-DE/text()')
    if !location.blank?
      location
    else
      record.xpath('ancestor::bilder/_nested__bilder__orte/bilder__orte/ort/orte/name_orte/text()')
    end
  end

  # material
  def material
    record.xpath('ancestor::bilder/_nested__bilder__material_technik_kg/bilder__material_technik_kg/material_technik_kg/material_technik_kg/_path/material_technik_kg/_standard/de-DE/text()')
  end

  def genre
    record.xpath('ancestor::bilder/_nested__bilder__objektbezeichnung_kg/bilder__objektbezeichnung_kg/objektbezeichnung_kg/objektbezeichnung_kg/name/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('ancestor::bilder/abbildungsnachweis_quelle/text()')
  end

  def license
    record.xpath('ancestor::bilder/lizenz/lizenzen/name/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('ancestor::bilder/copyright/text()')
  end

  def annotation
    record.xpath('ancestor::bilder/weitere_informationen/text()')
  end
end
