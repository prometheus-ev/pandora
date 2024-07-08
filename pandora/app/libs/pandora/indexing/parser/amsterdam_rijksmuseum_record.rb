class Pandora::Indexing::Parser::AmsterdamRijksmuseumRecord < Pandora::Indexing::Parser::Record
  def record_id
    "#{record.xpath('.//Id/text()')}".gsub(/\Aen-/, "")
  end

  # No objects with multiple records available, move objectNumber to record_identifier.
  # def record_object_id
  #   if !(text = record.xpath('.//objectNumber/text()')).empty?
  #     [name, Digest::SHA1.hexdigest(text.to_s)].join('-')
  #   end
  # end

  def record_identifier
    "#{record.xpath('.//ObjectNumber/text()')}"
  end

  def path
    "#{record.at_xpath('.//WebImage/Url/text()')}".gsub(/https:\/\//, '')
  end

  def artist
    number = record.xpath('count(.//PrincipalMakers)')
    (1..(number.to_i)).map {|index|
      ("#{record.xpath(".//PrincipalMakers[#{index}]/Name/text()")} " \
        "(" \
        "#{record.xpath(".//PrincipalMakers[#{index}]/PlaceOfBirth/text()")} " \
        "#{record.xpath(".//PrincipalMakers[#{index}]/DateOfBirthPrecision/text()")} " \
        "#{record.xpath(".//PrincipalMakers[#{index}]/DateOfBirth/text()")} " \
        "- " \
        "#{record.xpath(".//PrincipalMakers[#{index}]/PlaceOfDeath/text()")} " \
        "#{record.xpath(".//PrincipalMakers[#{index}]/DateOfDeathPrecision/text()")} " \
        "#{record.xpath(".//PrincipalMakers[#{index}]/DateOfDeath/text()")}" \
        ") [" \
        "#{record.xpath(".//PrincipalMakers[#{index}]/Qualification/text()")}" \
        "]").squeeze(" ").strip.gsub(/\( - \)/, "").gsub(/\A\( - /, "").gsub(/- \)\z/, "").gsub(/ \(\)/, "").gsub(/ \[\]/, "").gsub(/\( /, "(")
    }.uniq
  end

  def title
    title = record.xpath('./Title/text()').to_a.join(' | ')
    titles = record.xpath('./Titles/text()').to_a.join(' | ')

    if title == titles
      title
    else
      "#{title} - #{titles}"
    end
  end

  def date
    date = "#{record.xpath('.//Dating/EarlyPrecision/text()')} #{record.xpath('.//Dating/YearEarly/text()')}".strip
    date2 = "#{record.xpath('.//Dating/EarlyPrecision/text()')} #{record.xpath('.//Dating/YearLate/text()')}".strip
    if date == date2
      date
    else
      "#{date} - #{date2}"
    end
  end

  def date_range
    return @date_range if @date_range

    @date_range = @date_parser.date_range(date)
  end

  def location
    "Rijksmuseum, Amsterdam"
  end

  def production_place
    record.xpath('.//PrincipalMakers/ProductionPlaces/text()')
  end

  def description
    "#{record.xpath('.//Description/text()')}"
  end

  # Inscription elements do not seem to be available anymore.
  def inscription
    "#{record.xpath('.//Inscriptions/Inscription/text()')}"
  end

  def short_explanation
    se = (record.xpath('.//PlaqueDescriptionDutch/text()') +
    record.xpath('.//PlaqueDescriptionEnglish/text()') +
    record.xpath('.//Label/Description/text()')).map {|short_explanation_term|
      short_explanation_term.to_s.strip
    }
    se.delete_if {|short_explanation_term|
      short_explanation_term.blank?
    }
  end

  def material
    record.xpath('.//Materials/text()') +
    record.xpath('.//PhysicalMedium/text()')
  end

  def size
    record.xpath('.//SubTitle/text()')
  end

  def technique
    technique = record.xpath('.//Techniques/text()').to_a.join(' | ')

    if technique.strip == ""
      record.xpath('.//ObjectTypes/text()')
    else
      technique
    end
  end

  def genre
    record.xpath('.//ObjectTypes/text()')
  end

  def credits
    credits = "Rijksmuseum, Amsterdam; " \
              "#{record.xpath('.//Acquisition/CreditLine/text()')}; " \
              "#{record.xpath('.//Acquisition/Date/text()')} " \
              "(acquisition date)"
    credits.gsub(/; \(acquisition date\)/, "").gsub(/; ; \z/, "").gsub(/; ; /, "; ").gsub(/; \z/, "").gsub(/T00:00:00Z/, "").gsub(/T00:00:00/, "")
  end

  def rights_work
    record.xpath('.//CopyrightHolder/text()')
  end

  def rights_reproduction
    (copyrightHolder = "#{record.xpath('.//CopyrightHolder/text()')}").blank? ?
      "http://creativecommons.org/publicdomain/zero/1.0/" : copyrightHolder
  end

  def literature
    record.xpath('.//Documentation/text()')
  end

  def iconclass
    record.xpath('.//Classification/IconClassIdentifier/text()')
  end

  def iconclass_description
    record.xpath('.//Classification/IconClassDescription/text()')
  end

  def iconography
    ("#{record.xpath('.//Classification/Events/text()').to_a.join(' | ')} (Events); " \
      "#{record.xpath('.//Classification/Places/text()').to_a.join(' | ')} (Places); " \
      "#{record.xpath('.//Classification/People/text()').to_a.join(' | ')} (People)").gsub(/\A \(Events\)/, "").gsub(/;  \(Places\)/, "").gsub(/;  \(People\)/, "").gsub(/\A; ; /, "").gsub(/; ; \z/, "").gsub(/\A; /, "").gsub(/; \z/, "")
  end

  def source_url
    "https://www.rijksmuseum.nl/en/collection/#{record_id}"
  end
end
