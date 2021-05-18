class Indexing::Sources::Digidia < Indexing::Sources::Parents::Filemaker
  def artist_normalized
    an = artist.map { |a|
      a.strip.split(/, /).reverse.join(" ")
    }
    super(an)
  end

  def rights_work
    if is_record_id_a_rights_work_warburg_record_id?
      rights_work_warburg
    elsif is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end
