class Indexing::Sources::AmsterdamMuseum < Indexing::SourceSuper
  def records
    document.xpath('//reproduction')
  end

  def record_id
    "#{record.xpath('.//reproduction.identifier_URL/text()')}".gsub(/.*\\/, '')
  end

  def record_object_id
    record_object_ids = record.xpath('ancestor::record/object_number/text()').map { |record_object_id|
      record_object_id.to_s
    }
    [name, Digest::SHA1.hexdigest(record_object_ids.uniq.join('|'))].join('-')
  end

  def path
    "#{record.at_xpath('.//reproduction.identifier_URL/text()')}".downcase.gsub(/..\\..\\dat\\collectie\\images\\/, '').gsub('\\', '/').gsub(' ', '%20').sub(/^(\/*)/,'')
  end

  # künstler
  def artist
    number = record.xpath('ancestor::record/maker').length
    (1..(number.to_i)).map{ |index| "#{record.xpath("ancestor::record/maker[#{index}]/creator/text()")} (#{record.xpath("ancestor::record/maker[#{index}]/creator.qualifier/text()")} #{record.xpath("ancestor::record/maker[#{index}]/creator.date_of_birth/text()")} - #{record.xpath("ancestor::record/maker[#{index}]/creator.date_of_death/text()")}, #{record.xpath("ancestor::record/maker[#{index}]/creator.role/text()")})".gsub(/\( - /, '').gsub(/, \)/, ')').gsub(/\( /, '(').gsub(/\( - \)/, '').gsub(/\( - , /, '(')}
  end

  def artist_normalized
    an = record.xpath("ancestor::record/maker/creator/text()").map { |a|
      a.to_s.gsub(/ \(.*/, '').split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    "#{record.xpath('ancestor::record/title/text()')} (#{record.xpath('ancestor::record/title.translation/text()')})".gsub(/ \(\)/, '')
  end

  # datierung
  def date
    @date ||= begin
      start_date = "#{record.xpath('ancestor::record/production.date.start[1]/text()')}".strip
      end_date = "#{record.xpath('ancestor::record/production.date.end[1]/text()')}".strip
      
      @date = if (start_date.blank? || start_date == '0000') && (end_date.blank? || end_date == '0000')
        nil
      elsif start_date.blank? || start_date == '0000'
        end_date
      elsif end_date.blank? || end_date == '0000'
        start_date
      elsif start_date == end_date
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
    if parsed_date = date
      # Preprocess, see #1166.
      parsed_date.sub! '17101620 - 17301640', '1710 - 1730'
      parsed_date.sub! '18711881 - 19181928', '1871 - 1918'
      parsed_date.sub! '19201930 - 19351945', '1920 - 1935'
      parsed_date.gsub!(/ \(\?\)/, '')
      parsed_date.gsub!(/ \?/, '')

      super(parsed_date)
    end
  end

  # standort
  def location
    record.xpath('ancestor::record/credit_line/text()')
  end

  def production_place
    record.xpath('ancestor::record/production.place/text()')
  end

  # material
  def material
    record.xpath('ancestor::record/material/text()')
  end

  def technique
    record.xpath('ancestor::record/technique/text()')
  end

  def genre
    "#{record.xpath('ancestor::record/object_name/text()')} (#{record.xpath('ancestor::record/object_category/text()')})"
  end

  # format
  def size
    number = record.xpath('ancestor::record/dimension').length
    (1..(number.to_i)).map{ |index| "#{record.xpath("ancestor::record/dimension[#{index}]/dimension.type/text()")} #{record.xpath("ancestor::record/dimension[#{index}]/dimension.part/text()")}: #{record.xpath("ancestor::record/dimension[#{index}]/dimension.value/text()")} #{record.xpath("ancestor::record/dimension[#{index}]/dimension.unit/text()")}".gsub(/ : /,': ')}
  end

  # abbildungsnachweis
  def credits
    record.xpath('ancestor::record/credit_line/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # copyright
  def rights_reproduction
    record.xpath('ancestor::record/copyright/text()')
  end

  # literature
  def literature
    number = record.xpath('count(ancestor::record/documentation)')
    (1..(number.to_i)).map { |index|
      "#{record.xpath("ancestor::record/documentation[#{index}]/documentation.author/text()")}: #{record.xpath("ancestor::record/documentation[#{index}]/documentation.title/text()")} #{record.xpath("ancestor::record/documentation[#{index}]/documentation.sortyear/text()")}. #{record.xpath("ancestor::record/documentation[#{index}]/documentation.page_reference/text()")}.".gsub(/\A: /, '').gsub(/ \./, '').gsub(/ \.\z/, '')
    }
  end

  # schlagworte
  def keyword
    record.xpath('ancestor::record/content.motif.general/text()') + record.xpath('ancestor::record/content.subject/text()')
  end

  def description
    record.xpath('ancestor::record/AHMteksten/AHM.texts.tekst/text()')
  end

  def source_url
    "http://am.adlibhosting.com/Details/collect/#{record.xpath('ancestor::record/priref/text()')}"
  end
end
