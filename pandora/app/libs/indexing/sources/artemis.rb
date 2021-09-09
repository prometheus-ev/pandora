class Indexing::Sources::Artemis < Indexing::Sources::Parents::Artemis
  def records
    document.xpath('//datensatz[not(contains(bemerkung, "Bayerische Kunstgeschichte"))]')
  end

  def path
    return miro if miro?

    super
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
