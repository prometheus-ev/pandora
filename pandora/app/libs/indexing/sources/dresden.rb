class Indexing::Sources::Dresden < Indexing::SourceSuper
  def records
    Indexing::XmlReaderNodeSet.new(document, "row", ".")
  end

  # Array of record ID strings (Dianummer)
  def records_to_exclude
    %w[21370 23516 59386 83893 85736 89303 90378 155528 155529 155530 155531 155532 155481 155490 155491 155492 155493 155494 155495 155496 155497 155498 155499 155482 155500 155501 155502 155503 155504 155505 155506 155507 155508 155509 155483 155510 155511 155512 155513 155514 155515 155516 155517 155518 155519 155484 155520 155521 155522 155523 155524 155525 155526 155527 155485 155486 155487 155488 155489]
  end

  def record_id
    record.xpath(".//Dianummer/text()")
  end

  def path
    return miro if miro?

    record.at_xpath(".//Dianummer/text()").to_s + ".jpg"
  end

  def title
    record.xpath(".//Titel/text()")
  end

  def subtitle
    record.xpath(".//Untertitel/text()")
  end

  def artist
    record.xpath(".//Künstlername/text()") +
    record.xpath(".//Architekt_Künstler/text()")
  end

  def artist_normalized
    an = artist.map { |a|
      HTMLEntities.new.decode(a.to_s.sub(/ \(.*/, '').strip.split(', ').reverse.join(' ')).gsub(/Ö/, 'ö').gsub(/Ä/,'ä').gsub(/Ü/,'ü')
    }
    super(an)
  end

  def date
    record.xpath(".//Datierung/text()")
  end

  def location
    locations = (record.xpath(".//Ort/text()") + record.xpath(".//Aufbewahrungsort/text()")).to_a
    locations.reject!{ |location|
      location = location.to_s.strip
      location.blank?
    }
    locations.compact.join(", ")
  end

  def genre
    "#{record.xpath(".//Katalog/text()")}, #{record.xpath(".//Themenkategorie/text()")}".gsub(/\A, /, "").gsub(/, \z/, "")
  end

  def credits
    record.xpath(".//Abbildungsnachweis/text()")
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  def rights_reproduction
    record.xpath(".//Copyright/text()")
  end

  def catalogue
    record.xpath(".//Katalog/text()")
  end
end
