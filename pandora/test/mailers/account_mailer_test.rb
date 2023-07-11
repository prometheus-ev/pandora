require 'test_helper'

class AccountMailerTest < ActionMailer::TestCase
  test "email confirmation" do
    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.where(login: 'prometheus').first
    token = SecureRandom.hex(10)
    AccountMailer.with(
      user: user,
      timestamp: Time.now,
      token: token
    ).email_confirmation.deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.count
    link = ActionMailer::Base.deliveries.first.body.to_s.scan(/http[^\n ]+/)[0]
    assert_match /^http:\/\/localhost\//, link

    # grab the last 1200 characters from the rails log
    log = File.read("#{Rails.root}/log/test.log")[-1200..-1]
    assert_match /#{ShortUrl.last.token}/, log
  end

  test "activation request" do
    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.where(login: 'jdoe').first
    AccountMailer.with(user: user).activation_request.deliver_now

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
    AccountMailer.with(user: user, address: address).invoice_notice.deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.first
    assert_match /^An invoice has been requested by John Doe/, mail.body.to_s
  end

  test 'password changed' do
    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.find_by!(login: 'jdoe')
    admin = Account.find_by!(login: 'superadmin')
    AccountMailer.with(
      user: user,
      originator: admin
    ).password_changed.deliver_now

    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries.first

    assert_match /^the password for your prometheus account has been changed/, mail.body.to_s
  end

  test 'global redirect' do
    address = 'pandora-devel@prometheus-bildarchiv.de'
    ENV['PM_GLOBAL_MAIL_REDIRECT'] = address

    AccountMailer.default_url_options = {host: 'localhost', locale: 'en'}

    user = Account.where(login: 'jdoe').first
    AccountMailer.with(user: user).activation_request.deliver_now

    mail = ActionMailer::Base.deliveries.first
    assert_equal [address], mail.to
  end
end
