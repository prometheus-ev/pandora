require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  test 'create a account and sign in with it' do
    login_as 'superadmin'
    click_on 'Administration'

    section = find('h3', text: 'Account').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'Create'

    fill_in 'User name', with: 'hmustermann'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    select 'user', from: 'Roles'
    select '1 week', from: 'Expiration'
    submit

    assert_text "Email can't be blank"
    fill_in 'E-mail', with: 'hmustermann@example.com'
    select 'Köln, prometheus - Das verteilte ...', from: 'Institution'
    submit

    assert_text 'successfully created'
    click_on 'Active'
    assert_text "Hans Mustermann"

    click_on 'Log out'

    login_as 'hmustermann'

    assert_text "Please verify your e-mail address!"

    hmustermann = Account.find_by!(login: 'hmustermann')
    hmustermann.email_verified_at = Time.now
    hmustermann.save

    login_as 'hmustermann'

    assert_text 'Terms of use'
    submit

    assert_text 'You have to accept our terms of use to be able to use the prometheus image archive'
    check 'I read the terms of use carefully and agree!'
    submit

    assert_text 'Advanced search'

    # user created by admin, so no email verification is needed
  end

  test 'creating a user as institution admin' do
    nowhere = Institution.find_by!(name: 'nowhere')

    login_as 'jdupont'
    click_on 'Administration'
    click_submenu_button 'Create a new account'
    fill_in 'User name', with: 'hmustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    select '2 years', from: 'Expiration'
    select 'Nowhere, Nowhere University', from: 'Institution'
    submit

    hmustermann = Account.find_by!(login: 'hmustermann')
    assert_equal hmustermann.institution, nowhere
    assert_equal(['user'], hmustermann.roles.map{|r| r.title})
    assert hmustermann.expires_at > 23.months.from_now

    login_as 'hmustermann'
    # The email of an account create by an institution admin is not confirmed
    # automatically.
    assert_text "You haven't confirmed your email address yet!"

    hmustermann.email_verified_at = Time.now
    hmustermann.save

    # try login after more than one year, see #1134
    travel_to 360.days.from_now do
      login_as 'hmustermann'
      # the institution's license is expired
      assert_text 'Your account has expired'

      login_as 'superadmin'
      section = find('h3', text: 'Institution').find(:xpath, 'following-sibling::*[1]')
      section.click_on 'List'
      within 'tr', text: /Nowhere/ do
        click_on 'Edit'
      end
      select 'library (250)', from: 'License'
      submit
      assert_text 'successfully updated'

      login_as 'hmustermann'
      assert_no_text 'Your account has expired'
    end
  end

  test 'update a account' do
    login_as 'superadmin'
    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Active'
    end

    click_on 'John Doe'
    click_on 'Edit'

    select 'useradmin', from: 'Roles'
    select 'Nowhere, Nowhere University', from: 'Institution'
    select 'Nowhere, Nowhere University', from: 'Useradmin for'
    submit 'Save'
    assert_text 'successfully updated'
    assert_no_text 'User has role Useradmin, but no institutions to administer.'

    jdoe = Account.find_by!(login: 'jdoe')
    nowhere = Institution.find_by!(name: 'nowhere')
    assert_includes jdoe.admin_institutions, nowhere
    assert_equal nowhere, jdoe.institution

    # change email address to another user's address
    visit "/en/accounts/jdoe/edit"
    fill_in 'E-mail', with: 'mrossi@prometheus-bildarchiv.de'
    submit
    assert_text 'Email has already been taken'
    assert_equal 0, ActionMailer::Base.deliveries.size

    # change the username
    click_on 'Active'
    within '.list_row:first-child' do
      click_on 'Edit'
    end
    fill_in 'User name', with: 'j_doe'
    select 'de', from: 'Language'
    submit
    assert_text "Account 'j_doe' successfully updated!"
    assert_text 'Member since' # so we are on the user's show page
    assert_text 'German'
  end

  test 'update clickandbuy account' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update expires_at: 6.years.ago, mode: 'clickandbuy'

    login_as 'superadmin'
    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Expired'
    end

    click_on 'John Doe'
    click_on 'Edit'

    fill_in 'About you [English]', with: 'I\'ve been paying with clickandbuy in the past, but I haven\'t used the image archive for quiet a while.'
    submit

    assert_text "Account 'jdoe' successfully updated!"
    assert_text 'I\'ve been paying with clickandbuy in the past, but I haven\'t used the image archive for quiet a while.'
  end

  test 'reset a user password (as admin)' do
    assert_equal 0, ActionMailer::Base.deliveries.count
    login_as 'superadmin'
    click_on 'Administration'

    section = find('h3', text: 'Account').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'List'

    # test distance_in_words_ago
    assert_text 'ago'

    within '.accounts-list tr', text: 'John Doe' do
      click_on 'Edit'
    end

    fill_in 'Password', with: 'supersecret'
    fill_in 'Confirm password', with: 'supersecret'
    submit

    assert_text "Account 'jdoe' successfully updated!"
    assert Account.authenticate('jdoe', 'supersecret')

    # update by an admin, so no notification
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  test 'disable account' do
    jdoe = Account.find_by!(login: 'jdoe')
    nowhere = Institution.find_by!(name: 'nowhere')
    jdoe.update institution: nowhere
    assert_nil jdoe.disabled_at

    login_as 'jdupont'
    click_on 'Administration'
    assert_text 'John Doe'
    assert_text 'Jean Dupont'
    assert_no_text 'superadmin'

    within '.list_row', text: /John Doe/ do
      accept_confirm do
        click_on 'Disable'
      end
    end
    assert_text 'successfully disabled'
    assert jdoe.reload.disabled_at > 10.seconds.ago
  end

  test 'useradmin only sees accounts of his institution (account list)' do
    jdoe = Account.find_by!(login: 'jdoe')
    nowhere = Institution.find_by!(name: 'nowhere')
    jdoe.update institution: nowhere

    login_as 'jdupont'
    click_on 'Administration'

    assert_css '.list_row', count: 2
    assert_text 'Nowhere University', count: 2
  end

  test 'useradmin only sees basic profile for accounts outside his/her institution' do
    login_as 'jdupont'
    visit '/en/accounts/mrossi'

    assert_no_text 'Roles'
    assert_no_text 'Newsletter'
    assert_no_text 'Research interest'

    login_as 'superadmin'
    visit '/en/accounts/mrossi'

    assert_text 'Roles'
    assert_text 'Newsletter'
    assert_text 'Research interest'
  end

  test 'deactivate account' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'List'
    end
    click_on 'John Doe'
    click_on 'Edit'
    select 'Deactivate', from: 'Expiration'
    submit
    assert_text 'successfully updated'
    assert_text 'deactivated'
    logout

    login_as 'jdoe'
    assert_text 'Your account has been deactivated'
  end

  test 'show pending accounts' do
    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update_column :status, 'pending'

    login_as 'superadmin'
    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Pending'
    end
    assert_text 'John Doe'
  end

  test 'create association account and test login' do
    # TODO: how does the admin change the mode to association?

    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update mode: 'association'

    login_as 'jdoe'
    assert_text 'Welcome, John Doe'

    within '#statusbar' do
      click_on 'John Doe'
    end
    assert_text "Your account is valid until Saint Glinglin's Day"
  end

  test 'try to create anonymous user' do
    login_as 'superadmin'
    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Create'
    end

    fill_in 'User name', with: 'hmustermann'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    select 'Köln, prometheus - Das verteilte ...', from: 'Institution'
    select 'ipuser', from: 'Roles'
    select '1 week', from: 'Expiration'
    submit

    assert_text "Anonymous users can't be created that way"
  end

  test 'try to create user with role useradmin without admin dbs' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Create'
    end
    fill_in 'User name', with: 'hmustermann'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    select 'Köln, prometheus - Das verteilte ...', from: 'Institution'
    select 'useradmin', from: 'Roles'
    select '1 week', from: 'Expiration'
    submit
    assert_text 'successfully created'
    assert_text 'User has role Useradmin, but no institutions to administer'
  end

  test 'try to create user without role useradmin but with admin db' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Create'
    end
    fill_in 'User name', with: 'hmustermann'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    select 'Köln, prometheus - Das verteilte ...', from: 'Institution'
    select 'user', from: 'Roles'
    select 'Nowhere, Nowhere University', from: 'Useradmin for'
    select '1 week', from: 'Expiration'
    submit
    assert_text 'successfully created'
    assert_text 'User has institutions to administer, but not role Useradmin'
  end

  test 'expiration update prompt (for useradmins)' do
    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update(
      expires_at: 2.days.from_now,
      institution: Institution.find_by!(name: 'nowhere')
    )

    login_as 'jdupont'
    click_on 'Administration'
    click_on 'John Doe'
    click_on 'Edit'
    assert_text "This user is about to expire. Please fill in the field 'Expiration'"
  end

  test 'create user: preselected locale should follow current locale' do
    login_as 'superadmin'

    click_on 'Administration'
    within_admin_section 'Account' do
      click_on 'Create'
    end
    assert_field 'Language', with: 'en'

    click_on 'Deutsch'
    assert_field 'Sprache', with: 'de'
  end

  test 'expiry notification' do
    login_as 'jdoe'

    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update_columns expires_at: 10.days.from_now, mode: 'guest'

    with_env 'PM_SILENT' => 'true' do
      Pandora::UpcomingExpiry.new.run
      assert_nil jdoe.reload.notified_at
      # too early

      travel 14.days do
        Pandora::UpcomingExpiry.new.run
        assert_nil jdoe.reload.notified_at
        # too late
      end

      travel 8.days do
        # first try
        Pandora::UpcomingExpiry.new.run
        assert_not_nil jdoe.reload.notified_at
        text = ActionMailer::Base.deliveries.last.body.to_s
        assert_match /With your guest account you were able to test/, text
        assert_match /http:\/\/localhost:47001\/en\/license/, text
        visit '/en/license'
        assert_text 'You have a guest account'
        assert_text 'Obtain license'

        # reset account and set 'institution' mode, then notify
        jdoe.update_columns notified_at: nil, mode: 'institution'
        Pandora::UpcomingExpiry.new.run
        assert_not_nil jdoe.reload.notified_at
        text = ActionMailer::Base.deliveries.last.body.to_s
        assert_match /your personal prometheus account at your institution/, text
        assert_match /http:\/\/localhost:47001\/en\/license/, text
        visit '/en/license'
        assert_text 'You have a free account from your institution'
        assert_text 'Obtain license / Change institution'

        # reset account and set 'invoice' mode, then notify
        jdoe.update_columns notified_at: nil, mode: 'invoice'
        Pandora::UpcomingExpiry.new.run
        assert_not_nil jdoe.reload.notified_at
        text = ActionMailer::Base.deliveries.last.body.to_s
        assert_match /your personal prometheus account is about to expire/, text
        assert_match /http:\/\/localhost:47001\/en\/license/, text
        visit '/en/license'
        assert_text 'You have a single license via invoice'
        assert_text 'Obtain license'

        # this should not notify again
        assert_no_changes 'ActionMailer::Base.deliveries.count' do
          Pandora::UpcomingExpiry.new.run
        end

        choose 'Invoice'
        fill_in 'Address', with: 'Seestraße 35'
        fill_in 'Postal code', with: '56634'
        fill_in 'City', with: 'Frankfurt am Main'
        check 'I read the terms of use carefully and agree'
        submit
        assert_text 'The prometheus office has been informed'

        # simulate that the account was extended
        jdoe.update expires_at: 1.year.from_now

        # this should still not notify again
        assert_no_changes 'ActionMailer::Base.deliveries.count' do
          Pandora::UpcomingExpiry.new.run
        end
      end

      travel 1.year + 1.week do
        assert_changes 'ActionMailer::Base.deliveries.count' do
          Pandora::UpcomingExpiry.new.run
        end
      end
    end
  end

  test 'account timestamps are updated when associated records are changing' do
    login_as 'superadmin'

    # update the record once to apply "empty" field values from form, otherwise,
    # the record is updated because of (e.g.) `accounts.addressline = ''`
    visit '/en/accounts/jdoe/edit'
    submit

    jdoe = Account.find_by! login: 'jdoe'
    ts = jdoe.updated_at
    visit '/en/accounts/jdoe/edit'
    select 'Halle, University of Halle'
    sleep 1 # because of mysql timestamp precision
    submit
    assert_text 'successfully updated!'
    jdoe.reload
    assert ts < jdoe.updated_at

    ts = jdoe.updated_at
    visit '/en/accounts/jdoe/edit'
    select 'useradmin'
    sleep 1 # because of mysql timestamp precision
    submit
    assert_text 'successfully updated!'
    jdoe.reload
    assert ts < jdoe.reload.updated_at
  end
end
