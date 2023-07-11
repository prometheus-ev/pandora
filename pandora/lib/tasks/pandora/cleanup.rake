namespace :pandora do
  desc 'cleanup stale records from various tables'
  task cleanup: :environment do
    Pandora::Cleanup.new.all
  end

  desc 'verify institution hostnames with a DNS resolver'
  task verify_hostnames: :environment do
    Pandora::HostnameVerifier.new.run
  end
end
