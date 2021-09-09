namespace :pandora do
  namespace :index do
    desc 'show the status of the indices and the pandora database and backup files'
    task status: :environment do
      Indexing::IndexTasks.new(verbose: true).status
    end

    desc 'dump one, several, or all indices from elasticsearch to a file (e.g INDEX="daumier robertin", or INDEX="all")'
    task dump: :environment do
      index_arg = (ENV['INDEX'] || '').downcase.split(/\s+/)
      Indexing::IndexTasks.new(verbose: true).dump(index_arg)
    end

    desc 'load one, several, or all backup indices into elasticsearch (e.g INDEX="daumier robertin", or INDEX="all"); update mapping (optional, e.g. UPDATE_MAPPING=true)'
    task load: :environment do
      index_arg = (ENV['INDEX'] || '').downcase.split(/\s+/)
      update_mapping_arg = ENV['UPDATE_MAPPING'] == 'true' ? true : false
      Indexing::IndexTasks.new(verbose: true).load(index_arg, update_mapping_arg)
    end

    desc 'drop one, several, or all indices (see dump task for selection)'
    task drop: :environment do
      index_arg = (ENV['INDEX'] || '').downcase.split(/\s+/)
      index_arg = :all if index_arg == ['all']
      Indexing::IndexTasks.new(verbose: true).drop(index_arg)
    end

    desc 'check one, several, or all backup indices for consistency (unfinished, see dump task for selection)'
    task check: :environment do
      index_arg = (ENV['INDEX'] || '').downcase.split(/\s+/)
      index_arg = :all if index_arg == ['all']
      Indexing::IndexTasks.new(verbose: true).check(index_arg)
    end

    desc 'revert one, several, or all indices to the previous version'
    task revert: :environment do
      index_arg = (ENV['INDEX'] || '').downcase.split(/\s+/)
      index_arg = :all if index_arg == ['all']
      Indexing::IndexTasks.new.revert(index_arg)
    end

    desc 'update VGBK artists'
    task update_vgbk_artists: :environment do
      Indexing::IndexTasks.new(verbose: true).update_vgbk_artists
    end

    desc 'update PKND artists'
    task update_pknd_artists: :environment do
      Indexing::IndexTasks.new(verbose: true).update_pknd_artists
    end
  end
end
