require 'test_helper'

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "users can't access it" do
    login_as 'jdoe'

    get '/en/stats/new'
    assert_access_denied

    post '/en/stats'
    assert_access_denied

    get '/en/stats/facts'
    assert_access_denied

    post '/en/stats/facts'
    assert_access_denied
  end

  test "admins have access" do
    login_as 'superadmin'

    get '/en/stats/new'
    assert_ok

    post '/en/stats', params: {
      csv_stats: {issuer: 'prometheus'}
    }
    assert_ok

    get '/en/stats/facts'
    assert_ok

    post '/en/stats/facts', params: {
      date: {top_terms_year: 2020, top_terms_month: 12}
    }
    assert_ok
  end

  test "useradmins have only access to (their) stats" do
    login_as 'jdupont'

    get '/en/stats/new'
    assert_ok

    post '/en/stats', params: {csv_stats: {institution: 'nowhere'}}
    assert_ok

    assert_raises NoMethodError do
      post '/en/stats', params: {csv_stats: {institution: 'prometheus'}}
    end

    get '/en/stats/facts'
    assert_access_denied

    post '/en/stats/facts', params: {
      date: {top_terms_year: 2020, top_terms_month: 12}
    }
    assert_access_denied
  end
end
