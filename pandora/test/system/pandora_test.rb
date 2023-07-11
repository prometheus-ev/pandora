require "application_system_test_case"

class PandoraTest < ApplicationSystemTestCase
  test 'about'do
    visit '/en/about'
    assert_text Rails.version
  end

  test 'sitemap' do
    visit '/'
    click_on 'Sitemap'
    assert_text 'Searching and finding'
    assert_no_text 'As an administrator, you have additional options'

    login_as 'superadmin'

    click_on 'Sitemap'
    assert_text 'As an administrator, you have additional options'

    login_as 'jdoe'

    click_on 'Sitemap'
    click_on 'Your collections'
    assert_text "John's private collection"

    click_on 'Sitemap'
    click_on 'Your shared collections'
    assert_text "No collections found"
  end

  test 'terms of use' do
    skip '#1573 We now link to the PDF file directly.'

    visit '/'
    click_on 'Terms of use'
    assert_text 'Please read the terms of use carefully!'
  end

  test 'api help page' do
    visit '/en/api'

    # we are happy with no errors for now
    assert_text 'The prometheus image archive API'
  end

  test 'send feedback' do
    visit '/'
    click_on 'Feedback'
    fill_in 'Your name (optional)', with: 'Klaus'
    fill_in 'Your e-mail address (optional)', with: 'klaus@example.com'

    answer_brain_buster
    submit # try without message
    assert_text 'Your message was empty'

    fill_in 'Your message', with: 'Great App!'
    submit
    assert_text 'Your feedback has been delivered'

    assert_equal 2, ActionMailer::Base.deliveries.size

    notification = ActionMailer::Base.deliveries[0]
    assert_match /submitted the following feedback/, notification.body.to_s

    copy = ActionMailer::Base.deliveries[1]
    assert_match /thank you very much for your feedback/, copy.body.to_s
  end

  test 'language switch with query string' do
    visit '/en/help/index?some=thing'
    click_on 'Deutsch'
    assert_match /some=thing/, current_url
  end

  test 'conference signup' do
    visit '/en/conference_sign_up'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    fill_in 'City', with: 'Frankfurt am Main'
    fill_in 'Street', with: 'Am Dreiklang 8'
    fill_in 'Postal code', with: '44532'
    fill_in 'Country', with: 'Germany'
    submit # try omitting the brain buster

    assert_text 'Your captcha answer failed'
    answer_brain_buster
    submit

    assert_text 'Your registration was sucessful'
    mails = ActionMailer::Base.deliveries
    assert_equal 2, mails.size
    assert_equal 'Anmeldung zur Tagung - Hans Mustermann', mails[0].subject
    assert_match /^Anmeldung zur Tagung: /, mails[1].subject
  end

  test 'navigation (Administration button)' do
    visit '/en'
    assert_no_text 'Administration'

    login_as 'jdoe'
    assert_no_text 'Administration'

    login_as 'superadmin'
    assert_text 'Administration'

    login_as 'jdupont'
    assert_text 'Administration'
  end

  test 'env overrides' do
    assert_equal 'data-0', ENV['PM_TEST_VARIABLE']

    url = "http://#{Capybara.server_host}:#{Capybara.server_port}"
    response = Faraday.get("#{url}/api/json/about")
    data = JSON.parse(response.body)
    assert_equal 'data-0', data['PM_TEST_VARIABLE']

    with_env 'PM_TEST_VARIABLE' => 'data-1' do
      assert_equal 'data-1', ENV['PM_TEST_VARIABLE']

      response = Faraday.get("#{url}/api/json/about")
      data = JSON.parse(response.body)
      assert_equal 'data-1', data['PM_TEST_VARIABLE']
    end

    response = Faraday.get("#{url}/api/json/about")
    data = JSON.parse(response.body)
    assert_equal 'data-0', data['PM_TEST_VARIABLE']
  end
end
