require 'test_helper'

class ImageRequestTest < ActionDispatch::IntegrationTest
  test 'image from non existing source' do
    get '/en/image/no_exist-cc4ba69925f263ef64904360aa469db335e7c07a', headers: api_auth('jdoe')
    assert_match /File not found/, response.body

    get '/de/image/no_exist-cc4ba69925f263ef64904360aa469db335e7c07a', headers: api_auth('jdoe')
    assert_match /Datei nicht gefunden/, response.body
  end

  test 'non existing images' do
    pids = ["robertin-xxx", "robertinxxx", "upload-xxx", "upload-", "-xxx", "xxx"]
    pids.each do |pid|
      get "/en/image/#{pid}", headers: api_auth('jdoe')
      assert_response :missing
    end
  end
end