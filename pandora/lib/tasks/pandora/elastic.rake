# TODO: probably not needed anymore
# namespace :pandora do
#   task elastic_backup: :environment do
#     elastic = Pandora::Elastic.new
#     elastic.ensure_backup_repo
#     elastic.snapshot
#   end

#   task elastic_restore: :environment do
#     elastic = Pandora::Elastic.new
#     elastic.restore
#   end
# end
