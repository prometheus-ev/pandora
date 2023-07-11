class Indexing::RightsWorkArtistUpdater
  def initialize
    @non_vgbk_artists_list = Rails.configuration.x.indexing_non_vgbk_artists[:artists]
  end

  def run(validated_fields)
    artist_normalized = validated_fields['artist_normalized']

    if validated_fields['rights_work'].blank? && !artist_normalized.blank?
      unless (artist_normalized_selected = artist_normalized.select{|an|@non_vgbk_artists_list.include?(an.encode(Encoding::UTF_8))}).empty?
        validated_fields['rights_work'] = artist_normalized_selected
      end
    end

    validated_fields
  end
end
