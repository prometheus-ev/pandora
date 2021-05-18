require "application_system_test_case"

class OAuthClientsTest < ApplicationSystemTestCase
  test 'list, show, update and delete' do
    login_as 'superadmin'
    click_on 'Administration'
    within_admin_section 'Auth client' do
      click_on 'List'
    end

    click_on 'Meta-Image'
    assert_text 'somekey'

    click_on 'Edit'
    fill_in 'Name', with: 'Mäta-Image'
    submit
    assert_text 'successfully updated'
    assert_text 'Mäta-Image'

    accept_confirm do
      click_on 'Delete'
    end
    assert_text 'successfully deleted'

    click_on 'List'
    assert_no_text 'Meta-Image'
    assert_no_text 'Mäta-Image'
  end

  test 'create' do
    login_as 'superadmin'
    click_on 'Administration'
    within_admin_section 'Auth client' do
      click_on 'Create'
    end

    fill_in 'Name', with: 'My-App'
    fill_in 'Homepage', with: 'https://my-app.example.com'
    fill_in 'Callback URL', with: 'oob'
    submit
    assert_text 'successfully created'

    click_on 'List'
    assert_text 'My-App'
  end
end