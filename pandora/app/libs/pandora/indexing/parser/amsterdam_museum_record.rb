class Pandora::Indexing::Parser::AmsterdamMuseumRecord < Pandora::Indexing::Parser::Record
  def record_id
    "#{record.xpath('./reproduction.identifier_URL/text()')}".gsub(/.*\\/, '')
  end

  def record_object_id
    if !(record_object_id = object.xpath('./object_number/text()')).empty?
      [name, Digest::SHA1.hexdigest(record_object_id.to_s)].join('-')
    end
  end

  def record_object_id_count
    count = object.xpath('./reproduction/reproduction.identifier_URL/text()').size

    if count > 1
      count
    end
  end

  def path
    "#{record.at_xpath('./reproduction.identifier_URL/text()')}".downcase.gsub(/..\\..\\dat\\collectie\\images\\/, '').gsub('\\', '/').gsub(' ', '%20').sub(/^(\/*)/, '')
  end

  def artist
    number = object.xpath('./maker').length
    (1..(number.to_i)).map{|index| "#{object.xpath("./maker[#{index}]/creator/text()")} (#{object.xpath("./maker[#{index}]/creator.qualifier/text()")} #{object.xpath("./maker[#{index}]/creator.date_of_birth/text()")} - #{object.xpath("./maker[#{index}]/creator.date_of_death/text()")}, #{object.xpath("./maker[#{index}]/creator.role/text()")})".gsub(/\( - /, '').gsub(/, \)/, ')').gsub(/\( /, '(').gsub(/\( - \)/, '').gsub(/\( - , /, '(')}
  end

  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = object.xpath('./maker/creator/text()').map {|a|
      a.to_s.gsub(/ \(.*/, '').split(', ').reverse.join(' ')
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def title
    "#{object.xpath('./title/text()')} (#{object.xpath('./title.translation/text()')})".gsub(/ \(\)/, '')
  end

  def date
    @date ||= begin
      start_date = "#{object.xpath('./production.date.start[1]/text()')}".strip
      end_date = "#{object.xpath('./production.date.end[1]/text()')}".strip

      @date = if (start_date.blank? || start_date == '0000') && (end_date.blank? || end_date == '0000')
        nil
      elsif start_date.blank? || start_date == '0000'
        end_date
      elsif end_date.blank? || end_date == '0000' || start_date == end_date
        start_date
      else
        if start_date.to_i > end_date.to_i
          start_date
        else
          "#{start_date} - #{end_date}"
        end
      end
    end
  end

  def date_range
    return @date_range if @date_range

    if parsed_date = date
      # Preprocess, see #1166.
      parsed_date.sub! '17101620 - 17301640', '1710 - 1730'
      parsed_date.sub! '18711881 - 19181928', '1871 - 1918'
      parsed_date.sub! '19201930 - 19351945', '1920 - 1935'
      parsed_date.gsub!(/ \(\?\)/, '')
      parsed_date.gsub!(/ \?/, '')

      @date_range = @date_parser.date_range(parsed_date)
    end
  end

  def location
    object.xpath('./credit_line/text()')
  end

  def production_place
    object.xpath('./production.place/text()')
  end

  def material
    object.xpath('./material/text()')
  end

  def technique
    object.xpath('./technique/text()')
  end

  def genre
    "#{object.xpath('./object_name/text()')} (#{object.xpath('./object_category/text()')})"
  end

  def size
    number = object.xpath('./dimension').length
    (1..(number.to_i)).map{|index| "#{object.xpath("./dimension[#{index}]/dimension.type/text()")} #{object.xpath("./dimension[#{index}]/dimension.part/text()")}: #{object.xpath("./dimension[#{index}]/dimension.value/text()")} #{object.xpath("./dimension[#{index}]/dimension.unit/text()")}".gsub(/ : /, ': ')}
  end

  def credits
    object.xpath('./credit_line/text()')
  end

  def rights_work
    if @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end

  def rights_reproduction
    object.xpath('./copyright/text()')
  end

  def literature
    number = object.xpath('count(./documentation)')
    (1..(number.to_i)).map {|index|
      "#{object.xpath("./documentation[#{index}]/documentation.author/text()")}: #{object.xpath("./documentation[#{index}]/documentation.title/text()")} #{object.xpath("./documentation[#{index}]/documentation.sortyear/text()")}. #{object.xpath("./documentation[#{index}]/documentation.page_reference/text()")}.".gsub(/\A: /, '').gsub(/ \./, '').gsub(/ \.\z/, '')
    }
  end

  def keyword
    object.xpath('./content.motif.general/text()') + object.xpath('./content.subject/text()')
  end

  def description
    object.xpath('./AHMteksten/AHM.texts.tekst/text()')
  end

  def source_url
    "http://am.adlibhosting.com/Details/collect/#{object.xpath('./priref/text()')}"
  end
end
