require "application_system_test_case"

class NewslettersTest < ApplicationSystemTestCase
  test 'subscribe to and unsubscribe from newsletter (without an account)' do
    # TODO: is this the way?
    visit '/'
    click_on 'Sitemap'
    click_on 'Newsletters'
    click_on 'Subscribe'
    fill_in 'Your e-mail address', with: 'someone@example.com'
    answer_brain_buster
    submit 'Subscribe'
    assert_text 'An e-mail with a link'
    assert_text 'has been sent to you'

    # should not be subscribed at this point yet
    assert_not Account.last.newsletter

    mails = ActionMailer::Base.deliveries
    assert_equal 1, mails.count
    assert_equal ['someone@example.com'], mails.first.to

    link = link_from_email(mails.first)
    visit link
    assert_text 'successfully subscribed'
    assert_equal 'someone@example.com', Account.last.email
    assert Account.last.newsletter?

    click_on 'Sitemap'
    click_on 'Newsletters'
    click_on 'Unsubscribe'
    fill_in 'Your e-mail address', with: 'wrong@example.com'
    answer_brain_buster
    submit 'Unsubscribe'
    assert_text 'No subscription by that e-mail address found!'
    fill_in 'Your e-mail address', with: 'someone@example.com'
    answer_brain_buster
    submit 'Unsubscribe'
    assert_text 'An e-mail with a link'
    assert_text 'has been sent to you'

    mails = ActionMailer::Base.deliveries
    assert_equal 2, mails.count
    assert_equal ['someone@example.com'], mails.last.to

    link = link_from_email(mails.last)
    visit link
    assert_text 'successfully unsubscribed'
    assert_not Account.exists?(email: 'someone@example.com')
  end

  test 'create, list, web preview and send a newsletter' do
    stats_data

    Account.find_by!(login: 'mrossi').update newsletter: true
    Account.find_by!(login: 'jdupont').update newsletter: true

    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Newsletter' do
      click_on 'Create'
    end
    
    click_on 'Create a new newsletter'
    assert_text "Create newsletter '#{Time.now.year} / 01'"

    fill_in 'email[_translations][en][subject]', with: 'Prometheus news!'
    fill_in 'email[_translations][en][body]', with: 'really interesting'
    fill_in 'email[_translations][en][body_html]', with: '<strong>really</strong> interesting'
    fill_in 'email[_translations][de][subject]', with: 'Neues von Prometheus'
    fill_in 'email[_translations][de][body]', with: 'sehr interessant'
    fill_in 'email[_translations][de][body_html]', with: '<strong>sehr</strong> interessant'
    submit 'Save'
    assert_text 'successfully created'

    # edit it again
    click_on 'Edit'
    fill_in 'email[_translations][en][subject]', with: 'Prometheus news'
    submit 'Save'
    assert_text 'successfully updated'
    assert_equal 'Prometheus news', Email.last.subject
    assert Email.last.newsletter?

    click_submenu 'All'
    assert_text 'Prometheus news'
    click_submenu 'Pending'
    assert_text 'Prometheus news'

    click_submenu 'All'
    click_on "#{Time.now.year} / 01: Prometheus news"

    click_on 'web preview'
    assert_text 'really interesting'
    back

    # verify recipients
    click_on 'see here'
    assert_text "[TO]\nnewsletter"
    back

    accept_confirm do
      click_on 'Send!'
    end
    assert_text 'successfully delivered'

    assert_equal 2, ActionMailer::Base.deliveries.count
    recipients = ActionMailer::Base.deliveries.map{|m| m.to}.flatten
    assert_includes recipients, 'mrossi@prometheus-bildarchiv.de'
    assert_includes recipients, 'jdupont@example.com'

    click_submenu 'Pending'
    assert_no_text 'Prometheus news'
    click_submenu 'All'
    assert_text 'Prometheus news'

    # we edit it again, which should prepare a new newsletter but with the
    # existing newsletter's values
    click_on 'Edit'
    assert_field 'Subject', with: 'Prometheus news'
    back

    accept_confirm do
      click_on 'Delete'
    end
    assert_text 'successfully deleted'
    assert_text 'No newsletters found'
  end

  test 'newsletter facts' do
    stats_data

    login_as 'jnadie'

    click_on 'Administration'
    click_on 'Newsletter facts'
    select '2019', from: 'date_top_terms_year'
    select 'February', from: 'date_top_terms_month'
    submit 'Generate'
    assert_text 'Collections: 4'
    assert_text 'baum: 11'
    assert_text '4c26deb8710753c84e6a48d27129cf47c945c3d5: 1'
    select '2019', from: 'date_top_terms_year'
    select 'February', from: 'date_top_terms_month'
    fill_in 'top_terms_numbers', with: '1'
    submit 'Generate'
    assert_text 'baum: 11'
    assert_no_text '4c26deb8710753c84e6a48d27129cf47c945c3d5: 1'
  end

  test 'unsubscribe without subscription and subscribe to newsletter twice' do
    visit '/'
    click_on 'Sitemap'
    click_on 'Newsletters'
    click_on 'Unsubscribe'
    fill_in 'Your e-mail address', with: 'jdoe@prometheus-bildarchiv.de'
    answer_brain_buster
    submit 'Unsubscribe'
    assert_text 'You are not subscribed to our newsletter'

    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update_column :newsletter, true

    click_on 'Sitemap'
    click_on 'Newsletters'
    click_on 'Subscribe'
    fill_in 'Your e-mail address', with: 'jdoe@prometheus-bildarchiv.de'
    answer_brain_buster
    submit 'Subscribe'
    assert_text 'You are already subscribed to our newsletter'
  end

  test 'auto linking (render an html link if it looks like a link)' do
    # this is happening when there is no html version specified for the
    # newsletter. pandora tries to generate it then from the plain text version
    # added rinku gem to do the job

    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Newsletter' do
      click_on 'Create'
    end
    click_on 'Create a new newsletter'
    assert_text "Create newsletter '#{Time.now.year} / 01'"

    fill_in 'email[_translations][en][subject]', with: 'Prometheus news!'
    fill_in 'email[_translations][en][body]', with: 'really interesting. go to https://wendig.io!'
    fill_in 'email[_translations][de][subject]', with: 'Neues von Prometheus'
    fill_in 'email[_translations][de][body]', with: 'sehr interessant'
    submit 'Save'

    click_on 'web preview'
    assert_text 'really interesting'
    assert_link 'https://wendig.io', href: 'https://wendig.io'
  end

  test 'subscribe to newsletter (with an account)' do
    jdoe = Account.find_by!(login: 'jdoe')

    visit '/subscribe'
    fill_in 'Your e-mail address', with: 'jdoe@prometheus-bildarchiv.de'
    answer_brain_buster
    submit 'Subscribe'

    # should not be subscribed at this point
    assert_not jdoe.reload.newsletter

    mails = ActionMailer::Base.deliveries
    link = link_from_email(mails.first)
    visit link
    assert_text 'successfully subscribed'
    assert jdoe.reload.newsletter
  end

  test 'subscribe with invalid email address' do
    visit '/subscribe'
    fill_in 'Your e-mail address', with: 'Mein Name ist Hase'
    answer_brain_buster
    submit 'Subscribe'
    assert_text 'Email is invalid'
  end

  test 'unsubscribe with invalid email address' do
    visit '/unsubscribe'
    fill_in 'Your e-mail address', with: 'Mein Name ist Hase'
    answer_brain_buster
    submit 'Unsubscribe'
    assert_text 'No subscription by that e-mail address found'
  end

  test 'send email to account (as admin)' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Active'
    end
    click_on 'John Doe'
    click_on 'Send John Doe a message'
    fill_in 'Recipients', with: 'ros'
    within '#to_suggestions' do
      assert_text 'Mario Rossi'
    end
    find('#to_suggestions li').click
    fill_in 'Message', with: 'Ciao Mario!'
    submit

    assert_text 'Your message has been delivered'
    mails = ActionMailer::Base.deliveries
    assert_equal 2, mails.count
    assert_equal ['mrossi@prometheus-bildarchiv.de'], mails.first.to
    assert_match 'Message from user prometheus', mails.first.subject
    assert_equal ['informatik@prometheus-bildarchiv.de'], mails.last.to
    assert_match 'Your message', mails.last.subject
  end

  test 'send email to account (as user)' do
    login_as 'jdoe'

    visit '/en/accounts/mrossi'
    click_on 'Send Mario Rossi a message'
    fill_in 'Message', with: 'Ciao Mario!'
    submit
    assert_text 'Your message has been delivered'

    mails = ActionMailer::Base.deliveries
    assert_equal 2, mails.count
    assert_equal ['mrossi@prometheus-bildarchiv.de'], mails.first.to
    assert_match 'Message from user John Doe', mails.first.subject
    assert_equal ['jdoe@prometheus-bildarchiv.de'], mails.last.to
    assert_match 'Your message', mails.last.subject
  end
end
