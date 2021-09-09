# bundle exec rake pandora:deploy:synonyms

namespace :pandora do
  namespace :deploy do
    desc "Copy synonyms to NFS."
    task :synonyms => :environment do
      cmd = "scp config/synonyms/*.txt prometheus1.uni-koeln.de:/nfs/prometheus/ng/staging/synonyms/"
      system(cmd)
      cmd = "scp config/synonyms/*.txt prometheus1.uni-koeln.de:/nfs/prometheus/ng/production/synonyms/"
      system(cmd)
    end
  end
end
