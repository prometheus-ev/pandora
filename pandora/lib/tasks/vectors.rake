namespace :pandora do
  namespace :vectors do
    desc 'fetch image vectors (e.g. INDEX="daumier robertin" VECTORS=dominant_colors)'
    task fetch: :environment do
      index_arg = (ENV['INDEX'] || '').downcase.split(/\s+/)
      vector_arg = (ENV['VECTORS'] || '').downcase.split(/\s+/)
      Pandora::ImageVectors.for_sources(index_arg, vector_arg)
    end

    desc 'drop image vectors (e.g. INDEX="daumier robertin")'
    task drop: :environment do
      index_arg = (ENV['INDEX'] || '').downcase.split(/\s+/)
      Pandora::ImageVectors.drop(index_arg)
    end
  end
end
