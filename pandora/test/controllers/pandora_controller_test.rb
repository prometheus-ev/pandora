require 'test_helper'

class PandoraControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to /en/login for non-authenticated users" do
    get '/'
    assert_redirected_to '/en'

    follow_redirect!
    assert_redirected_to '/en/login'
  end

  test 'should not crash with invalid format' do
    login_as 'jdoe'

    assert_nothing_raised do
      get '/en/start.asp'
    end
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

    assert_raises ActionController::UnknownFormat do
      get '/en/help/RELEASE_NOTES.txt'
      follow_redirect!
    end
  end

  test 'correct locale redirect handling' do
    assert_nothing_raised do
      get '/', params: {locale: 'invalid'}
    end

    # it shouldn't raise a I18n::InvalidLocale
  end

  # TODO: this can't be tested at the moment because Rack::Test catches the
  # bogus url before sending it to rails, see also
  # https://github.com/rack/rack-test/issues/266
  # test "don't send notifications for ActionController::BadRequest" do
  #   path = '%%3C%2Fscript%3E%3Cscript%3Ealert%28document.domain%29%3C%2Fscript%3E'
  #   get path
  # end

  test 'uses correct exception notifier code' do
    # test exception raiser action
    assert_raises ActionDispatch::Http::MimeNegotiation::InvalidType do
      get '/en/raise_exception', params: {
        exception: 'ActionDispatch::Http::MimeNegotiation::InvalidType'
      }
    end

    # the exception is raised and error details are rendered (test/development
    # behavior)
    assert_raises I18n::InvalidLocale do
      get '/en/raise_exception', params: {exception: 'I18n::InvalidLocale'}
    end
    assert 1, ActionMailer::Base.deliveries.count

    # nothing will be raised, a error page is rendered (production behavior)
    with_env 'PM_PRODUCTION_ERROR_HANDLING' => 'true' do
      get '/en/raise_exception', params: {exception: 'I18n::InvalidLocale'}
    end
    assert 2, ActionMailer::Base.deliveries.count
  end
end