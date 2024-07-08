class Pandora::Indexing::Parser::Parents::BerlinIkbRecord < Pandora::Indexing::Parser::Record
  # Since artist_nested exists, artist is only used for sorting via artist.raw.
  def artist
    artist_nested.map {|artist|
      artist['name']
    }.join(' | ')
  end

  def artist_nested
    nested_artists = []
    artists = record.xpath('.//objektknstler/text()').to_s.split(/(?<=\)), /)
    attribution = ""
    return unless artists

    artists.each do |artist|
      brackets_data = []
      a = {}
      a['name'] = artist.split(' (')[0]

      if attribution.include?("Zuschreibung")
        a['name'] = "#{attribution}\n#{a['name']}"
      end

      if artist.starts_with?("(")
        attribution = artist
        next
      else
        attribution = ""
        brackets_data = artist.scan(/\((.*?)\)/).flatten
      end

      # Wikidata?
      if brackets_data.size == 3
        if brackets_data[2].match?(/\A[Q]\d+/)
          a['wikidata'] = brackets_data[2]
          brackets_data.delete_at(2)
        end
      elsif brackets_data.size == 2
        if brackets_data[1].match?(/\A[Q]\d+/)
          a['wikidata'] = brackets_data[1]
          brackets_data.delete_at(1)
        end
      end

      # Name addition?
      unless brackets_data[0].blank?
        if brackets_data[0].starts_with?(/\D/)
          a['name'] << " (#{brackets_data[0]})"
          brackets_data.delete_at(0)
        end
      end

      # Dating?
      unless brackets_data[0].blank?
        if brackets_data[0] == '?-?'
          a['dating'] = ''
        else
          a['dating'] = brackets_data[0]
        end
      end

      nested_artists << a
    end

    nested_artists
  end

  # Since title_nested exists, title is only used for sorting via title.raw.
  def title
    title_nested.map {|title|
      title['name']
    }.join(' | ')
  end

  def title_nested
    nested_titles = []
    titles = "#{record.xpath('.//objektbezeichnung/text()')}".gsub(/ \(Q0\)/, '').split(/(?<=\)),/)
    return unless titles

    titles.each do |title|
      brackets_data = []
      t = {}

      # there is some additional information in the first element in brackets like (Zeichnung), that would be processed twice
      unless title.starts_with?("(")
        brackets_data = title.scan(/\((.*?)\)/).flatten
      end

      t['name'] = title.split(' (')[0]

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
    location_nested.map {|location|
      location['name']
    }.join(' | ')
  end

  def location_nested
    # Kopenhagen, Ny Carlsberg Glyptotek (Q1140507)
    nested_locations = []
    locations = "#{record.xpath('.//objektort/text()')}, #{record.xpath('.//objektmuseumsammlung/text()')}".gsub(/ \(Q0\)/, '').gsub(/, \z/, '').gsub(/\A, /, '').split(/(?<=\)),/)
    return unless locations

    locations.each do |location|
      brackets_data = []
      t = {}

      unless location.starts_with?("(")
        brackets_data = location.scan(/\((.*?)\)/).flatten
      end

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

  def inscription
    record.xpath('.//beschriftung/text()')
  end

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
      "#{record.xpath('.//objektdatierung/text()')} (Foto: #{record.xpath('.//bilddatierung/text()')})".gsub(/\A /, '').gsub(/ 00:00/, '').gsub(/-00-00/, '').gsub(/\(Foto: \)/, '')
    elsif !object_date.blank?
      "#{record.xpath('.//objektdatierung/text()')}".gsub(/\A /, '').gsub(/ 00:00/, '').gsub(/-00-00/, '').gsub(/\(Foto: \)/, '')
    elsif !image_date.blank?
      "(Foto: #{record.xpath('.//bilddatierung/text()')})".gsub(/\A /, '').gsub(/ 00:00/, '').gsub(/-00-00/, '').gsub(/\(Foto: \)/, '')
    end
  end

  def date_range
    return @date_range if @date_range

    # Preprocess.
    date = record.xpath('.//objektdatierung/text()').to_s.strip

    if date == '80. n. Chr.'
      date = '80 n. Chr.'
    end

    if !date.blank? && date != '2.-3. Jh. n. Chr.'
      @date_range = @date_parser.date_range(date)
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

  def comment
    record.xpath('.//bemerkungen/text()')
  end

  def iconography
    record.xpath('.//objektikonografie/text()')
  end

  def iconclass
    "#{record.xpath('.//objektikonografie/text()')}".split(/, /).delete_if{|i| i.starts_with?(/[A-z]/)}.map{|item| item.gsub(/ .*/, '')}
  end

  # Since rights_reproduction_nested exists, rights_reproduction is only used for sorting via rights_reproduction.raw.
  def rights_reproduction
    rights_reproduction_nested.map {|rights_reproduction|
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

    if !(wikidata = "#{record.xpath('.//bildfotograf/text()')}".match(/\(Q.*\)/).to_s.gsub(/\(/, '').gsub(/\)/, '')).blank?
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
    persons = []
    unless (person1 = "#{record.xpath('.//objektabgebperson/text()')}").blank?
      persons = "#{person1}".gsub(/ \(Q0\)/, '').gsub(/\A/, 'abgebildete Person/en:').split(/(?<=\)),/)
    end
    unless (person2 = "#{record.xpath('.//fotopersonbeschriftu/text()')}").blank?
      persons << "#{person2}".gsub(/ \(Q0\)/, '').gsub(/\A/, 'Beschriftung:').split(/(?<=\)),/)
    end
    persons.flatten!
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

  def carrier_medium
    record.xpath('.//diamedientyp/text()')
  end

  def based_on
    "#{record.xpath('.//bildvorlage/text()')}, #{record.xpath('.//bildvorlageseite/text()')}".gsub(/, \z/, '')
  end

  def source_url
    "https://rs.cms.hu-berlin.de/ikb_mediathek/pages/view.php?ref=#{record.xpath('.//Ressourcen-ID/text()')}"
  end
end
