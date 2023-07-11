class Pandora::Indexing::Parser::VgbkParser
  def initialize
    @vgbk_artists_list = Rails.configuration.x.indexing_vgbk_artists[:artists]
  end

  def is_any_artist_in_vgbk_artists_list?(artist_normalized, date_range)
    is_any_artist_in_vgbk_artists_list = artist_normalized.to_a.any? {|a|
      vgbk_artist = CGI.unescape_html(a.to_s.downcase.encode(Encoding::UTF_8))
      @vgbk_artists_list.include?(vgbk_artist)
    }

    if is_any_artist_in_vgbk_artists_list
      if date_range
        # See #181.
        if date_range.to > (Time.now - 170.years)
          true
        else
          false
        end
      else
        true
      end
    else
      false
    end
  end

  def rights_work_vgbk
    'rights_work_vgbk'
  end
end
