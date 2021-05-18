class Indexing::Sources::Imago < Indexing::SourceSuper
  def records
    document.xpath('//entry')
  end

  def record_id
    record.xpath('.//bildnummer/text()')
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      "#{record.at_xpath('.//bildnummer/text()')}".downcase
    end
  end

  def s_location
    [record.xpath('.//standort/text()'), record.xpath('.//institution/text()')]
  end

  def s_credits
    [record.xpath('.//abbildungsnachweis/text()'), record.xpath('.//copyright/text()'), record.xpath('.//fotograf/text()')]
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstler/text()').map { |a|
      HTMLEntities.new.decode(a.to_s.sub(/ \(.*/, '').split(', ').reverse.join(' '))
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  # standort
  def location
    "#{record.xpath('.//standort/text()')}, #{record.xpath('.//institution/text()')}".gsub(/\A, /, '').gsub(/, \z/, '')
  end

  # technik
  def technique
    record.xpath('.//technik/text()')
  end

  # format
  def size
    record.xpath('.//format/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//abbildungsnachweis/text()')
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end

  # copyright
  def rights_reproduction
    record.xpath('.//copyright/text()')
  end

  # fotograf
  def photographer
    record.xpath('.//fotograf/text()')
  end

  # schlagworte
  def keyword
    record.xpath('.//schlagworte/text()')
  end
end
