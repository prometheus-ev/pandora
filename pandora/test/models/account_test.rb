require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test 'is serializable with json' do
    assert_nothing_raised do
      Account.new.to_json
    end
  end

  test 'required attributes' do
    account = Account.new
    account.valid?

    attrs = :email, :firstname, :lastname, :login
    attrs.each do |a|
      assert account.errors[a].include?("can't be blank")
    end
  end

  test "should require roles" do
    account = Account.new
    account.valid?

    assert account.errors[:roles].include?("can't be blank")
  end

  test "should require a login with a minimum length of 3 characters" do
    account = Account.new login: 'xy'
    account.valid?

    assert account.errors[:login].include?('is too short (minimum is 3 characters)')
  end

  test "should require a login with a maximum length of 40 characters" do
    account = Account.new login: "#{'A' * 100}"
    account.valid?

    assert account.errors[:login].include?('is too long (maximum is 99 characters)')
  end

  test "should also validate maximum login length if e-mail is blank" do
    account = Account.new login: "#{'A' * 100}", email: ''
    account.valid?

    assert account.errors[:login].include?('is too long (maximum is 99 characters)')
  end

  test "should require well-formed e-mail" do
    account = Account.new email: 'foo@bar@example.com'
    account.valid?

    assert account.errors[:email].include?('is invalid')
  end

  test "should require e-mail with valid domain name" do
    skip 'the domain check depends on a live dns request which is unreliable during testing'

    account = Account.new email: 'foo@noexist.wendig.io'
    account.valid?

    assert account.errors[:email].include?('has an invalid domain name')
  end

  test "email domain names with special characters don't break things" do
    with_env 'PM_SKIP_EMAIL_DOMAIN_CHECK' => 'false' do
      account = Account.new email: 'foo@noäxist.wendig.io'
      account.valid?

      assert_includes account.errors[:email], 'should not contain special characters'
    end
  end

  test "should perform magic login" do
    account = Account.find_by! login: 'jdoe'
    timestamp, token = account.token_auth(true)

    assert_equal account, Account.authenticate_from_token(account.login, timestamp, token)
  end

  test "should perform magic login even if the parameters have trailing closing angle brackets" do
    account = Account.find_by! login: 'jdoe'
    timestamp, token = account.token_auth(true)

    login = account.login + '>'
    ts = timestamp.to_s + '>'
    token += '>'
    assert_equal account, Account.authenticate_from_token(login, ts, token)
  end

  test "should not perform magic login when timestamp is expired" do
    account = Account.find_by! login: 'jdoe'
    account.send(:reset_password!)

    timestamp = 1.week.ago.to_i
    token     = account.magic_encrypt(timestamp)

    yielded = false
    assert_nil Account.authenticate_from_token(account.login, timestamp, token) { yielded = true }
    assert yielded
  end

  # brittle because the address verification uses a dns lookup which is not
  # reliable (e.g. doesn't work from everywhere)
  if ENV['PM_BRITTLE'] == 'true'
    test "should verify e-mail on magic login" do
      account = Account.find_by! login: 'jdoe'
      timestamp, token = account.token_auth(true)

      assert_changes 'account.email_verified_at' do
        account = Account.authenticate_from_token(account.login, timestamp, token)
      end
      assert_kind_of Time, account.email_verified_at
    end
  end

  test "should perform magic confirmation" do
    account = Account.find_by! login: 'jdoe'

    timestamp = 1.day.from_now.to_i
    token     = account.magic_encrypt(timestamp)

    assert_equal account, Account.authenticate_from_token(account.login, timestamp, token)
  end

  # test "should perform magic confirmation even if the parameters have trailing closing angle brackets"
  # test "should not perform magic confirmation when timestamp is expired"

  test "should not verify e-mail on magic confirmation" do
    account = Account.find_by! login: 'jdoe'
    account.update(email_verified_at: 1.hour.ago)

    timestamp = 1.week.from_now.to_i
    token     = account.magic_encrypt(timestamp)

    assert_no_changes 'account.email_verified_at' do
      account = Account.authenticate_from_token(account.login, timestamp, token)
    end
    assert_kind_of Time, account.email_verified_at
  end

  test 'should allow superadmins to write others' do
    account = Account.find_by! login: 'superadmin'
    other = Account.find_by! login: 'jdoe'

    assert account.allowed?(other)
  end

  test 'find by institution' do
    prometheus = Institution.find_by!(name: 'prometheus')
    nowhere = Institution.find_by(name: 'nowhere')
    prometheus.update name: 'koeln_prometheus'
    nowhere.update name: 'koeln'

    assert_equal 0, Account.search('institution', 'noexist').count

    # superadmin, prometheus, jdoe, jexpired, mrossi, jnadie
    assert_equal 6, Account.search('institution', 'koeln_prometheus').count

    # campus, jdupont
    assert_equal 2, Account.search('institution', 'koeln').count
  end

  test 'find by non roles' do
    accounts = Account.without_roles('user')
    assert_same_elements ['campus', 'jnadie'], accounts.pluck(:login)

    accounts = Account.without_roles('superadmin')
    assert_same_elements ['campus', 'jdoe', 'jdupont', 'jexpired', 'jnadie', 'mrossi', 'prometheus'], accounts.pluck(:login)

    accounts = Account.without_roles(['user', 'superadmin'])
    assert_same_elements ['campus', 'jnadie'], accounts.pluck(:login)
  end

  test 'validate login on create' do
    account = Account.new(login: 'john doe')
    account.valid?
    msg = 'has to start with a Latin letter and can only contain Latin letters, digits, underscores and full stops and cannot end with a full stop'
    assert_equal [msg], account.errors[:login]
  end

  test 'validate login on update when changed' do
    account = Account.find_by!(login: 'jdoe')
    account.login = 'john_doe.'
    account.valid?
    msg = 'has to start with a Latin letter and can only contain Latin letters, digits, underscores and full stops and cannot end with a full stop'
    assert_equal [msg], account.errors[:login]
  end

  test "don't validate login on update when not changed (backwards compat)" do
    account = Account.find_by!(login: 'jdoe')
    account.email = 'another@example.com'
    account.valid?
    assert_equal [], account.errors[:login]
  end

  test "login format and length" do
    Account.find_by!(login: 'jdoe').destroy

    good = ['john_doe', 'jdoe', 'JohnDoe', 'johnDoe', 'JoHnDoE', 'john.doe']
    good.each do |login|
      account = Account.new login: login
      account.valid?
      assert_empty account.errors[:login], "#{login} should validate fine, but didn't"
    end

    bad = [
      '.john.doe', 'john doe', 'John Doe', ' jdoe', 'jdoe ', 'John.',
      'jd', 'j' * 40 + 'doe', '_john'
    ]
    bad.each do |login|
      account = Account.new login: login
      account.valid?
      assert_not_empty account.errors[:login], "#{login} shouldn't pass validation, but did"
    end
  end

  test 'expiry and scopes' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_columns expires_at: 10.days.from_now

    assert_not jdoe.expired?
    assert_equal 0, Account.upcoming_expiry(1.week).count
    assert_equal 1, Account.upcoming_expiry(2.week).count

    travel 1.week do
      assert_not jdoe.expired?
      assert_equal 1, Account.upcoming_expiry(4.days).count
      assert_equal 1, Account.upcoming_expiry(1.week).count
      assert_equal 1, Account.upcoming_expiry(2.week).count
    end

    travel 2.week do
      assert jdoe.expired?
      assert_equal 0, Account.upcoming_expiry(4.days).count
      assert_equal 0, Account.upcoming_expiry(1.week).count
      assert_equal 0, Account.upcoming_expiry(2.week).count
    end
  end
end
