require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test 'can login with correct credentials' do
    login_as 'jdoe', 'jdoejdoe'
    assert_text 'Welcome, John Doe!'
  end

  test 'cannot login with wrong credentials' do
    login_as 'jdoe', 'wrong'
    assert_text 'Invalid user name or password!'

    login_as 'jnobody', 'secret'
    assert_text 'Invalid user name or password!'
  end

  test 'too many logins' do
    login_as 'jdoe', 'wrong'
    login_as 'jdoe', 'wrong'
    login_as 'jdoe', 'wrong'
    login_as 'jdoe', 'jdoejdoe'

    assert_text 'Too many failed login attempts!'
  end

  test 'sign in via ip' do
    TestSource.index

    pid = pid_for(1)
    # we also test return_to
    visit "/en/image/#{pid}"
    assert_text 'Please log in first'

    within '#campus_login_wrap' do
      find('.submit_button').click
    end
    assert_text 'Bitte akzeptieren Sie unsere Nutzungsbedingungen'

    # has to be German sentence because mobile app checks against it
    check 'I read the terms of use carefully and agree!'
    find('.submit_button').click

    assert_no_text 'Please accept our terms'
    assert_text 'Nowhere University (Log out)'
    assert_text "Raphael"

    # we log out to test return_to while accepting the terms immediately
    click_on 'Log out'
    visit "/en/image/#{pid}"
    within '#campus_login_wrap' do
      check 'I accept the terms of use'
      find('.submit_button').click
    end
    assert_no_text 'Please accept our terms'
    assert_text 'Raphael'
  end

  test 'sign in via unlicensed institution' do
    nowhere = Institution.find_by(name: 'nowhere')
    nowhere.license.update_column :expires_at, 2.weeks.ago

    visit '/en/login'
    assert_text 'Nowhere University (Not licensed!)'

    visit '/en/campus'
    assert_text 'Your institution Nowhere University does no longer hold a license'
  end

  test 'sign in via ip (without a matching institution)' do
    # this can happen (e.g.) when the campus login url is bookmarked
    nowhere = Institution.find_by(name: 'nowhere')
    nowhere.destroy

    visit '/de/campus'
    assert_text "Es tut uns leid, Ihre IP-Adresse 127.0.0.1 gehört nicht zu einer lizenzierten Institution"
  end

  test 'sign in via ip and keep locale' do
    # we force the German locale
    visit '/de/login'

    within '#campus_login_wrap' do
      find('.submit_button').click
    end

    # we also expect to see the German version of the terms agreement, but the
    # interface will only be translated in testing after #998
    assert_text 'Nutzungsbedingungen'
    check 'Ich habe die Nutzungsbedingungen sorgfältig durchgelesen und stimme ihnen zu!'
    submit

    assert_equal '/de/searches', current_path
  end


  test 'logout' do
    login_as 'jdoe'
    click_on 'Log out'
    assert_no_text 'John Doe'
    assert_text 'Welcome to the prometheus image archive!'
    assert_text 'Sign up / Log in'

    ENV['PM_LOGOUT_URL'] = 'https://prometheus-bildarchiv.de'
    login_as 'jdoe'
    click_on 'Log out'
    assert_match 'https://prometheus-bildarchiv.de', current_url
  end

  test 'login with universal password' do
    login_as 'jdoe', 'secret'
    assert_text 'Welcome, John Doe'
  end

  test "don't ask to accept terms twice" do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_columns(
      accepted_terms_of_use_revision: 4,
      research_interest: 'n.a.'
    )

    login_as 'jdoe'
    # TODO Remove German version of flash notice after the prometheus app has been updated for prometheus-ng.
    # The legacy app checks this sentence in German.
    # assert_text 'Please accept our terms of use'
    assert_text 'Bitte akzeptieren Sie unsere Nutzungsbedingungen'
    check 'I read the terms of use carefully and agree!'
    submit 'Proceed...'

    click_on 'Log out'
    login_as 'jdoe'

    assert_no_text 'Please accept our terms of use'
  end

  test 'stay logged in' do
    manage = Capybara.current_session.driver.browser.manage

    # try without
    login_as 'jdoe'

    # remove the actual session cookie (simulates browser close)
    manage.delete_cookie '_pandora_session'

    visit '/'
    assert_text 'Please log in first'

    # now with 'staying logged in'
    login_as 'jdoe', nil, true

    # verify the existence of the auth cookie
    cookie = manage.cookie_named('auth_token')
    assert_not_nil cookie
    assert cookie[:expires] > 13.days.from_now
    assert cookie[:expires] < 15.days.from_now

    # remove the actual session cookie (simulates browser close)
    manage.delete_cookie '_pandora_session'

    visit '/'
    assert_text 'Welcome, John Doe'
    assert_no_text 'Please log in first'

    # however, I should still be able to log out
    click_on 'Log out'
    visit '/'
    assert_text 'Welcome to the prometheus image archive'
  end

  test 'banning' do
    login_as 'jdoe', 'wrong'
    assert_text 'Invalid user name or password'

    login_as 'jdoe', 'wrong'
    assert_text 'Invalid user name or password'

    login_as 'jdoe', 'wrong'
    assert_text 'Invalid user name or password'

    login_as 'jdoe', 'wrong'
    assert_no_text 'Invalid user name or password'
    assert_text 'Too many failed login attempts'

    # jdoe is banned so the correct password also doesn't help
    login_as 'jdoe'
    assert_no_text 'Invalid user name or password'
    assert_text 'Too many failed login attempts'

    # after 10 minutes, the bann should have been lifted
    travel_to 15.minutes.from_now do
      login_as 'jdoe', 'wrong'
      assert_text 'Invalid user name or password'
      assert_no_text 'Too many failed login attempts'

      login_as 'jdoe'
      assert_text 'Welcome, John Doe'
    end
  end

  test 'signing in with expired account' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update expires_at: 3.weeks.ago

    login_as 'jdoe'
    assert_text 'Welcome, John Doe'
    assert_text 'Your account has expired'
  end


  test 'sign in with clickandbuy user' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update expires_at: 6.years.ago, mode: 'clickandbuy'

    login_as 'jdoe'
    assert_text 'Welcome, John Doe'
    assert_text 'Your account has expired'
  end

  test 'sign in with account that is about to expire' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update expires_at: 5.days.from_now

    login_as 'jdoe'
    assert_text 'Your account is about to expire on'
    assert_text 'You can obtain a new license'
  end
end
