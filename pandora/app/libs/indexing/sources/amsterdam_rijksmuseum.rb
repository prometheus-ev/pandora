class Indexing::Sources::AmsterdamRijksmuseum < Indexing::SourceSuper
  def records(file)
    document(file).xpath('//artObject[boolean(webImage)]')
  end

  def record_id
    "#{record.xpath('.//id/text()')}".gsub(/\Aen-/, "")
  end

  # No objects with multiple records available, move objectNumber to record_identifier.
  #def record_object_id
  #  if !(text = record.xpath('.//objectNumber/text()')).empty?
  #    [name, Digest::SHA1.hexdigest(text.to_s)].join('-')
  #  end
  #end

  def record_identifier
    "#{record.xpath('.//objectNumber/text()')}"
  end

  def path
    "#{record.at_xpath('.//webImage/url/text()')}".gsub(/https:\/\//, '')
  end

  # künstler
  def artist
    number = record.xpath('count(.//principalMakers)')
    (1..(number.to_i)).map { |index|
      ("#{record.xpath(".//principalMakers[#{index}]/name/text()")}" + " " +
      "(" +
      "#{record.xpath(".//principalMakers[#{index}]/placeOfBirth/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfBirthPrecision/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfBirth/text()")}" + " - " +
      "#{record.xpath(".//principalMakers[#{index}]/placeOfDeath/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfDeathPrecision/text()")}" + " " +
      "#{record.xpath(".//principalMakers[#{index}]/dateOfDeath/text()")}" +
      ") [" +
      "#{record.xpath(".//principalMakers[#{index}]/qualification/text()")}" +
      "]").squeeze(" ").strip.gsub(/\( - \)/, "").gsub(/\A\( - /, "").gsub(/- \)\z/, "").gsub(/ \(\)/, "").gsub(/ \[\]/, "").gsub(/\( /, "(")
    }.uniq
  end

  # titel
  def title
    title = record.xpath('./title/text()').to_a.join(' | ')
    titles = record.xpath('./titles/text()').to_a.join(' | ')

    if title == titles
      title
    else
      "#{title} - #{titles}"
    end
  end

  # datierung
  def date
    date = "#{record.xpath('.//dating/earlyPrecision/text()')} #{record.xpath('.//dating/yearEarly/text()')}".strip
    date2 = "#{record.xpath('.//dating/earlyPrecision/text()')} #{record.xpath('.//dating/yearLate/text()')}".strip
    if date == date2
      date
    else
      "#{date} - #{date2}"
    end
  end

  def date_range
    super(date)
  end

  # institution
  def location
    "Rijksmuseum, Amsterdam"
  end

  def production_place
    record.xpath('.//principalMakers/productionPlaces/text()')
  end

  # Beschreibung
  def description
    "#{record.xpath('.//description/text()')}"
  end

  # Inscription elements do not seem to be available anymore.
  def inscription
    "#{record.xpath('.//inscriptions/inscription/text()')}"
  end

  def short_explanation
    (record.xpath('.//plaqueDescriptionDutch/text()') +
    record.xpath('.//plaqueDescriptionEnglish/text()') +
    record.xpath('.//label/description/text()')).map { |short_explanation_term|
      short_explanation_term.to_s.strip
    }.delete_if { |short_explanation_term|
      short_explanation_term.blank?
    }
  end

  def material
    record.xpath('.//materials/text()') +
    record.xpath('.//physicalMedium/text()')
  end

  def size
    record.xpath('.//subTitle/text()')
  end

  def technique
    technique = record.xpath('.//techniques/text()').to_a.join(' | ')

    if technique.strip == ""
      record.xpath('.//objectTypes/text()')
    else
      technique
    end
  end

  def genre
    record.xpath('.//objectTypes/text()')
  end

  # abbildungsnachweis
  def credits
    credits = "Rijksmuseum, Amsterdam; " +
              "#{record.xpath('.//acquisition/creditLine/text()')}; " +
              "#{record.xpath('.//acquisition/date/text()')} " +
              "(acquisition date)"
    credits.gsub(/; \(acquisition date\)/, "").gsub(/; ; \z/, "").gsub(/; ; /, "; ").gsub(/; \z/, "").gsub(/T00:00:00Z/, "")
  end

  def rights_work
    record.xpath('.//copyrightHolder/text()')
  end

  def rights_reproduction
    (copyrightHolder = "#{record.xpath('.//copyrightHolder/text()')}").blank? ?
      "http://creativecommons.org/publicdomain/zero/1.0/" : copyrightHolder
  end

  def literature
    record.xpath('.//documentation/text()')
  end

  def iconclass
    record.xpath('.//classification/iconClassIdentifier/text()')
  end

  def iconclass_description
    record.xpath('.//classification/iconClassDescription/text()')
  end

  def iconography
    ("#{record.xpath('.//classification/events/text()').to_a.join(' | ')} (Events); " +
     "#{record.xpath('.//classification/places/text()').to_a.join(' | ')} (Places); " +
     "#{record.xpath('.//classification/people/text()').to_a.join(' | ')} (People)").gsub(/\A \(Events\)/, "").gsub(/;  \(Places\)/, "").gsub(/;  \(People\)/, "").gsub(/\A; ; /, "").gsub(/; ; \z/, "").gsub(/\A; /, "").gsub(/; \z/, "")
  end

  def source_url
    "https://www.rijksmuseum.nl/en/collection/#{record_id}"
  end
end
