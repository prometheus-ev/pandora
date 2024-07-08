# bundle exec rails harvest:rmn
#
# API: https://api.art.rmngp.fr/
namespace :harvest do
  desc "Harvest RMN API JSON data."
  task rmn: :environment do
    if Rails.env.development?
      count = 0
      collections = []
      page = 1
      per_page = 100
      museums = {
        "rmn_musee_du_louvre": "Musée du Louvre",
        "rmn_musee_de_orsay": "Musée d'Orsay",
        "rmn_musee_national_dart_moderne": "Centre national d'art et de culture Georges-Pompidou"
      }

      puts "Enter API key:"
      api_key = STDIN.noecho(&:gets).chomp
      puts "Select the museum to harvest:"
      museums.values.each_with_index{|museum, i| puts "#{i}. #{museum}"}
      museum_index = STDIN.gets.chomp.to_i
      museum_name = museums.keys[museum_index]
      museum_title = museums.values[museum_index]

      puts "You selected the \"#{museum_title}\"."
      puts
      puts "Harvesting RMN API collections:"

      url = 'https://api.art.rmngp.fr/v1/thesaurus/collections'

      response = Faraday.get(
        url,
        {per_page: per_page, page: page},
        {ApiKey: api_key}
      )

      json = JSON.parse(response.body)
      json['hits']['hits'].each do |t|
        printf "."
        collections << t['_source']['name']['fr']
      end
      puts

      page += 1

      dir = "../data/dumps/#{museum_name}"

      if Dir.exist?(dir)
        FileUtils.remove_entry_secure dir
      end

      FileUtils.mkdir_p dir

      puts
      puts "Harvesting RMN API works:"

      collection_no = 1

      begin
        collections.each do |collection|
          page = 1
          url = "https://api.art.rmngp.fr/v1/works"
          q = "location.name.fr:\"#{museum_title}\" AND collections.name.fr:\"#{collection}\""

          response = Faraday.get(
            url,
            {per_page: per_page, page: page, q: q},
            {ApiKey: api_key}
          )

          json = JSON.parse(response.body)

          if json['hits']['total'] == 0
            puts "No hits in collection #{collection}."
            next
          else
            puts "Collection #{collection_no}: #{collection}"
            puts "Number of objects: #{json['hits']['total']}"
            count += json['hits']['total']
          end

          begin
            while true
              url = "https://api.art.rmngp.fr/v1/works"
              file = "#{collection_no}-#{page}.json"

              response = Faraday.get(
                url,
                {per_page: per_page, page: page, q: q},
                {ApiKey: api_key}
              )

              json = JSON.parse(response.body)

              if json['hits']['hits'].empty?
                raise
              end

              File.open("#{dir}/#{file}", "w") do |f|
                f.write(response.body)
              end

              puts "Writing #{json['hits']['hits'].size} objects to file #{file}"

              page += 1
            end
          rescue Exception => e
            puts '---'
          end

          collection_no += 1
        end
      rescue Exception => e
        puts "\n" + e.message
      end

      puts "Downloaded #{count} objects."
      puts 'Finished!'
    else
      puts 'Harvesting is only available in a development environment.'
    end
  end
end
