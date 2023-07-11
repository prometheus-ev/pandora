class Pandora::Indexing::Parser::ArtemisRecord < Pandora::Indexing::Parser::Parents::ArtemisRecord
  def path
    return @miro_parser.miro if @miro_parser.miro?(record_id, name)

    super
  end

  def rights_work
    if @warburg_parser.is_record_id_a_rights_work_warburg_record_id?(record_id, name)
      @warburg_parser.rights_work_warburg
    elsif @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end
end
