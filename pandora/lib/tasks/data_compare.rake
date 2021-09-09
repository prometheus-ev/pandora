require 'rest-client'
require 'json'
require 'io/console'

namespace :pandora do
  desc 'record data comparison localhost staging or production'
  task data_compare: :environment do
    env = ENV['ENV'] || 'production'
    index = ENV['INDEX']

    if env == 'production'
      env = 'prometheus'
    else
      env = 'prometheus2'
    end

    if index.blank?
      raise 'Please provide an INDEX environment variable with the index that shall be compared.'
    end

    per_page = 100

    puts "Enter a #{env} user:"
    user = STDIN.gets.chomp
    puts "Enter password:"
    password = STDIN.noecho(&:gets).chomp

    url = 'http://localhost:3000/api/json/source/show'
    headers = {:Authorization => api_auth('superadmin', 'superadmin')['Authorization'], params: {id: index}}
    response = RestClient.get url, headers
    json = JSON.parse(response.body)
    puts "#{json['record_count']} local records"

    url = "https://#{env}.uni-koeln.de/api/json/source/show"
    headers = {:Authorization => api_auth(user, password)['Authorization'], params: {id: index}}
    response = RestClient.get url, headers
    json_remote = JSON.parse(response.body)
    puts "#{json_remote['record_count']} remote records"

    if json_remote['record_count'] == json['record_count']
      puts 'Record count matches!'
    else
      Rails.logger.warn 'Unequal record count!'
    end

    pages = json_remote['record_count'] / per_page
    pages += 1 if json_remote['record_count'] % per_page != 0

    (1..pages).each do |page|
      puts "Page #{page}/#{pages}"

      url = 'http://localhost:3000/api/json/search/index'
      headers = {:Authorization => api_auth('superadmin', 'superadmin')['Authorization'], params: {s: [index], term: '*', per_page: per_page, page: page}}
      response = RestClient.get url, headers
      json = JSON.parse(response.body)

      json.each do |record|
        id = record['pid']
        printf '.'

        url = 'http://localhost:3000/api/json/image/show'
        headers = {:Authorization => api_auth('superadmin', 'superadmin')['Authorization'], params: {id: id}}
        response = RestClient.get url, headers
        json = JSON.parse(response.body)

        url = "https://#{env}.uni-koeln.de/api/json/image/show"
        headers = {:Authorization => api_auth(user, password)['Authorization'], params: {id: id}}
        response = RestClient.get url, headers
        json_remote = JSON.parse(response.body)

        json.keys.each do |key|
          next if key == 'source' || key == 'database' || key == 'rating'
          next if json[key].blank? && json_remote[key].blank?

          if json[key]
            if json[key] != json_remote[key]
              next if key == 'title' && json[key] == '[Titel nicht vorhanden]' && json_remote[key].blank?
              next if key == 'rights_work' && json[key] == 'Nicht bekannt' && json_remote[key].blank?
              next if key == 'rights_reproduction' && json[key] == 'Nicht bekannt' && json_remote[key].blank?
              next if key == 'credits' && json[key] == '[Bildnachweis nicht vorhanden]' && json_remote[key].blank?
              puts '-' * 100
              puts id
              puts key
              puts "Local value:  #{json[key]}"
              puts "Remote value: #{json_remote[key]}"
              puts '-' * 100
            end
          else
            puts '-' * 100
            puts id
            puts "#{key} locally unavailable."
            puts "Local value:  #{json[key]}"
            puts "Remote value: #{json_remote[key]}"
            puts '-' * 100
          end
        end
      end

      puts
    end
  end
end

def api_auth(user, password = nil)
  password = password || (user.size >= 8 ? user : user * 2)
  data = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
  {'Authorization' => data}
end
