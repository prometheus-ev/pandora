namespace :pandora do
  desc 'record data comparison localhost staging'
  task staging_data_compare: :environment do
    raise Pandora::Exception, 'copied from unit tests, task needs to be fixed'

    index = 'robertin'
    per_page = 100

    Indexing::Index.delete(index + '*')
    Indexing::IndexTasks.new.load([index])

    puts "Enter a staging user:"
    user = STDIN.gets.chomp
    puts "Enter password:"
    password = STDIN.noecho(&:gets).chomp

    get '/api/json/source/show', params: {id: index}, headers: api_auth('jdoe')
    puts "#{json['record_count']} local records"

    url = 'https://prometheus2.uni-koeln.de/api/json/source/show'
    headers = {:Authorization => api_auth(user, password)['Authorization'], params: {id: index}}
    response = RestClient.get url, headers
    json_staging = JSON.parse(response.body)
    puts "#{json_staging['record_count']} staging records"

    assert_equal json_staging['record_count'], json['record_count']

    pages = json_staging['record_count'] / per_page
    pages += 1 if json_staging['record_count'] / per_page != 0

    (1..pages).each do |page|
      puts "Page #{page}/#{pages}"
      get '/api/json/search/search', params: {s: [index], term: '*', per_page: per_page, page: page}, headers: api_auth('jdoe')

      json.each do |record|
        id = record['pid']
        printf '.'

        get '/api/json/image/show', params: {id: id}, headers: api_auth('jdoe')

        url = 'https://prometheus2.uni-koeln.de/api/json/image/show'
        headers = {:Authorization => api_auth(user, password)['Authorization'], params: {id: id}}
        response = RestClient.get url, headers
        json_staging = JSON.parse(response.body)

        json.keys.each do |key|
          next if key == 'source' || key == 'rating'
          if json[key]
            assert_equal json[key], json_staging[key], "#{key}, #{id}"
          else
            assert_nil json[key], "#{key}, #{id}"
            assert_nil json_staging[key], "#{key}, #{id}"
          end
        end
      end

      puts
    end
  end
end