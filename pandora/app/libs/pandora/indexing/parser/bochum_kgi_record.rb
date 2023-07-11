class Pandora::Indexing::Parser::BochumKgiRecord < Pandora::Indexing::Parser::Parents::DilpsRecord
  def path
    path_for(nil, true)
  end

  def date_range
    return @date_range if @date_range

    d = date.strip.chomp('.')

    if d == '1896.'
      d = '1896'
    elsif d == '12170-75 (?)'
      d = '1270-75 (?)'
    elsif d == 'um 1240750'
      d = 'um 1240'
    end

    @date_range = @date_parser.date_range(d)
  end

  def rights_work
    if @warburg_parser.is_record_id_a_rights_work_warburg_record_id?(record_id, name)
      @warburg_parser.rights_work_warburg
    elsif @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end
end
