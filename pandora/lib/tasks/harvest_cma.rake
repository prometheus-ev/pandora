# bundle exec rails harvest:cma
namespace :harvest do
  desc "Harvest CMA JSON data."
  task :cma => :environment do
    if Rails.env.development?
      url = 'https://github.com/ClevelandMuseumArt/openaccess/raw/master/data.json'
      file = '../data/dumps/cma.json'

      puts "Harvesting CMA JSON data from #{url}, this may take a while..."
      # https://ruby-doc.org/stdlib/libdoc/open-uri/rdoc/OpenURI/OpenRead.html#method-i-open
      stream = URI.open(
        url,
        :progress_proc => lambda {|size|
          # https://ruby-doc.org/core/IO.html#method-i-printf
          # https://api.rubyonrails.org/classes/ActiveSupport/NumberHelper.html#method-i-number_to_human_size
          printf("%8s", "#{ActiveSupport::NumberHelper.number_to_human_size(size, precision: 0)}\r")
        }
      )
      IO.copy_stream(stream, file)
      puts
      puts "CMA JSON data saved to file #{file}."
    else
      puts 'Harvesting is only available in a development environment.'
    end
  end
end
