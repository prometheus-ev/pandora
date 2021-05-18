class Indexing::Sources::Tuberlin < Indexing::SourceSuper
  def records
    document.xpath('//dump')
  end

  def record_id
    record.xpath('.//bildreferenz/text()')
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      record.at_xpath('.//bildreferenz/text()')
    end
  end

  def s_location
    [record.xpath('.//standort/text()'), record.xpath('.//institution/text()'), record.xpath('.//herkunftsort/text()')]
  end

  def s_credits
    [record.xpath('.//abbildungsnachweis/text()'), record.xpath('.//copyright/text()')]
  end

  # künstler
  def artist
    record.xpath('.//kuenstler/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstler/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
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
    record.xpath('.//standort/text()')
  end

  # institution
  def institution
    record.xpath('.//institution/text()')
  end

  # herkunft
  def origin
    record.xpath('.//herkunftsort/text()')
  end

  # material
  def material
    record.xpath('.//material/text()')
  end

  # gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  # abbildungsnachweis
  def credits
    record.xpath('.//abbildungsnachweis/text()')
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

  # format
  def size
    record.xpath('.//abmessung/text()')
  end
end
