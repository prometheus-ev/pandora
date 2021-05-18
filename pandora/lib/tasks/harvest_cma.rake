# bundle exec rake harvest:cma

namespace :harvest do
  desc "Harvest CMA JSON data."
  task :cma => :environment do
    if Rails.env.development?
      url = 'https://github.com/ClevelandMuseumArt/openaccess/raw/master/data.json'
      file = '../data/dumps/cma.json'

      puts "Harvesting CMA JSON data from #{url}, this may take a while..."
      IO.copy_stream(open(url), file)
      puts "CMA JSON data saved in file #{file}."
    else
      puts 'Harvesting is only available in a development environment.'
    end
  end
end
