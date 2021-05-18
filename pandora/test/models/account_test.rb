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
  if ENV['PM_BRITTLE']
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
    account.update({email_verified_at: 1.hour.ago}, without_protection: true)

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
end

# Factory(:prometheus) unless Institution[:prometheus]

# describe Account do

#   it { should protect_attributes(:crypted_password, :salt, :created_at, :updated_at,
#                                  :notified_at, :remember_token, :remember_token_expires_at,
#                                  :registered_at, :email_verified_at, :announcement_hide_time,
#                                  :accepted_terms_of_use_revision, :accepted_terms_of_use_at,
#                                  :readable_collections, :readable_collection_ids,
#                                  :writable_collections, :writable_collection_ids) }

#   it "should create a valid IP user for an institution" do
#     institution = Factory.build(:institution)
#     ipuser = nil

#     lambda { ipuser = Account.create_ipuser(institution) }.should change(Account, :count).by(1)

#     ipuser.should be_an_instance_of(Account)
#     ipuser.should be_valid
#     ipuser.login.should == Account::IPUSER_LOGIN
#     ipuser.roles.should == [Role[:ipuser]]
#   end

#   it "should generate a salt" do
#     salt = Account.salt("a_token_string")

#     salt.should be_an_instance_of(String)
#     salt.length.should == 128
#   end

#   it "should generate unique salts" do
#     salts = Array.new(5) { |i| Account.salt("a_token_string_#{i}") }
#     salts.uniq.should == salts
#   end

#   describe "with valid attributes" do

#     before :each do
#       @account = Factory.build(:account)
#     end

#     it "should be valid" do
#       @account.should be_valid
#     end

#     it "should identify itself as being an admin or useradmin if it is one" do
#       @account.roles = [Role[:admin], Role[:useradmin]]

#       @account.should be_admin_or_superadmin
#     end

#     it "should not identify itself as being a useradmin only if it's not" do
#       @account.roles = [Role[:useradmin], Role[:admin]]

#       @account.should_not be_useradmin_only
#     end

#     it "should have power over itself" do
#       @account.should be_allowed(@account)
#     end

#     it "should not have power over an account higher than itself" do
#       other_account = Factory.next(:account)

#       @account.update_attributes(:roles => [Role[:admin]])
#       other_account.update_attributes(:roles => [Role[:superadmin]])

#       @account.should_not be_allowed(other_account)
#     end

#     it "should have power over an account lower than itself if it belongs to the same institution" do
#       other_account = Factory.next(:account)

#       @account.update_attributes(:roles => [Role[:useradmin]])
#       other_account.update_attributes(:roles => [Role[:user]], :institution => @account.institution)

#       @account.should be_allowed(other_account)
#     end

#     it "should not have power over an account lower than itself if it belongs to another institution" do
#       other_account = Factory.next(:account)

#       @account.update_attributes(:roles => [Role[:useradmin]])
#       other_account.update_attributes(:roles => [Role[:user]], :institution => Factory.next(:institution))

#       @account.should_not be_allowed(other_account)
#     end

#     it "should have power over collections and presentations if it owns them" do
#       @account.should be_allowed(Factory.build(:collection, :owner => @account))
#       @account.should be_allowed(Factory.build(:presentation, :owner => @account))
#     end

#     it "should not have power over collections and presentations if it doesn't own them" do
#       @account.should_not be_allowed(Factory.build(:collection))
#       @account.should_not be_allowed(Factory.build(:presentation))
#     end

#     it "should have power over sources if it administrates them" do
#       @account.should be_allowed(Factory.build(:source, :admin => @account))
#     end

#     it "should not have power over sources if it doesn't administrate them" do
#       @account.should_not be_allowed(Factory.build(:source))
#     end

#     it "should not have power over images, rights exploiters, announcements, and e-mails" do
#       [Image, RightsExploiter, Announcement, Email].each { |model|
#         @account.should_not be_allowed(model.new)
#       }
#     end

#     it "should not have power over any unexpected object" do
#       @account.should_not be_allowed('i_am_a_string')
#       @account.should_not be_allowed(123)
#       @account.should_not be_allowed(nil)
#     end

#     it "should know if it is allowed to call a given action" do
#       @account.roles = [Role[:user]]

#       @account.should be_action_allowed('account', 'show')
#       @account.should_not be_action_allowed('account', 'create')
#     end

#     it "should know if it is allowed to access a given controller" do
#       @account.roles = [Role[:user]]

#       @account.should be_controller_allowed('account')
#       @account.should_not be_controller_allowed('stats')
#     end

#     it "should know the actions it is allowed to call" do
#       @account.roles = [Role[:user]]

#       @account.allowed_actions('account', %w[index show create delete]).should == %w[index show]
#     end

#     it "which edits itself should be allowed to edit user enabled fields" do
#       @account.should be_editable_field('firstname')
#     end

#     it "which edits itself should not be allowed to edit not user enabled fields" do
#       @account.should_not be_editable_field('expires_in')
#     end

#     it "should be allowed to edit not just user or useradmin enabled fields if it's not a user or useradmin" do
#       @account.roles = [Factory.build(:role)]

#       @account.should be_editable_field('registered_at', Factory.next(:account))
#     end

#     it "should authenticate using the right password" do
#       password = 'a_password'
#       @account.update_attributes(:password => password, :password_confirmation => password)

#       @account.should be_authenticated(password)
#     end

#     it "should not authenticate using the wrong password" do
#       password = 'a_password'
#       @account.update_attributes(:password => password, :password_confirmation => password)

#       @account.should_not be_authenticated(password.reverse)
#     end

#     it "should not know any special conditions to find users to administrate if it is not a useradmin only" do
#       @account.roles = [Role[:admin]]

#       @account.conditions_for_allowed_accounts.should == {}
#     end

#     it "should know how long it takes until it expires" do
#       @account.expires_at = 1.week.from_now

#       @account.expires_in.should == 1.week
#     end

#     it "should change the moment it expires by getting the amount of time until then" do
#       lambda { @account.expires_in = 2.weeks }.should change(@account, :expires_at)
#       @account.expires_at.should == 2.weeks.to_i.from_now.utc
#     end

#     it "should still be \"mole\" after setting the expiration time" do
#       @account.status = nil

#       lambda { @account.expires_in = 2.weeks }.should_not change(@account, :status?).to(true)
#     end

#     it "should still be pending after setting the expiration time" do
#       @account.status.pending

#       lambda { @account.expires_in = 2.weeks }.should_not change(@account.status, :pending?).to(false)
#     end

#     describe "existing record" do

#       before :each do
#         @account.save
#       end

#       it "should not be \"mole\" after setting the expiration time" do
#         @account.status = nil

#         lambda { @account.expires_in = 2.weeks }.should change(@account, :status?).to(true)
#       end

#       it "should not be pending after setting the expiration time" do
#         @account.status.pending

#         lambda { @account.expires_in = 2.weeks }.should change(@account.status, :pending?).to(false)
#       end

#     end

#     it "should not be already notified of its expiration after setting the expiration time" do
#       @account.notified_at = Time.now

#       lambda { @account.expires_in = 2.weeks }.should change(@account, :notified_at).to(nil)
#     end

#     it "should not set expiration time if no time is given" do
#       lambda { @account.expires_in = nil }.should_not change(@account, :expires_at)
#     end

#     it "which is a DB user should not be expired" do
#       @account.attributes = { :roles => [Role[:dbadmin]], :expires_at => nil }

#       @account.should_not be_expired
#     end

#     it "which doesn't belong to an institution should not be expired" do
#       @account.attributes = { :institution => nil, :expires_at => nil }

#       @account.should_not be_expired
#     end

#     it "which belongs to an institution with a license should not be expired" do
#       @account.expires_at = nil
#       @account.institution.license = Factory.build(:license)

#       @account.should_not be_expired
#     end

#     it "which is a guest should be expiring if expiration is less than 3 days in the future" do
#       @account.mode.guest
#       @account.expires_at = 2.days.from_now

#       @account.mode.should be_guest
#       @account.should be_expires
#     end

#     it "which is not a guest should be expiring if expiration is less than a month in the future" do
#       @account.created_at = 20.days.ago
#       @account.expires_at = 20.days.from_now

#       @account.mode.should_not be_guest
#       @account.should be_expires
#     end

#     it "which is a guest should not be expiring if expiration is more than 3 days in the future" do
#       @account.mode.guest
#       @account.expires_at = 20.days.from_now

#       @account.mode.should be_guest
#       @account.should_not be_expires
#     end

#     it "should not be expiring if expiration is more than a month in the future" do
#       @account.created_at = 5.days.ago
#       @account.expires_at = 2.months.from_now

#       @account.should_not be_expires
#     end

#     it "should not be expiring if expiration is in the past" do
#       @account.created_at = 5.days.ago
#       @account.expires_at = 1.day.ago

#       @account.should_not be_expires
#     end

#     it "should set \"mole\" to false when paid" do
#       @account.status = nil

#       lambda { @account.paid! }.should change(@account, :status?).to(true)
#     end

#     it "should set pending to false when paid" do
#       @account.status.pending

#       lambda { @account.paid! }.should change(@account.status, :pending?).to(false)
#     end

#     it "should get one year until expiration when paid" do
#       lambda { @account.paid! }.should change(@account, :expires_at)
#       @account.expires_at.should == 1.year.from_now
#     end

#     it "should get one more year until expiration when paid" do
#       @account.expires_at = 1.month.from_now

#       lambda { @account.paid! }.should change(@account, :expires_at)
#       @account.expires_at.should == 1.month.from_now + 1.year
#     end

#     it "which verified its e-mail should be e-mail verified" do
#       @account.email_verified_at = Time.now

#       @account.should be_email_verified
#     end

#     it "which never verified its e-mail should not be e-mail verified" do
#       @account.email_verified_at = nil

#       @account.should_not be_email_verified
#     end

#     it "should not be e-mail verified when e-mail just changed" do
#       @account.email_verified_at = Time.now

#       lambda { @account.email_changed! }.should change(@account, :email_verified_at).to(nil)
#     end

#     it "which accepted the terms of use should be accepted terms of use" do
#       @account.accepted_terms_of_use

#       @account.should be_accepted_terms_of_use
#     end

#     it "which did not accept the terms of use should not be accepted terms of use" do
#       @account.accepted_terms_of_use_revision = nil

#       @account.should_not be_accepted_terms_of_use
#     end

#     it "should remember the acceptance of the terms of use" do
#       @account.accepted_terms_of_use_revision = nil

#       lambda { @account.accepted_terms_of_use! }.should change {
#         [@account.accepted_terms_of_use_revision, @account.accepted_terms_of_use_at]
#       }

#       @account.accepted_terms_of_use_revision.should == TERMS_OF_USE_REVISION
#       @account.accepted_terms_of_use_at.should be_an_instance_of(Time)
#     end

#     it "should become notified after notification" do
#       @account.notified_at = nil

#       lambda { @account.notified! }.should change(@account, :notified_at)
#       @account.notified_at.should be_an_instance_of(Time)
#     end

#     it "should be notified after notification" do
#       @account.notified!

#       @account.should be_notified
#     end

#     it "should not be notified before notification" do
#       @account.should_not be_notified
#     end

#     it "should have a valid remember token if it has a remember token that doesn't have expired" do
#       @account.remember_token_expires_at = 2.days.from_now

#       @account.should be_remember_token
#     end

#     it "should not have a valid remember token if it has a remember token that has expired" do
#       @account.remember_token_expires_at = 2.days.ago

#       @account.should_not be_remember_token
#     end

#     it "should not have a valid remember token if it has no remember token expiration time at all" do
#       @account.remember_token_expires_at = nil

#       @account.should_not be_remember_token
#     end

#     it "should get a remember token by remembering a session" do
#       @account.remember_token_expires_at = nil
#       @account.remember_token = nil

#       lambda { @account.remember_me }.should change(@account, :remember_token)
#       @account.remember_token.should be_an_instance_of(String)
#     end

#     it "should get a remember token expiration time by remembering a session" do
#       @account.remember_token_expires_at = nil
#       @account.remember_token = nil

#       lambda { @account.remember_me }.should change(@account, :remember_token_expires_at)
#       @account.remember_token_expires_at.should be_an_instance_of(Time)
#       @account.remember_token_expires_at.should > Time.now
#     end

#     it "should forget its remember token by forgetting a session" do
#       @account.remember_me

#       lambda { @account.forget_me }.should change(@account, :remember_token).to(nil)
#     end

#     it "should forget its remember token expiration time by forgetting a session" do
#       @account.remember_me

#       lambda { @account.forget_me }.should change(@account, :remember_token_expires_at).to(nil)
#     end

#     it "should provide a full name" do
#       @account.fullname.should == "#{@account.firstname} #{@account.lastname}".strip
#     end

#     it "should provide a string representation equal to its full name" do
#       @account.to_s.should == @account.fullname
#     end

#     it "should provide a full name with e-mail" do
#       @account.fullname_with_email.should == %Q{"#{@account.fullname}" <#{@account.email}>}
#     end

#     it "should confirm e-mail" do
#       timestamp, token = @account.token_auth

#       timestamp.should be_an_integer
#       token.should be_an_instance_of(String)
#     end

#     it "should be via issuer if it belongs to a corresponding institution" do
#       @account.institution = Institution[:prometheus]

#       @account.should be_via_issuer
#     end

#     it "should not be via issuer if it does not belong to a corresponding institution" do
#       @account.institution = Factory.next(:institution)

#       @account.should_not be_via_issuer
#     end

#     describe "for an active user" do

#       before :each do
#         @account.attributes = attributes_for_active_user
#       end

#       it "should be active" do
#         @account.should be_active
#       end

#       it "should be expired if its expiration was in the past" do
#         @account.expires_at = 1.week.ago

#         @account.should be_expired
#       end

#       it "should not be expired if its expiration is in the future" do
#         @account.expires_at = 1.week.from_now

#         @account.should_not be_expired
#       end

#       it "should be expired if it's not a DB user and has an unlicensed institution" do
#         @account.attributes = { :roles => [Role[:user]], :mode => Account::ModeEnum::INSTITUTION, :institution => Factory.build(:institution, :licenses => []) }

#         @account.should be_expired
#       end

#       it "which is \"mole\" should not be active" do
#         @account.status = nil

#         @account.should_not be_active
#       end

#       it "which is pending should not be active" do
#         @account.status.pending

#         @account.should_not be_active
#       end

#       it "which is expired should not be active" do
#         @account.expires_at = 1.day.ago

#         @account.should_not be_active
#       end

#     end

#     describe "which is a user" do

#       before :each do
#         @account.roles = [Role[:user]]
#       end

#       it "should not identify itself as being an admin or useradmin" do
#         @account.should_not be_admin_or_superadmin
#       end

#       it "should be allowed to edit user enabled fields" do
#         @account.should be_editable_field('firstname')
#       end

#       it "should not be allowed to edit not user enabled fields" do
#         @account.should_not be_editable_field('expires_in')
#       end

#     end

#     describe "which is a superadmin" do

#       before :each do
#         @account.roles = [Role[:superadmin]]
#       end

#       it "should have power over all target accounts at its own institution" do
#         accounts = Role.find(:all).map { |r|
#           a = Factory.next(:account)
#           a.attributes = { :roles => [r], :institution => @account.institution }
#           a
#         }

#         accounts.each { |a| @account.should be_allowed(a) }
#       end

#       it "should have power over all target accounts at another institution" do
#         accounts = Role.find(:all).map { |r|
#           a = Factory.next(:account)
#           a.roles = [r]
#           a
#         }

#         accounts.each { |a| @account.should be_allowed(a) }
#       end

#       it "should have power over target institutions" do
#         @account.should be_allowed(@account.institution)
#         @account.should be_allowed(Factory.next(:institution))
#       end

#       it "should have power over collections and presentations" do
#         @account.should be_allowed(Factory.build(:collection))
#         @account.should be_allowed(Factory.build(:presentation))
#       end

#     end

#     describe "which is an admin" do

#       before :each do
#         @account.roles = [Role[:admin]]
#       end

#       it "should know which roles it has power over" do
#         @account.allowed_roles.map(&:title).sort.should == %w[dbadmin subscriber user useradmin visitor webadmin]
#       end

#       it "should know if it has power over given roles" do
#         @account.should be_roles_allowed([Role[:user]])
#         @account.should be_roles_allowed([Role[:useradmin], Role[:user]])
#         @account.should_not be_roles_allowed([Role[:superadmin]])
#         @account.should_not be_roles_allowed([Role[:superadmin], Role[:user]])
#       end

#       it "should have power over an institution if it belongs to it" do
#         @account.should be_allowed(@account.institution)
#       end

#       it "should have power over target institutions" do
#         @account.should be_allowed(@account.institution)
#         @account.should be_allowed(Factory.next(:institution))
#       end

#     end

#     describe "which is only a useradmin" do

#       before :each do
#         @account.roles = [Role[:useradmin]]
#       end

#       it "should identify itself as being a useradmin only if it is one" do
#         @account.should be_useradmin_only
#       end

#       it "should be allowed to edit useradmin enabled fields" do
#         @account.should be_editable_field('expires_in', Factory.next(:account))
#       end

#       it "should not be allowed to edit not useradmin enabled fields" do
#         @account.should_not be_editable_field('registered_at')
#       end

#       it "should be allowed to edit user enabled fields if it is editing itself" do
#         @account.should_not be_editable_field('expires_in')
#         @account.should be_editable_field('firstname')
#       end

#     end

#     describe "which is a dbadmin" do

#       before :each do
#         @account.roles = [Role[:dbadmin]]
#         @source = Factory.next(:source)
#         @source.admin = @account
#       end

#       it "should be allowed to edit dbadmin enabled fields on sources he administrates" do
#         @account.should be_editable_field('description', @source)
#       end

#       it "should not be allowed to edit not dbadmin enabled fields on sources he administrates" do
#         @account.should_not be_editable_field('title', @source)
#       end

#       it "should never expire" do
#         @account.should be_exempt_from_expiration
#       end

#     end

#     describe "which is not an IP user" do

#       before :each do
#         @account.attributes = { :login => 'not_ipuser', :roles => [Role[:user]] }
#       end

#       it "should have a string representation equal to its full name" do
#         @account.to_s.should == @account.fullname
#       end

#       it "should have a parameter representation equal to its login" do
#         @account.to_param.should == @account.login
#       end

#       describe "when saved" do

#         before :each do
#           @account.save
#         end

#         it "should not be a new record" do
#           @account.should_not be_new_record
#         end

#         it "should be findable by its parameter representation" do
#           Account[@account.to_param].should be_eql(@account)
#         end

#       end

#       it "should encrypt password with the user salt" do
#         @account.salt = 'a_salt'
#         @account.digest('password_string').should == Account.digest('password_string', @account.salt)
#       end

#     end

#     describe "which is an IP user" do

#       before :each do
#         @account.attributes = { :login => Account::IPUSER_LOGIN, :roles => [Role[:ipuser]] }
#       end

#       it "should not require e-mail" do
#         @account.email = ''
#         @account.should have(0).errors_on(:email)
#       end

#       it "should not require firstname" do
#         @account.firstname = ''
#         @account.should have(0).errors_on(:firstname)
#       end

#       it "should not require lastname" do
#         @account.lastname = ''
#         @account.should have(0).errors_on(:lastname)
#       end

#       it "should have a parameter representation consisting of the IP user login and its institution's parameter representation" do
#         @account.to_param.should == "#{Account::IPUSER_LOGIN}-#{@account.institution.to_param}"
#       end

#     end

#     describe "which requires a password" do

#       before :each do
#         @account.login = 'not_ipuser'
#       end

#       it "should require a password" do
#         @account.password = ''
#         @account.errors_on(:password).should include("can't be blank")
#       end

#       it "should require a password confirmation" do
#         @account.password_confirmation = ''
#         @account.errors_on(:password_confirmation).should include("can't be blank")
#       end

#       it "should require a password with a minimum length of 8 characters" do
#         @account.password = 'abc'
#         @account.errors_on(:password).should include("is too short (minimum is 8 characters)")
#       end

#       it "should require a password with a maximum length of 99 characters" do
#         @account.password = 'A' * 100
#         @account.errors_on(:password).should include("is too long (maximum is 99 characters)")
#       end

#       it "should validate password confirmation" do
#         password = 'a_password'
#         @account.attributes = { :password => password, :password_confirmation => password.reverse }
#         @account.errors_on(:password).should include("doesn't match confirmation")
#       end

#       it "should encrypt the password before saving" do
#         password = 'a_password'
#         @account.attributes = { :password => password, :password_confirmation => password }

#         lambda { @account.save }.should change(@account, :crypted_password)
#         @account.crypted_password.should_not == password
#       end

#     end

#   end

#   describe "with several instances" do

#     before :each do
#       institution = Factory(:institution)

#       @accounts = Array.new(5) { |i|
#         Factory(:account,
#           :login       => "login#{i}",
#           :email       => "name#{i}@example.com",
#           :roles       => [Factory.next(:role)],
#           :institution => institution
#         )
#       }
#     end

#     it { should require_unique_attributes(:login, :email) }

#     it "should find accounts conveniently by their login" do
#       Account['login0', 'login2'].should == @accounts.values_at(0, 2)
#     end

#     it "should find an IP user by its parameter representation" do
#       @accounts[1].update_attributes(:login => Account::IPUSER_LOGIN, :roles => [Role[:ipuser]])
#       @accounts[1].institution.update_attribute(:ipuser, @accounts[1])

#       Account[@accounts[1].to_param].should == @accounts[1]
#     end

#     it "should find accounts by their login or e-mail" do
#       Account.find_by_login_or_email('login1').should == @accounts[1]
#       Account.find_by_login_or_email('name4@example.com').should == @accounts[4]
#     end

#     it "should authenticate a user by his login and unencrypted password" do
#       password = 'a_password'
#       @accounts[0].update_attributes(:login => 'john', :password => password, :password_confirmation => password)

#       Account.authenticate('john', password).should == @accounts[0]
#     end

#     it "should authenticate a user by his e-mail and unencrypted password" do
#       password = 'a_password'
#       @accounts[1].update_attributes(:login => 'john@example.com', :password => password, :password_confirmation => password)

#       Account.authenticate('john@example.com', password).should == @accounts[1]
#     end

#     it "should provide the conditions to find not IP users" do
#       ipuser_attributes = { :login => Account::IPUSER_LOGIN, :roles => [Role[:ipuser]] }
#       update_attributes_of_each_object(@accounts, ipuser_attributes, 0..2)

#       accounts = @accounts[3..-1]

#       Account.find(:all, Account.conditions_for_not_anonymous).should == accounts
#       accounts.each { |account| account.should be_not_anonymous }
#     end

#     it "should provide the conditions to find not \"mole\" users" do
#       update_attributes_of_each_object(@accounts, { :status => Account::StatusEnum::ACTIVATED }, 0..2, { :status => nil })

#       accounts = @accounts[0..2]

#       Account.find(:all, Account.conditions_for_status).should == accounts
#       accounts.each { |account| account.should be_status }
#     end

#     it "should provide the conditions to find pending users" do
#       update_attributes_of_each_object(@accounts, { :status => Account::StatusEnum::PENDING }, 1..3, { :status => Account::StatusEnum::ACTIVATED })

#       accounts = @accounts[1..3]

#       Account.find(:all, Account.conditions_for_pending).should == accounts
#       accounts.each { |account| account.status.should be_pending }
#     end

#     it "should provide the conditions to find expired users" do
#       update_attributes_of_each_object(@accounts, { :expires_at => 5.days.ago }, 1..3, { :expires_at => 5.days.from_now })

#       # dbadmin should not expire
#       @accounts[1].roles << Role[:dbadmin]
#       @accounts[1].save

#       accounts = @accounts[2..3]

#       Account.find(:all, Account.conditions_for_expired).should == accounts
#       accounts.each { |account| account.should be__expired }
#     end

#     it "should provide the conditions to find not expired users" do
#       update_attributes_of_each_object(@accounts, { :expires_at => 5.days.from_now }, 2..3, { :expires_at => 5.days.ago })

#       # dbadmin should not expire
#       @accounts[1].roles << Role[:dbadmin]
#       @accounts[1].save

#       accounts = @accounts[1..3]

#       Account.find(:all, Account.conditions_for_not_expired).should == accounts
#       accounts.each { |account| account.should be_not_expired }
#     end

#     it "should provide the conditions to find licensed users" do
#       update_attributes_of_each_object(@accounts, { :institution => Institution[:prometheus] }, 2..3, { :institution => Factory.next(:institution) })

#       accounts = @accounts[2..3]

#       Account.find(:all, Account.conditions_for_licensed).should == accounts
#       accounts.each { |account| account.should be_licensed }
#     end

#     it "should provide the conditions to find guest users" do
#       update_attributes_of_each_object(@accounts, { :mode => Account::ModeEnum::GUEST }, 2..3, { :mode => Account::ModeEnum::INSTITUTION })

#       accounts = @accounts[2..3]

#       Account.find(:all, Account.conditions_for_guest).should == accounts
#       accounts.each { |account| account.mode.should be_guest }
#     end

#     it "should provide the conditions to find expiring users" do
#       update_attributes_of_each_object(@accounts, { :expires_at => 5.days.from_now }, 1..3, { :expires_at => 2.months.from_now })

#       # dbadmin should not expire
#       @accounts[1].roles << Role[:dbadmin]
#       @accounts[1].save

#       accounts = @accounts[2..3]

#       Account.find(:all, Account.conditions_for_expires).should == accounts
#       accounts.each { |account| account.should be_expires }
#     end

#     it "should provide the conditions to find users" do
#       update_attributes_of_each_object(@accounts, { :roles => [Role[:user]] }, 1..3, { :roles => [Role[:admin]] })

#       accounts = @accounts[1..3]

#       Account.find(:all, Account.conditions_for_user).should == accounts
#       accounts.each { |account| account.should be_user }
#     end

#     it "should provide the conditions to find active users" do
#       update_attributes_of_each_object(@accounts, attributes_for_active_user, 0..3, { :status => Account::StatusEnum::PENDING })

#       accounts = @accounts[0..3]

#       Account.find(:all, Account.conditions_for_active_user).should == accounts
#       accounts.each { |account| account.should be_active_user }
#     end

#     it "should count active users" do
#       update_attributes_of_each_object(@accounts, attributes_for_active_user, 0..3, { :status => Account::StatusEnum::PENDING })

#       Account.count_active_users.should == 4
#     end

#     it "should find a user by its login or e-mail" do
#       Account.find_by_login_or_email('name2@example.com').should == @accounts[2]
#       Account.find_by_login_or_email('login3').should == @accounts[3]
#     end

#     it "which is a useradmin should know the conditions to find accounts it is admin for if it doesn't have any admin institutions" do
#       @accounts[0].attributes = { :roles => [Role[:useradmin]], :admin_institutions => [] }
#       @accounts[4].update_attributes(:institution => Factory.next(:institution))

#       Account.find(:all, @accounts[0].conditions_for_allowed_accounts).should == @accounts[0..3]
#     end

#     it "which is a useradmin should know the conditions to find accounts it is admin for at its admin institutions" do
#       first_institution  = Factory.next(:institution)
#       second_institution = Factory.next(:institution)

#       @accounts[0].attributes = { :roles => [Role[:useradmin]], :admin_institutions => [first_institution] }
#       update_attributes_of_each_object(@accounts, { :institution => first_institution }, 1..3, { :institution => second_institution })

#       Account.find(:all, @accounts[0].conditions_for_allowed_accounts).should == @accounts[1..3]
#     end

#     it "should know its admins" do
#       institution = @accounts[0].institution

#       update_attributes_of_each_object(@accounts,       :institution        => institution)
#       update_attributes_of_each_object(@accounts[1..3], :admin_institutions => [institution])
#       update_attributes_of_each_object(@accounts[1..2], :roles              => [Role[:useradmin]])

#       @accounts[0].admins.should == @accounts[1..2]
#     end

#   end

# end

# def attributes_for_active_user
#   institution_with_license = Factory.next(:institution)
#   institution_with_license.license = Factory.next(:license)

#   {
#     :roles       => [Role[:user]],
#     :status      => Account::StatusEnum::ACTIVATED,
#     :expires_at  => 5.days.from_now,
#     :institution => institution_with_license
#   }
# end
