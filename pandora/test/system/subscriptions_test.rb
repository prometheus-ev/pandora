require "application_system_test_case"

class SubscriptionsTest < ApplicationSystemTestCase

  test 'unsubscribe from newsletter' do
    create_newsletter_user

    visit "/en/unsubscribe"
    assert_text "prometheus newsletter - Unsubscribe!"

    answer_brain_buster

    fill_in 'Your e-mail address', with: 'mmouse@prometheus-bildarchiv.de'
    submit

    assert_text "An e-mail with a link to confirm that you want to unsubscribe from the newsletter has been sent to you."

    unsubscription_email = ActionMailer::Base.deliveries[0]
    link = link_from_email(unsubscription_email)
    visit link

    assert_text "You successfully unsubscribed from our newsletter."
    assert_text "prometheus newsletter - Subscribe!"
  end

  test 'unsubscribe from newsletter for logged in but expired user' do
    mmouse = create_newsletter_user
    mmouse.update(expires_at: 2.weeks.ago)

    visit "/en/unsubscribe"
    assert_text "prometheus newsletter - Unsubscribe!"

    answer_brain_buster

    fill_in 'Your e-mail address', with: 'mmouse@prometheus-bildarchiv.de'
    submit

    assert_text "An e-mail with a link to confirm that you want to unsubscribe from the newsletter has been sent to you."

    unsubscription_email = ActionMailer::Base.deliveries[0]
    link = link_from_email(unsubscription_email)
    visit link

    assert_text "You successfully unsubscribed from our newsletter."
    assert_text "prometheus newsletter - Subscribe!"
  end

  def create_newsletter_user
    Account.create!(
      login: 'mmouse',
      password: 'mmousemmouse',
      password_confirmation: 'mmousemmouse',
      email: 'mmouse@prometheus-bildarchiv.de',
      firstname: 'Mickey',
      lastname: 'Mouse',
      newsletter: true,
      institution: Institution.find_by(name: 'prometheus'),
      status: 'activated',
      accepted_terms_of_use_at: Time.now,
      accepted_terms_of_use_revision: TERMS_OF_USE_REVISION,
      # REWRITE: test the negative case
      email_verified_at: Time.now,
      roles: [Role.find_by(title: 'user')],
      research_interest: 'unsubscribe from newsletter'
    )
  end

end