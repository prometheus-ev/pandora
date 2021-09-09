require "application_system_test_case"

class SignupsTest < ApplicationSystemTestCase
  test 'signup with a test account and login' do
    visit '/'

    click_on 'Sign up'

    choose 'One week free trial'
    fill_in 'User name', with: 'hmustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    check 'Subscribe to our newsletter?'

    submit # try without terms and brain buster
    assert_text 'Your captcha answer failed'
    answer_brain_buster
    submit
    assert_text 'You have to accept our terms'
    check 'I read the terms of use carefully and agree'

    submit
    assert_text "Research interest can't be blank"

    fill_in 'Research/education interest and context', with: 'employed at DFK Paris'
    submit
    assert_text 'Thank you for your registration'

    assert Account.find_by(login: "hmustermann").status.nil?

    # confirm the email address as the new user
    email_confirmation_request = ActionMailer::Base.deliveries[0]
    link = link_from_email(email_confirmation_request)

    visit link
    assert_text 'Your e-mail address has been confirmed'

    assert Account.find_by(login: "hmustermann").status == 'pending'

    # try login (should succeed, but should be redirected to research interest
    # confirmation page)
    login_as 'hmustermann'
    assert_text 'Your research interest has to be approved'
    click_on 'My Uploads'
    assert_text 'Your research interest has to be approved'

    # as superadmin: confirm the research interest
    login_as 'superadmin'
    activation_request = ActionMailer::Base.deliveries[1]
    link = link_from_email(activation_request)
    visit link

    click_on 'Edit'
    select 'Activate', from: 'Expiration'
    submit
    assert_text "Account 'hmustermann' successfully updated"

    # there should be a notification about the activation for the user
    activation_notice = ActionMailer::Base.deliveries[2]
    assert_match /Your account has been activated/, activation_notice.subject

    # The following message is shown 3 days before actual expiry for guests,
    # so we do a time jump of 5 days
    travel_to 5.days.from_now do
      login_as 'hmustermann'
      assert_text 'Your guest account is about to expire'
      click_on 'My Uploads'
      assert_text /Using 0 Bytes of 1000 MB/

      # we like it, so let's do paypal and extend the license
      click_on 'Hans Mustermann'
      click_on 'Obtain a new license or change your institution...'
      assert_text 'You have a guest account'
      choose 'user_mode_paypal'
      submit

      # we just assert the redirect, the actual paypal process is dealt with in
      # another test
      assert_match /sandbox.paypal.com/, current_url
    end
  end

  test 'signup with already existing account' do
    visit '/'

    click_on 'Sign up'

    choose 'One week free trial'
    fill_in 'User name', with: 'jdoe'
    fill_in 'E-mail', with: 'jdoe@prometheus-bildarchiv.de'
    fill_in 'Password', with: 'jdoe1234'
    fill_in 'Confirm password', with: 'jdoe1234'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'

    answer_brain_buster
    check 'I read the terms of use carefully and agree'
    fill_in 'Research/education interest and context', with: 'art'
    submit

    assert_text 'An account with this email address already exists.'
    fill_in 'E-mail', with: 'j_doe@prometheus-bildarchiv.de'
    submit

    assert_text 'An account with this login already exists.'
    fill_in 'User name', with: 'j_doe'
    submit

    assert_text 'Thank you for your registration'
  end

  test 'signup via invoice payment and login' do
    visit '/'

    click_on 'Sign up'

    choose 'Single license for 30 EUR per year'
    fill_in 'User name', with: 'hmustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    check 'I read the terms of use carefully and agree'
    answer_brain_buster
    submit

    assert_text "Research interest can't be blank"
    fill_in 'Research/education interest and context', with: 'employed at DFK Paris'
    check 'Subscribe to our newsletter?'
    submit

    assert_text 'Thank you for your registration'
    assert_text 'An e-mail with a link to confirm that your e-mail address belongs to your person has been sent to you.'

    # confirm the email address as the new user
    email_confirmation_request = ActionMailer::Base.deliveries[0]
    link = link_from_email(email_confirmation_request)
    visit link

    assert_equal("Single license", find('h1.page_title').text)
    submit

    assert_text "Please select a means by which to gain access to the image archive."
    # choose payment option
    choose 'Invoice'
    fill_in 'Address', with: 'Am Stadpfad 1'
    fill_in 'Postal code', with: '10001'
    fill_in 'City', with: ''
    submit

    assert_text 'We need your full address to create a valid invoice for you.'
    choose 'Invoice'
    fill_in 'City', with: 'Berlin'
    submit

    assert_text 'The prometheus office has been informed about your registration.'

    invoice_notification = ActionMailer::Base.deliveries[1]
    assert_match /Amount: 45 EUR/, invoice_notification.body.to_s

    # as superadmin: assume the received payment, so activate the new account
    login_as 'superadmin'

    within 'form.search_form[action="/en/accounts"]' do
      find('select[name="field"]').select "Login"
      find('input[type="text"]').fill_in with: "hmusterman"
      submit
    end

    click_on 'Hans Musterman'

    click_on 'Edit'
    select '1 year', from: 'Expiration'
    select 'user', from: 'Roles'
    submit
    assert_text "Account 'hmustermann' successfully updated"

    # login as the new user
    login_as 'hmustermann'
    assert_text 'Welcome, Hans Mustermann!'

    expires_at = Account.find_by(login: 'hmustermann').expires_at
    assert_in_epsilon expires_at.to_i, 1.year.from_now.to_i, 1.hour
  end

  # brittle because the paypal sandbox isn't always responding in time and/or is
  # sometimes changed (button labels, headers etc.)
  if ENV['PM_BRITTLE'] == 'true'
    test 'signup via paypal and login' do
      visit '/'

      click_on 'Sign up'

      choose 'Single license for 30 EUR per year'
      fill_in 'User name', with: 'hmustermann'
      fill_in 'E-mail', with: 'hmustermann@example.com'
      fill_in 'Password', with: 'hmustermann'
      fill_in 'Confirm password', with: 'hmustermann'
      fill_in 'First name', with: 'Hans'
      fill_in 'Last name', with: 'Mustermann'
      check 'Subscribe to our newsletter?'
      check 'I read the terms of use carefully and agree'
      answer_brain_buster
      submit
      assert_text "Research interest can't be blank"

      fill_in 'Research/education interest and context', with: 'employed at DFK Paris'
      submit

      email_confirmation_request = ActionMailer::Base.deliveries[0]
      link = link_from_email(email_confirmation_request)
      visit link

      assert_equal("Single license", find('h1.page_title').text)

      choose 'user_mode_paypal'
      submit

      # paypal is slow
      using_wait_time 20 do

        # wait until cookie banner faded in
        sleep 2
        # click to accept cookies, in order to avoid cookie banner lying over back to merchant button, see below
        find("#acceptAllButton").click

        fill_in 'login_email', with: ENV['PM_PAYPAL_BUYER_ID']
        click_on 'Next'
        fill_in 'login_password', with: ENV['PM_PAYPAL_BUYER_PASSWORD']
        click_on 'Login'
        find('#payment-submit-btn').click
        # find('[data-test-id=continueButton]').click

        # cookie banner lies over button
        # Selenium::WebDriver::Error::ElementClickInterceptedError: element click intercepted:
        # Element <input track-submit="" type="submit" value="Zurück zum Händler" id="merchantReturnBtn"
        # class="btn btn-secondary full submit receipt ng-binding ng-scope" ng-click="returnToMerchant()" pa-marked="1">
        # is not clickable at point (688, 811). Other element would receive the click:
        # <p class="gdprCookieBanner_content gdprCookieBanner_content-custom">...</p>
        find("[data-testid='donepage-return-to-merchant-button'] a").click
      end

      # back in pandora

      # we are also slow
      using_wait_time 10 do
        # Simulate paypal IPN callback. This can't be tested since its a
        # back-channel request which paypal can't send to localhost:47001
        pt = PaymentTransaction.first
        # simulating transaction params
        assert pt.confirm(
          txn_id: '12345',
          payment_status: 'Completed',
          mc_gross: 30,
          mc_currency: 'EUR',
          business: ENV['PM_PAYPAL_SELLER_ID']
        )
        pt.complete
        assert_text 'Your payment was successful'
      end

      click_on 'Enjoy working with prometheus'
      submit

      assert_text 'Advanced search'
    end

  end

  test "start (but don't complete) paypal signup, then try invoice (see #391)" do
    visit '/'

    click_on 'Sign up'

    choose 'Single license for 30 EUR per year'
    fill_in 'User name', with: 'hmustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    check 'Subscribe to our newsletter?'
    check 'I read the terms of use carefully and agree'
    fill_in 'Research/education interest and context', with: 'employed at DFK Paris'
    answer_brain_buster
    submit

    email_confirmation_request = ActionMailer::Base.deliveries[0]
    link = link_from_email(email_confirmation_request)
    visit link

    choose 'user_mode_paypal'
    submit

    # we are now redirected to paypal but we simply fake the succeeded
    # transaction
    pt = PaymentTransaction.first
    assert pt.confirm(
      txn_id: '12345',
      payment_status: 'Completed',
      mc_gross: 30,
      mc_currency: 'EUR',
      business: ENV['PM_PAYPAL_SELLER_ID']
    )
    pt.complete
    pt.update_column :status, 'initialized'

    # after the account has expired, we try another transaction
    travel_to 18.months.from_now do
      visit '/'
      login_as 'hmustermann'
      assert_text 'Your account has expired'

      choose 'user_mode_paypal'
      check 'I read the terms of use carefully and agree'
      submit

      # we fake success as before (different txn id)
      pt = PaymentTransaction.first
      assert pt.confirm(
        txn_id: '67890',
        payment_status: 'Completed',
        mc_gross: 30,
        mc_currency: 'EUR',
        business: ENV['PM_PAYPAL_SELLER_ID']
      )
      pt.complete

      visit '/'
      assert_no_text 'Your account has expired'
    end
  end

  test 'signup via institution, then make a personal account' do
    visit '/'
    within '#campus_login_wrap' do
      check 'I accept the terms of use'
      submit
    end
    within '#statusbar' do
      assert_text 'Nowhere University'
    end

    click_on 'My Uploads'
    assert_text 'Please log in with a qualified account'

    find('a', text: 'Sign up!', match: :first).click
    choose 'Free access via your institution'
    fill_in 'User name', with: 'Hans M.'
    fill_in 'E-mail', with: 'hans.m@example.com'
    fill_in 'Password', with: 'Hans_MHans_M'
    fill_in 'Confirm password', with: 'Hans_MHans_M'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    check 'I read the terms of use carefully and agree'
    submit('Sign up')

    assert_text 'Login has to start with a Latin letter and can only contain Latin letters, digits, underscores and full stops and cannot end with a full stop'
    fill_in 'User name', with: 'Hans_M'
    submit('Sign up')

    assert_no_text "Research interest can't be blank"
    assert_text 'Thank you for your registration!'

    select 'Nowhere, Nowhere University'
    submit('Proceed')
    assert_text 'e-mail with a link'

    # now, only one email confirmation request email is sent!
    # email_confirmation_request = ActionMailer::Base.deliveries[1] # ActionMailer::Base.deliveries[0] is also email confirmation request email
    email_confirmation_request = ActionMailer::Base.deliveries[0]
    link = link_from_email(email_confirmation_request)
    visit link
    assert_text 'Your e-mail address has been confirmed'
    assert_text 'Your account has to be activated'

    login_as 'jdupont'
    click_on 'Administration'
    find('tr', text: /Hans Mustermann/).click_on('Edit')
    select '1 year', from: 'Expiration'
    submit('Save')

    login_as 'Hans_M'
    assert_text 'Welcome'
    assert_no_text 'Your account has to be activated'

    # Change institution
    within '#statusbar' do
      click_on 'Hans Mustermann'
    end

    Institution.create!({
      name: 'other',
      city: 'Other',
      title: 'Other University',
      country: 'Otherland',
      description: 'for testing, too',
      postalcode: '12345',
      homepage: 'https://uni-otherwhere.om',
      addressline: '1 University Drive',
      email: 'info@example.com',
      license: License.new({
        license_type: LicenseType.find_by!(title: 'library'),
        valid_from: 1.month.ago,
        paid_from: 2.months.from_now.beginning_of_quarter,
        expires_at: 1.month.from_now
      }, without_protection: true),
      issuer: 'prometheus'
      }, without_protection: true
    )

    click_on 'Obtain a new license or change your institution...'

    select 'Other, Other University'
    submit
    assert Account.last.status == 'pending'
  end

  test 'signup via institution immediately' do
    visit '/'
    click_on 'Sign up'
    choose 'Free access via your institution'
    check 'I read the terms of use carefully and agree'
    answer_brain_buster
    submit('Sign up')
    assert_text "Login can't be blank"
    assert_no_text "Research interest can't be blank"

    fill_in 'User name', with: 'hmustermann'
    fill_in 'E-mail', with: 'hmustermann@example.com'
    fill_in 'Password', with: 'hmustermann'
    fill_in 'Confirm password', with: 'hmustermann'
    fill_in 'First name', with: 'Hans'
    fill_in 'Last name', with: 'Mustermann'
    submit('Sign up')
    assert_text 'Thank you for your registration'

    assert_equal("Institution", find('h1.page_title').text)
    assert_text 'Please select your institution.'

    select 'Nowhere, Nowhere University'
    submit('Proceed')
    # submit # confirm email
    assert_text 'An e-mail with a link to confirm'

    # now, only one email confirmation request email is sent!
    # email_confirmation_request = ActionMailer::Base.deliveries[1] # ActionMailer::Base.deliveries[0] is also email confirmation request email
    email_confirmation_request = ActionMailer::Base.deliveries[0]
    link = link_from_email(email_confirmation_request)
    visit link
    assert_text 'Your e-mail address has been confirmed'

    click_on 'Search'
    assert_text 'Your account has to be activated'

    # the remainder is tested within another scenario below
  end

  # see #405
  test 'change institution' do
    login_as 'jdoe'
    within '#statusbar' do
      click_on 'John Doe'
    end
    click_on 'Obtain a new license or change your institution...'
    click_on 'Obtain a free license through your institution'
    select 'Nowhere, Nowhere University'
    submit 'Proceed'

    assert_css "a[href='mailto:jdupont@example.com']"

    login_as 'jdoe'
    assert_text 'Your account has to be activated'

    login_as 'jdupont'
    click_on 'Administration'
    click_on 'John Doe'
    assert_text 'Status pending'
    click_on 'Edit'
    select 'Activate'
    submit
    assert_text 'Status activated'

    login_as 'jdoe'
    assert_text 'Welcome, John Doe'
  end

  test 'change institution after account expiry (and approve with local admin)' do
    nowhere = Institution.find_by! name: 'nowhere'
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_columns expires_at: 2.weeks.ago, research_interest: 'n.a.'

    login_as 'jdoe'
    assert_text 'Your account has expired'
    click_on 'Obtain a free license through your institution'
    select 'Nowhere, Nowhere University'
    submit 'Proceed'
    
    assert_text 'Local administrators'
    assert_link 'Jean Dupont', href: /mailto/

    login_as 'jdupont'
    click_on 'Administration'
    click_on 'John Doe'
    click_on 'Edit'
    select '1 week', from: 'Expiration'
    submit
    assert_text 'successfully updated'

    mails = ApplicationMailer.deliveries
    assert_equal 1, mails.count
    assert_match /your account for prometheus has been activated/, mails.first.body.to_s
  end

  # brittle because the paypal sandbox isn't always responding in time and/or is
  # sometimes changed (button labels, headers etc.)
  if ENV['PM_BRITTLE'] == 'true'
    test 'signup with paypal after account expiry' do
      jdoe = Account.find_by! login: 'jdoe'
      jdoe.update_columns expires_at: 2.weeks.ago, research_interest: 'n.a.'

      login_as 'jdoe'
      assert_text 'Your account has expired'
      choose 'user_mode_paypal'
      fill_in 'Research/education interest and context', with: 'employed at DFK Paris'
      submit

      # we go through the entire process because the user receives a different
      # set of emails here
      # paypal is slow
      using_wait_time 20 do

         # wait until cookie banner faded in
        sleep 2
        # click to accept cookies, in order to avoid cookie banner lying over back to merchant button, see below
        find("#acceptAllButton").click

        # click_on 'English'
        # this has changed
        assert_text 'Pay with PayPal'
        sleep 3

        fill_in 'login_email', with: ENV['PM_PAYPAL_BUYER_ID']
        click_on 'Next'
        fill_in 'login_password', with: ENV['PM_PAYPAL_BUYER_PASSWORD']
        click_on 'Log In'

        find('[data-test-id=continueButton]').click

        # cookie banner lies over button
        # Selenium::WebDriver::Error::ElementClickInterceptedError: element click intercepted:
        # Element <input track-submit="" type="submit" value="Zurück zum Händler" id="merchantReturnBtn"
        # class="btn btn-secondary full submit receipt ng-binding ng-scope" ng-click="returnToMerchant()" pa-marked="1">
        # is not clickable at point (688, 811). Other element would receive the click:
        # <p class="gdprCookieBanner_content gdprCookieBanner_content-custom">...</p>
        find('#merchantReturnBtn').click
      end


      # we are slow
      using_wait_time 10 do
        # Simulate paypal IPN callback. This should can't be tested since its a
        # back-channel request which paypal can't send to localhost:47001
        pt = PaymentTransaction.first
        # simulating transaction params
        assert pt.confirm(
          txn_id: '12345',
          payment_status: 'Completed',
          mc_gross: 30,
          mc_currency: 'EUR',
          business: ENV['PM_PAYPAL_SELLER_ID']
        )
        pt.complete

        mails = ApplicationMailer.deliveries

        assert_equal 1, mails.count

        assert_match /continue using the prometheus image archive/, mails.first.body.to_s
      end

      sleep 5 # to wait for the auto-refresh to kick in
      login_as 'jdoe'
      assert_text 'Welcome'
    end
  end

  test 'reset my password' do
    # TODO: entering a non existing username yields a failed captcha in devel
    # and the below positive message in staging

    # We add a sidebar item to test #479
    box = Box.create!(
      ref_type: 'image',
      image_id: Upload.last.pid,
      owner_id: Account.find_by!(login: 'jdoe').id,
    )

    login_as 'jdoe', 'wrong-pass'

    assert_text 'Invalid user name or password'
    click_on 'reset your password'
    find('.submit_button').click
    assert_text 'Your captcha answer failed - please try again.'

    answer_brain_buster
    find('.submit_button').click

    assert_text 'An email with a link to create a new password has been sent to your email address.'
    mails = ActionMailer::Base.deliveries
    assert_equal 1, mails.size
    assert_match /Dear John Doe/, mails.first.body.to_s
    link = links_from_email(mails.first)[0]
    visit link

    assert_text 'Please enter a new password.'
    assert_no_text 'CDATA' #479
    fill_in 'Password', with: 'wrong-pass'
    fill_in 'Confirm password', with: 'wrong-pass'
    find('.submit_button').click
    assert_text 'successfully updated'

    click_on 'Log out'
    login_as 'jdoe', 'wrong-pass'
    assert_text 'Welcome, John Doe'
  end

  # test 'signup as open access db user (?)'

  test 'signup in German' do
    visit '/'
    click_on 'Deutsch'

    click_on 'Registrieren'

    choose 'Eine Woche kostenlos testen'
    fill_in 'Login-Name', with: 'hmustermann'
    fill_in 'E-Mail', with: 'hmustermann@example.com'
    fill_in 'Passwort', with: 'hmustermann'
    fill_in 'Passwort bestätigen', with: 'hmustermann'
    fill_in 'Vorname', with: 'Hans'
    fill_in 'Nachname', with: 'Mustermann'
    fill_in 'Forschungsinteresse und wissenschaftlicher Kontext', with: 'das digitale Bild in Forschung und Lehre'
    check 'Newsletter abonnieren?'
    check 'Ich habe die Nutzungsbedingungen sorgfältig durchgelesen und stimme ihnen zu'
    answer_brain_buster

    submit
    assert_equal("de", Account.find_by(login: "hmustermann").settings.locale)

    assert Account.find_by(login: "hmustermann").status.nil?

    email_confirmation_request = ActionMailer::Base.deliveries[0]
    link = link_from_email(email_confirmation_request)

    visit link

    assert_text 'Ihre E-Mail-Adresse wurde bestätigt. Danke!'
  end
end
