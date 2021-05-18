require 'test_helper'

class NewslettersControllerTest < ActionDispatch::IntegrationTest
  test 'deliver newsletter that has already been delivered' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_attributes newsletter: true

    mrossi = Account.find_by! login: 'mrossi'
    mrossi.update_attributes newsletter: true

    newsletter = Email.newsletter
    newsletter.update_attributes(
      _translations: {
        'en': {body: 'Something new!'},
        'de': {body: 'Neuigkeiten!'}
      }
    )

    login_as 'superadmin'
    post "/en/newsletters/#{newsletter.id}/deliver"
    assert_equal 'Newsletter successfully delivered!', flash[:notice]

    post "/en/newsletters/#{newsletter.id}/deliver"
    assert_equal 'Newsletter has already been deliverd', flash[:notice]

    assert_equal 2, ActionMailer::Base.deliveries.count
  end

  test 'everyone can see the archive and show a web preview' do
    email = Email.newsletter
    email.update_attributes(
      _translations: {
        'en': {body: 'A test'},
        'de': {body: 'Ein test'}
      }
    )

    get '/en/newsletters/archive'
    assert_ok

    get "/en/newsletters/#{email.id}/webview"
    assert_access_denied

    email.delivered!
    get "/en/newsletters/#{email.id}/webview"
    assert_ok

    get "/en/newsletters/#{email.id}/edit"
    assert_login_prompt


    login_as 'jdoe'

    get '/en/newsletters/archive'
    assert_ok

    get "/en/newsletters/#{email.id}/webview"
    assert_ok

    get "/en/newsletters/#{email.id}/edit"
    assert_access_denied
  end

  test 'only admins and superadmins can make modifications' do
    email = Email.newsletter
    email.update_attributes(
      _translations: {
        'en': {body: 'A test'},
        'de': {body: 'Ein test'}
      }
    )
    
    login_as 'superadmin'

    get '/en/newsletters'
    assert_ok

    get "/en/newsletters/#{email.id}/webview"
    assert_ok

    email.delivered!
    get "/en/newsletters/#{email.id}/webview"
    assert_ok

    get "/en/newsletters/#{email.id}/edit"
    assert_ok
  end
end
