require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test 'should handle login names with special characters' do
    assert_recognizes(
      {
        controller: 'accounts',
        action: 'edit',
        locale: 'en',
        id: 'jdoe'
      },
      '/en/accounts/jdoe/edit'
    )

    assert_recognizes(
      {
        controller: 'accounts',
        action: 'edit',
        locale: 'en',
        id: 'wei-Rd:@.st_uff'
      },
      '/en/accounts/wei-Rd:@.st_uff/edit'
    )

    assert_recognizes(
      {
        controller: 'accounts',
        action: 'show',
        locale: 'en',
        id: 'weird stuff ß'
      },
      URI.escape('/en/accounts/weird stuff ß')
    )
  end

  test 'browser without cookies' do
    get '/en/login'
    location = response.location

    reset! # clears cookies
    get location

    assert_match /Sorry, you need to have cookies enabled/, response.body
  end

  test "admin can't manipulate superadmin role" do
    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update roles: Role.where(title: ['admin', 'user'])

    # try to remove superadmin role
    patch '/en/accounts/superadmin', headers: api_auth('jdoe'), params: {
      user: {
        role_ids: Role.where(title: ['user']).pluck(:id)
      }
    }
    assert_not response.successful?
    superadmin = Account.find_by!(login: 'superadmin')
    assert superadmin.has_role?('superadmin')

    # try to add superadmin role
    patch '/en/accounts/jdoe', headers: api_auth('jdoe'), params: {
      user: {
        role_ids: Role.where(title: ['superadmin']).pluck(:id)
      }
    }
    follow_redirect!
    assert response.successful?
    assert_not jdoe.reload.has_role?('superadmin')
  end

  test "useradmin can't change users from other institutions" do
    jdupont = Account.find_by!(login: 'jdupont')

    patch '/en/accounts/jdoe', headers: api_auth('jdupont'), params: {
      user: {
        about: {en: 'An interesting user'}
      }
    }
    assert_not response.successful?
  end

  test "modify expiration date" do
    login_as 'jdupont'

    patch '/en/accounts/jdupont', params: {
      :user => {
        :expires_in => "",
        'expires_at(1i)'.to_sym => "2018",
        'expires_at(2i)'.to_sym => "1",
        'expires_at(3i)'.to_sym => "13"
      }
    }

    jdupont = Account.find_by!(login: 'jdupont')

    assert jdupont.expires_at
    assert_equal(Time.zone.parse("2018-01-13 23:59:59"), Time.zone.parse(jdupont.expires_at.to_s))
  end

  test 'newsletter subscribers are not suggested' do
    subscriber = Account.subscriber_for('subscribe-me@example.com')
    subscriber.email_verified!

    get '/en/accounts/suggest_names', params: {q: 'subscr'}, headers: api_auth('superadmin')
    assert_no_match /Newsletter/, response.body
  end
end
