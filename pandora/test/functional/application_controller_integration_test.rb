require 'test_helper'

class ApplicationControllerIntegrationTest < ActionDispatch::IntegrationTest
  test 'handling 404 (when using basic auth)' do
    # without basic auth, we are simply redirected to the login path
    get '/en/image/heidicon_kg-090f8f0281d685234a265072de6ca18f6b56ddd4'
    assert_match '/en/login', response.location

    # with (wrong) basic auth credentials, we should get a proper 401
    get(
      '/en/image/heidicon_kg-090f8f0281d685234a265072de6ca18f6b56ddd4',
      headers: api_auth('jdoe', 'wrong-secret')
    )
    assert_equal 401, response.status
  end
end
