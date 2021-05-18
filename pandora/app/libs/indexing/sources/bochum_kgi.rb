class Indexing::Sources::BochumKgi < Indexing::Sources::Parents::Dilps
  def path
    path_for(nil, true)
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
