require 'test_helper'

class PandoraControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to /en/login for non-authenticated users" do
    get '/'
    assert_redirected_to '/en'

    follow_redirect!
    assert_redirected_to '/en/login'
  end

  test "should redirect to /en/searches for jdoe" do
    login_as 'jdoe'
    assert_redirected_to '/en/searches'

    get '/'
    assert_redirected_to '/en'

    follow_redirect!
    assert_redirected_to '/en/searches'
  end

  test 'should redirect to /en/administraton for superadmin' do
    login_as 'superadmin'
    assert_redirected_to '/en/administration'

    get '/en'
    assert_redirected_to '/en/administration'
  end

  test 'remote ip' do
    get '/en/remote_ip?verbose=1'
    assert_match /REMOTE_ADDR/, response.body
  end

  test 'correct handling of /sitemap.txt' do
    assert_raises ActionController::UnknownFormat do
      get '/sitemap.txt'
      follow_redirect!
    end
  end
end