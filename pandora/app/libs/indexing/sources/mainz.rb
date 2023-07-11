class Indexing::Sources::Mainz < Indexing::SourceSuper  
  def records
    document.xpath('//bilder')
  end

  def record_id
    record.xpath('.//bildname_ims/text()')
  end

  def path
    "#{record.at_xpath('.//bildname_ims/text()')}"
  end

  # künstler
  def artist
    record.xpath('.//_nested__bilder__kuenstler_kuenstlerinnen/bilder__kuenstler_kuenstlerinnen/kuenstler_kuenstlerin/kuenstler_kuenstlerin/name/text()')
  end

  def artist_normalized
    an = record.xpath('.//_nested__bilder__kuenstler_kuenstlerinnen/bilder__kuenstler_kuenstlerinnen/kuenstler_kuenstlerin/kuenstler_kuenstlerin/name/text()').map { |a|
      a.to_s.gsub(/ \(.*/, '').split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  def date
    record.xpath('.//datierung/text()')
  end

  def date_range
    d = date.to_s.strip

    super(d)
  end

  def size
    record.xpath('.//masse/text()')
  end

  # standort
  def location
    record.xpath('.//_nested__bilder__orte/bilder__orte/ort/orte/_path/orte/_standard/de-DE/text()')
  end

  # material
  def material
    record.xpath('.//_nested__bilder__material_technik_kg/bilder__material_technik_kg/material_technik_kg/material_technik_kg/_path/material_technik_kg/_standard/de-DE/text()')
  end

  def genre
    record.xpath('.//_nested__bilder__objektbezeichnung_kg/bilder__objektbezeichnung_kg/objektbezeichnung_kg/objektbezeichnung_kg/name/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//abbildungsnachweis_quelle/text()')
  end

  def license
    record.xpath('.//lizenz/lizenzen/name/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # bildrecht
  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  def annotation
    record.xpath('.//weitere_informationen/text()')
  end
end
