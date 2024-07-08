require 'test_helper'

class LocaleRoutingTest < ActionDispatch::IntegrationTest
  test 'redirect /* to respective locale prefix (not logged in)' do
    get '/'
    assert_redirected_to '/en'

    get '/en'
    assert_redirected_to '/en/login'

    get '/de'
    assert_redirected_to '/de/login'

    get '/', headers: {
      'accept-language' => 'fr-CH, fr;q=0.9, en;q=0.8, de;q=0.7, *;q=0.5fr-FR'
    }
    assert_redirected_to '/en'

    assert_raises ActionController::RoutingError do
      get '/en/something'
    end

    get '/subscribe'
    assert_redirected_to '/en/subscribe'

    get '/signup'
    assert_redirected_to '/en/signup'

    get '/signup', headers: {'accept-language' => 'de'}
    assert_redirected_to '/de/signup'
  end

  test 'redirect /* to respective locale prefix (logged in as jdoe)' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.account_settings.update_column :locale, 'de'

    # this is just to login and set the cookie
    get '/de', headers: api_auth('jdoe')
    assert_redirected_to '/de/searches'

    get '/'
    assert_redirected_to '/de'

    get '/en'
    assert_redirected_to '/en/searches'

    get '/de'
    assert_redirected_to '/de/searches'

    assert_raises ActionController::RoutingError do
      get '/en/something'
    end

    get '/subscribe'
    assert_redirected_to '/de/subscribe'

    get '/signup'
    assert_redirected_to '/de/signup'

    get '/signup', headers: {'accept-language' => 'en'}
    assert_redirected_to '/de/signup'
  end
end
