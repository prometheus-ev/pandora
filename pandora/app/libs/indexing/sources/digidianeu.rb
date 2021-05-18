class Indexing::Sources::Digidianeu < Indexing::SourceSuper
  def records
    document.xpath('//ROW')
  end

  def record_id
    record.xpath('.//bildreferenz/text()')
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      record.xpath('.//bildreferenz/text()')
    end
  end

  # künstler
  def artist
    record.xpath('.//kuenstlerin/text()')
  end

  def artist_normalized
    an = record.xpath('.//kuenstlerin/text()').map { |a|
      a.to_s.split(', ').reverse.join(' ')
    }
    super(an)
  end

  # titel
  def title
    record.xpath('.//titel/text()')
  end

  # standort
  def location
    record.xpath('.//standort/text()')
  end

  # datierung
  def date
    record.xpath('.//datierung/text()')
  end

  # material
  def material
    record.xpath('.//material/text()')
  end

  # gattung
  def genre
    record.xpath('.//gattung/text()')
  end

  # bildrecht
  def credits
    record.xpath('.//abbildungsnachweis/text()')
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
