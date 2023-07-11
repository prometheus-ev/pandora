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

  def date_range
    d = date.strip.chomp('.')

    if d == '1896.'
      d = '1896'
    elsif d == '12170-75 (?)'
      d = '1270-75 (?)'
    elsif d == 'um 1240750'
      d = 'um 1240'
    end

    super(d)
  end
end
