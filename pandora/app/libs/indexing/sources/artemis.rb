class Indexing::Sources::Artemis < Indexing::Sources::Parents::Artemis
  def records
    document.xpath('//datensatz[not(contains(bemerkung, "Bayerische Kunstgeschichte"))]')
  end

  def path
    @miro_record_ids ||= Rails.configuration.x.athene_search_record_ids['miro'][name]
    if @miro_record_ids.include?(process_record_id(record_id))
      "miro"
    else
      super
    end
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
