require 'net/http'
require 'json'
require 'uri'

namespace :harvest do

  desc 'Harvest Statens Museum for Kunst, Copenhagen data'
  task harvest_smk_dk: :environment do
    BASE_URL = "http://api.smk.dk/api/v1/"

    art_all_ids_url = BASE_URL + "art/all_ids"

    # api art_all_ids request often returns response with incomplete JSON;
    art_all_ids = get_and_parse_response_until_success(parse_url(art_all_ids_url))
    # art_all_ids = parse_response_as_json(get_response_with_retry(parse_url(art_all_ids_url)))

    puts "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
    puts "<smk>"

    # total = art_all_ids["total"] # currently[July 2019]: 82458
    if art_all_ids["objectIDs"]
      art_all_ids["objectIDs"].each do |objectID|

        art_url = BASE_URL + "art/?object_number=#{objectID}"
        art = parse_response_as_json(get_response_with_retry(parse_url(art_url)))

        if art["items"]
          art["items"].each do |art|
            if art["production"]
              art["production"].each do |production|
                if  production["creator_lref"]
                  person_url = BASE_URL + "person/?id=#{production["creator_lref"]}"
                  creator = parse_response_as_json(get_response_with_retry(parse_url(person_url)))
                  production["creator"] = creator
                end
              end
            end

            puts art.to_xml(:root => :art, :skip_instruct => true)

          end
        end
      end
    end

    puts "</smk>"

  end

  # tries to get art_all_ids response until response complete and parseable as JSON
  def get_and_parse_response_until_success(uri)
    begin
      begin
        response = Net::HTTP.get(uri)
      rescue SocketError, Net::ReadTimeout, Net::OpenTimeout
        retry
      end
      JSON.parse(response)
    rescue JSON::ParserError
      retry
    end
  end

  def get_response_with_retry(uri, retry_attempts=3)
    Net::HTTP.get(uri)
  rescue SocketError, Net::ReadTimeout, Net::OpenTimeout
    if retry_attempts > 0
      retry_attempts -= 1
      sleep 5 
      retry
    end
    debugger
    # raise
  end

  def parse_response_as_json(response)
    JSON.parse(response)
  rescue JSON::ParserError
    debugger
    # raise
  end

  def parse_url(url)
    URI.parse(url)
  rescue URI::InvalidURIError
    URI.parse(URI.escape(url))
  end

end