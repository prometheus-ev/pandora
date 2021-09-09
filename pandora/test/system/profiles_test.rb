require "application_system_test_case"

class ProfilesTest < ApplicationSystemTestCase
  test 'show my profile' do
    login_as 'jdoe'
    
    within '#header' do
      click_on 'John Doe'
    end

    within '#header-section' do
      assert_text 'John Doe'
    end
  end

  if production_sources_available?
    test 'edit my profile and test settings' do
      jdoe = Account.find_by!(login: 'jdoe')
      jdoe.roles << Role.find_by!(title: 'admin')

      login_as 'jdoe'

      within '#header' do
        click_on 'John Doe'
      end

      click_on 'Edit'
      fill_in 'Title', with: 'Dr.'
      fill_in 'Address', with: 'Am Marktplatz 12'
      submit
      assert_text 'successfully updated'

      open_section 'account_settings'
      within '#account_settings-section' do
        select 'Deutsch', from: 'Preferred language'
        select 'Your collections', from: 'Start page'
        select 'Updated at', from: 'Sort order for account list'
        select 'Descending', from: 'Sort direction for account list'
        submit
      end
      assert_text 'successfully updated'

      open_section 'search_settings'
      within '#search_settings-section' do
        fill_in 'Number of results per page', with: '15'
        select 'Artist', from: 'Sort order for result list'
        select 'Gallery', from: 'Preferred view'
        check 'Zoom thumbnails?'
        submit
      end
      assert_text 'successfully updated'

      open_section 'collection_settings'
      within '#collection_settings-section' do
        select 'Updated at', from: 'Sort order for collection list'
        select 'Descending', from: 'Sort direction for collection list'
        select 'Credits', from: 'Sort order for image list'
        select 'Descending', from: 'Sort direction for image list'
        fill_in 'Number of images per page', with: '25'
        select 'Gallery', from: 'Preferred view'
        check 'Zoom thumbnails?'
        submit
      end
      assert_text 'successfully updated'

      open_section 'upload_settings'
      within '#upload_settings-section' do
        select 'Artist', from: 'Sort order for upload list'
        select 'Descending', from: 'Sort direction for upload list'
        fill_in 'Number of uploads per page', with: '50'
        submit
      end
      assert_text 'successfully updated'

      a = Account.find_by!(login: 'jdoe')
      assert_equal 'Dr.', a.title
      assert_equal 'Am Marktplatz 12', a.addressline
      assert_equal 'updated_at', a.collection_settings.list_order
      assert_equal 'DESC', a.upload_settings.direction

      click_on 'Uploads'
      assert_field 'order', with: 'artist'
      assert_field 'per_page', with: '50'
      assert_link 'Sort ascending' # so current direction is 'descending'

      collection = Collection.find_by!(title: "John's private collection")
      collection.images << create_upload('skull', approved_record: true).image

      click_on 'Collections'
      assert_field 'order', with: 'updated_at'
      assert_link 'Sort ascending' # so current direction is 'descending'
      # control unavailable
      # assert_field 'per_page', with: '20'

      click_on "John's private collection"
      # the images within the collection
      assert_link 'List' # so current view is 'gallery'
      assert_field 'order', with: 'credits'
      assert_field 'per_page', with: '25'
      assert_link 'Sort ascending' # so current direction is 'descending'
      assert all('div.zoom_link.enabled').count > 0 # image zoom is enabled

      click_on 'Search'
      fill_in 'search_value[0]', with: 'baum'
      submit
      assert_field 'order', with: 'artist'
      assert_field 'per_page', with: '15'
      assert all('div.zoom_link.enabled').count > 0 # image zoom is enabled
      assert all('div.view_link.gallery_view.inactive').count > 0 # so current view is 'gallery'

      click_on 'Administration'
      section = find('h3', text: 'Account').find(:xpath, 'following-sibling::*[1]')
      section.click_on 'List'
      assert_field 'order', with: 'updated_at'
      assert_link 'Sort ascending' # so current direction is 'descending'
      # control unavailable
      # assert_field 'per_page', with: '40'

      click_on 'Log out'
      
      login_as 'jdoe' 
      # after new login, German website version is displayed since German was set as
      # the default language in the user's account settings 
      assert_text 'Eigene Bildsammlungen suchen'

      # see https://prometheus-srv1.uni-koeln.de/redmine/issues/773
      # assert_match /\/de\//, current_url
    end
  end

  test 'delete (disable) my profile' do
    login_as 'jdoe'

    within '#header' do
      click_on 'John Doe'
    end
    within '#header-section' do
      click_on 'Disable'
    end
    # this should log the user out
    assert_text 'Your account has been disabled'
    assert_text 'Personal account login'

    login_as 'jdoe'
    assert_text 'Your account has expired'

    login_as 'superadmin'
    click_on 'Administration'
    within_admin_section 'Account' do
      fill_in 'value', with: 'jdoe'
      submit
    end
    click_on 'John Doe'
    accept_confirm do
      click_on 'Destroy'
    end
    assert_text 'successfully deleted!'
  end

  test 'show own institution' do
    visit '/'
    click_on 'Sitemap'
    click_on 'Your institution'
    assert_text 'Please log in first'

    within '#login_wrap' do
      fill_in 'User name or e-mail address', with: 'jdupont'
      fill_in 'Password', with: 'jdupontjdupont'
      submit
    end
    assert_text 'Nowhere University'
  end

  test 'download legacy presentation as a user' do
    login_as 'jdoe'

    within '#header' do
      click_on 'John Doe'
    end

    within '#legacy_presentations-section' do
      find('.section_toggle div').click
    end

    assert_text '2 Legacy presentations'
    assert_text 'empty.pdf'
    assert_text 'lorem.pdf'

    click_on 'lorem.pdf'
    # no error -> we are happy
  end

  test 'no profile for ipuser' do
    visit '/en/login'
    within '#campus_login_wrap' do
      submit
    end
    check 'I read the above terms of use carefully and agree!'
    submit
    within '#statusbar' do
      click_on "Nowhere University"
    end
    assert_text 'for testing only' # institution description
  end

  test "no profile for dbuser (and profile actions don't affect dbuser)" do
    robertin = Source.find_by!(name: 'robertin')
    robertin.update_attributes open_access: true

    visit '/'
    click_on 'Sitemap'
    click_on 'Open Access'
    assert_text 'ROBERTIN-database'
    click_on 'Enter "ROBERTIN-database"'
    within '#statusbar' do
      click_on "ROBERTIN-database"
    end
    check 'I read the above terms of use carefully and agree!'
    submit

    assert_text 'Institut für Klassische Altertumswissenschaften'

    # check that password reset doesn't mess with dbuser account
    visit '/'
    assert_text 'You are currently only searching in open access'
    click_on 'log in'
    click_on 'Forgotten?'
    assert_text 'Reset password'
    fill_in 'User name or e-mail address', with: 'jdoe@example.com'
    answer_brain_buster
    submit
    assert_text 'User name or e-mail address could not be found'
    assert_nil robertin.reload.dbuser.email

    # check that an old email confirmation link can't serve to mess with dbuser
    # ... we know the link doesn't work which is tested elsewhere so we simulate
    # the click by visiting:
    visit '/en/confirm_email'
    fill_in 'user[email]', with: 'jdoe@example.com'
    submit
    # nothing should happen, so:
    assert_nil robertin.reload.dbuser.email
  end

  test 'change email address' do
    login_as 'jdoe'
    within '#header' do
      click_on 'John Doe'
    end
    click_on 'Edit'

    fill_in 'E-mail', with: 'different@example.com'
    submit

    click_on 'Search'
    assert_text 'Please verify your e-mail address!'
  end

  test 'change email address having box in sidebar' do
    login_as 'jdoe'

    click_on 'My Uploads'
    find("[title='Store image in...']").find(:xpath, '..').click
    click_on 'Add image to sidebar'

    within '#sidebar' do
      assert_text 'Jean-Baptiste ' # ... Dupont: A Upload
    end

    within '#header' do
      click_on 'John Doe'
    end
    click_on 'Edit'

    fill_in 'E-mail', with: 'different@example.com'
    submit

    sleep 0.5
    assert_no_text 'Before you can enter the image archive'
  end

  test 'change research interest' do
    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.update mode: 'guest'

    login_as 'jdoe'
    within '#header' do
      click_on 'John Doe'
    end
    click_on 'Edit'
    fill_in 'Research/education interest and context', with: 'Weird field work'
    submit
    assert_text 'successfully updated'
    research_interest_check_email = ActionMailer::Base.deliveries[0]
    assert research_interest_check_email.to == [INFO_ADDRESS]
    assert_match  /\[pandora-ResearchInterestCheck\]/, research_interest_check_email.subject
    assert_match /Please check if the research interest is valid/, research_interest_check_email.body.to_s
  end

  test 'new terms of use' do
    value = TERMS_OF_USE_REVISION + 1
    stub_const :TERMS_OF_USE_REVISION, value do
      login_as 'jdoe'
      assert_text 'Our terms of use have changed'
      submit # without checking the box
      assert_text 'You have to accept our terms of use '

      check 'I read the above terms of use carefully and agree!'
      submit
      assert_text 'Advanced search'
    end
  end

  test 'change about (de/en)' do
    login_as 'jdoe'
    within '#statusbar' do
      click_on 'John Doe'
    end
    click_on 'Edit'
    fill_in 'About you [English]', with: 'I like pictures'
    fill_in 'About you [German]', with: 'Ich mag Bilder'
    submit

    jdoe = Account.find_by!(login: 'jdoe')
    assert_equal 'I like pictures', jdoe.about(:en)
    assert_equal 'Ich mag Bilder', jdoe.about(:de)

    click_on 'Edit'
    assert_field 'About you [English]', with: 'I like pictures'
    assert_field 'About you [German]', with: 'Ich mag Bilder'
  end
end
