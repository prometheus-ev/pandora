class Indexing::Sources::BerlinIkbFarbdias < Indexing::SourceSuper
  def records
    document.xpath('.//row[contains(bearbeitungsstand, "Erfassungsstufe II")]')
  end

  def record_id
    record.xpath('.//Ressourcen-ID/text()')
  end

  def path
    "Scaler?&dh=2000&fn=#{record.at_xpath('.//bildvollbilddigilib/text()')}"
  end

  # Since artist_nested exists, artist is only used for sorting via artist.raw.
  def artist
    artist_nested.map { |artist|
      artist['name']
    }.join(' | ')
  end

  def artist_nested
    nested_artists = []
    artists = record.xpath('.//objektknstler/text()').to_s.gsub(/ \(Q0\)/,'').split(/(?<=\)),/)
    return unless artists

    artists.each do |artist|
      a = {}
      a['name'] = artist.split(' (')[0]
      brackets_data = artist.scan(/\((.*?)\)/).flatten

      if brackets_data[0] == '?-?'
        a['dating'] = ''
      else
        a['dating'] = brackets_data[0] 
      end

      a['wikidata'] = brackets_data[1]

      nested_artists << a
    end

    nested_artists
  end

  # Since title_nested exists, title is only used for sorting via title.raw.
  def title
    title_nested.map { |title|
      title['name']
    }.join(' | ')
  end
  
  def title_nested
    nested_titles = []
    titles = "#{record.xpath('.//objektbezeichnung/text()')}".gsub(/ \(Q0\)/,'').split(/(?<=\)),/)
    return unless titles

    titles.each do |title|
      t = {}
      brackets_data = title.scan(/\((.*?)\)/).flatten
      t['name'] = title.split(' (')[0]

      if brackets_data[0]
        if brackets_data[0].match?(/\A[Q]\d+/)
          t['wikidata'] = brackets_data[0]
        else
          t['name'] += (' (' + brackets_data[0] + ')') if brackets_data[0]
        end
      end

      nested_titles << t
    end

    nested_titles
  end

  def detail
    record.xpath('.//bilddetailbildauschn/text()')
  end

  def description
    record.xpath('.//diabeschreibung/text()')
  end

  # Since location_nested exists, location is only used for sorting via location.raw.
  def location
    location_nested.map { |location|
      location['name']
    }.join(' | ')
  end

  def location_nested
    # Kopenhagen, Ny Carlsberg Glyptotek (Q1140507)
    nested_locations = []
    locations = "#{record.xpath('.//objektort/text()')}, #{record.xpath('.//objektmuseumsammlung/text()')}".gsub(/ \(Q0\)/,'').gsub(/, \z/, '').gsub(/\A, /, '').split(/(?<=\)),/)
    return unless locations

    locations.each do |location|
      t = {}
      brackets_data = location.scan(/\((.*?)\)/).flatten
      t['name'] = location.split(' (').first

      if brackets_data[0]
        if brackets_data[0].match?(/\A[Q]\d+/)
          t['wikidata'] = brackets_data[0]
        else
          t['name'] += (' (' + brackets_data[0] + ')') if brackets_data[0]
        end
      end

      if brackets_data[1]
        if brackets_data[1].match?(/\A[Q]\d+/)
          t['wikidata'] = brackets_data[1] if brackets_data[1]
        end
      end

      nested_locations << t
    end

    nested_locations
  end

  def taxonomy
    record.xpath('.//systematik/text()')
  end

  # no need
  #def inscription
  #  record.xpath('.//beschriftung/text()')
  #end

  def labels_collection
    record.xpath('.//stempelsammlung/text()')
  end

  def labels_creator
    record.xpath('.//stempelhersteller/text()')
  end

  def slide_creator
    record.xpath('.//diahersteller/text()')
  end

  def date
    object_date = record.xpath('.//objektdatierung/text()').to_s.strip
    image_date = record.xpath('.//bilddatierung/text()').to_s.strip

    if !object_date.blank? && !image_date.blank?
      "#{record.xpath('.//objektdatierung/text()')} (Foto: #{record.xpath('.//bilddatierung/text()')})".gsub(/\A /,'').gsub(/ 00:00/,'').gsub(/-00-00/,'').gsub(/\(Foto: \)/,'')
    elsif !object_date.blank?
      "#{record.xpath('.//objektdatierung/text()')}".gsub(/\A /,'').gsub(/ 00:00/,'').gsub(/-00-00/,'').gsub(/\(Foto: \)/,'')
    elsif !image_date.blank?
      "(Foto: #{record.xpath('.//bilddatierung/text()')})".gsub(/\A /,'').gsub(/ 00:00/,'').gsub(/-00-00/,'').gsub(/\(Foto: \)/,'')
    end
  end

  def date_range
    # Preprocess.
    date = record.xpath('.//objektdatierung/text()').to_s.strip

    if date == '80. n. Chr.'
      date = '80 n. Chr.'
    end

    if !date.blank? && date != '2.-3. Jh. n. Chr.'
      super(date)
    end
  end

  def credits
    "#{record.xpath('.//title/text()')}"
  end

  def credits_nested
    nested_credits = {}

    nested_credits['link_text'] = "#{record.xpath('.//title/text()')}"
    nested_credits['link_url'] = "https://rs.cms.hu-berlin.de/ikb_mediathek/pages/view.php?ref=#{record.xpath('.//Ressourcen-ID/text()')}"

    [nested_credits]
  end

  def external_references
    record.xpath('.//externereferenzenzbh/text()')
  end

  def license
    record.xpath('.//lizenz/text()')
  end

  def license_nested
    nested_license = {}

    license_info = license.to_s.delete(')').split(' (')
    nested_license['name'] = license_info[0]
    nested_license['url'] = license_info[1]

    [nested_license]
  end

  def comment
    record.xpath('.//bemerkungen/text()')
  end

  # Since rights_reproduction_nested exists, rights_reproduction is only used for sorting via rights_reproduction.raw.
  def rights_reproduction
    rights_reproduction_nested.map { |rights_reproduction|
      rights_reproduction['name']
    }.join(' | ')
  end

  def rights_reproduction_nested
    nested_rights_reproduction = {}
    license = "#{record.xpath('.//lizenz/text()')}"
    license_brackets_data = license.scan(/\((.*?)\)/).flatten

    nested_rights_reproduction['name'] = "#{record.xpath('.//bildfotograf/text()')}".split(' (').first
    nested_rights_reproduction['license'] = license.split(' (').first
    nested_rights_reproduction['license_url'] = license_brackets_data[0]

    if !(wikidata = "#{record.xpath('.//bildfotograf/text()')}".match(/\(Q.*\)/).to_s.gsub(/\(/,'').gsub(/\)/,'')).blank?
      nested_rights_reproduction['wikidata'] = wikidata
    end

    [nested_rights_reproduction]
  end

  def rights_work
    record.xpath('.//lizenzwerk/text()')
  end

  def status_record
    record.xpath('.//bearbeitungsstand/text()')
  end

  def annotations
    record.xpath('.//notes/text()')
  end

  def keywords
    record.xpath('.//keywords/text()')
  end

  def person_nested
    nested_persons = []
    persons = "#{record.xpath('.//objektabgebperson/text()')}".gsub(/ \(Q0\)/,'').split(/(?<=\)),/)
    return unless persons

    persons.each do |person|
      p = {}
      p['name'] = person.split(' (')[0]
      brackets_data = person.scan(/\((.*?)\)/).flatten

      if brackets_data[0] == '?-?'
        p['dating'] = ''
      else
        p['dating'] = brackets_data[0] 
      end

      p['wikidata'] = brackets_data[1]

      nested_persons << p
    end

    nested_persons
  end

  def source_url
    "https://rs.cms.hu-berlin.de/ikb_mediathek/pages/view.php?ref=#{record.xpath('.//Ressourcen-ID/text()')}"
  end
end
