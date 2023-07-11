class Pandora::Indexing::Parser::ArtistParser
  def initialize
    @artist_attributions = Rails.configuration.x.indexing_artist_attributions[:attributions]
  end

  def normalize(artists)
    # In case it is a single artist.
    artists = artists.to_a
    artists.map! { |a|
      a = a.to_s.encode(Encoding::UTF_8)

      @artist_attributions.each { |artist_attribution|
        a.delete_prefix!(artist_attribution)
        a.delete_suffix!(artist_attribution)
        a.strip!
      }

      a
    }
  end
end
