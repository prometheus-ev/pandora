class Indexing::Sources::GiessenKup < Indexing::Sources::Parents::Filemaker
  def artist
    record.xpath('.//nachname/text()').map {|artist|
      artist.to_s.split(" / ")
    }.flatten
  end

  def artist_normalized
    an = artist.map { |a|
      a.gsub(/ \(.*/, '')
    }
    super(an)
  end

  def rights_work
    if is_any_artist_in_vgbk_artists_list?
      rights_work_vgbk
    end
  end
end


