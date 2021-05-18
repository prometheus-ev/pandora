require 'test_helper'

class AccountMailerTest < ActionMailer::TestCase
  test "email confirmation" do
    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.where(login: 'prometheus').first
    token = SecureRandom.hex(10)
    AccountMailer.email_confirmation(user, Time.now, token).deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.count
    link = ActionMailer::Base.deliveries.first.body.to_s.scan(/http[^\n ]+/)[0]
    assert_match /^http:\/\/localhost\//, link
  end

  test "activation request" do
    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.where(login: 'jdoe').first
    AccountMailer.activation_request(user).deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.first
    assert_match /^The guest user John Doe requests activation/, mail.body.to_s
  end

  test 'invoice notice' do
    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.where(login: 'jdoe').first
    address = OpenStruct.new(
      fullname: 'John Doe',
      addressline: 'Am Stadtplatz 1',
      postalcode: '10001',
      city: 'Berlin',
      country: 'de'
    )
    AccountMailer.invoice_notice(user, address).deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.first
    assert_match /^An invoice has been requested by John Doe/, mail.body.to_s
  end

  test 'password changed' do
    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.find_by!(login: 'jdoe')
    admin = Account.find_by!(login: 'superadmin')
    AccountMailer.password_changed(user, admin).deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.first

    assert_match /^the password for your prometheus account has been changed/, mail.body.to_s
  end

  test 'global redirect' do
    address = 'pandora-devel@prometheus-bildarchiv.de'
    ENV['PM_GLOBAL_MAIL_REDIRECT'] = address

    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.where(login: 'jdoe').first
    AccountMailer.activation_request(user).deliver_now

    mail = ActionMailer::Base.deliveries.first
    assert_equal [address], mail.to
  end
end
