require 'test_helper'

class MapquestRequestTest < ActionDispatch::IntegrationTest
  # brittle because api seems to respond with 301 (sometimes)
  if ENV['PM_BRITTLE'] == 'true'
    test 'test reverse request nominatim API response' do
      url = 'https://www.mapquestapi.com/geocoding/v1/reverse?key=6cGTYTOCsUvGsEtmAr07AQbHE3mxeTAQ&location=50.91517,6.94199'

      res = Net::HTTP.get_response(URI(url))

      assert_equal '200', res.code
    end

    test 'test search request nominatim API response' do
      url = 'https://www.mapquestapi.com/geocoding/v1/address?key=6cGTYTOCsUvGsEtmAr07AQbHE3mxeTAQ&location=Bernhard-Feilchenfeld-Stra%C3%9Fe%2011'

      res = Net::HTTP.get_response(URI(url))

      assert_equal '200', res.code
    end

    test 'test tile sector request API response' do
      url = 'http://tileproxy.cloud.mapquest.com/attribution?format=json&cat=map&loc=6.7545318603515625,50.850174109831975,7.1294403076171875,50.9800470463021&zoom=11'

      res = Net::HTTP.get_response(URI(url))

      assert_equal '200', res.code
    end
  end

  test 'test tile request API response' do
    skip 'Not used right now and not working anymore with our MapQuest account. ' +
      'If we need it in the future we might have to add a Mapbox account.'

    url = 'https://api.mapbox.com/styles/v1/mapquest/ck62awhdx0g1g1iqqv9u80q6i/tiles/256/11/1067/687?access_token=pk.eyJ1IjoibWFwcXVlc3QiLCJhIjoiY2Q2N2RlMmNhY2NiZTRkMzlmZjJmZDk0NWU0ZGJlNTMifQ.mPRiEubbajc6a5y9ISgydg'

    res = Net::HTTP.get_response(URI(url))

    assert_equal '200', res.code
  end
end
