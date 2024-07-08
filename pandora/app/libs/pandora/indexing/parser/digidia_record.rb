class Pandora::Indexing::Parser::DigidiaRecord < Pandora::Indexing::Parser::Parents::FilemakerRecord
  def artist_normalized
    return @artist_normalized if @artist_normalized

    an = artist.map {|a|
      a.strip.split(/, /).reverse.join(" ")
    }

    @artist_normalized = @artist_parser.normalize(an)
  end

  def rights_work
    if @warburg_parser.is_record_id_a_rights_work_warburg_record_id?(record_id, name)
      @warburg_parser.rights_work_warburg
    elsif @vgbk_parser.is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
      @vgbk_parser.rights_work_vgbk
    end
  end
end