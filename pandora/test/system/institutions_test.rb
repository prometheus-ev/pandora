require "application_system_test_case"

class InstitutionsTest < ApplicationSystemTestCase
  # Deleting institutions is not supported. Instead their license simply
  # expires

  if ENV['PM_BRITTLE'] == 'true'
    test 'edit an institution' do
      # we change the institution's name to include a special character to ensure
      # the routes are working properly
      institution = Institution.find_by!(name: 'prometheus')
      institution.update_column :name, 'prometheus äüößéáóíúè'

      login_as 'superadmin'

      click_on 'Administration'
      section = find('h3', text: 'Institution').find(:xpath, 'following-sibling::*[1]')
      section.click_on 'List'

      within '.list_row', text: 'Köln, prometheus' do
        click_on 'Edit'
      end
      assert_text "Edit institution 'prometheus - Das verteilte"

      fill_in 'Title', with: 'Some new title'
      select 'school (250)', from: 'License'

      submit
      assert_text 'successfully updated'
      assert_equal 1, License.where(institution_id: institution.id).count

      # we also edit it again to test if an existing license works when updating
      click_on 'List'
      within '.list_row', text: 'Köln, prometheus' do
        click_on 'Edit'
      end
      select 'Albania', from: 'Country'
      submit
      assert_text 'successfully updated'
      assert_equal 'AL', Institution.find_by!(title: 'Some new title').country
    end
  end

  test 'create an institution' do
    login_as 'superadmin'

    click_on 'Administration'
    section = find('h3', text: 'Institution').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'Create'

    fill_in 'Name', with: 'Universität Frankfurt'
    fill_in 'Title', with: 'Johann Wolfgang Goethe-Universität Frankfurt'
    fill_in 'City', with: 'Frankfurt am Main'
    select 'campus (4200)', from: 'License'
    select '2020', from: 'institution_member_since_1i'
    select 'April', from: 'institution_member_since_2i'
    select '30', from: 'institution_member_since_3i'
    select 'jdoe', from: 'Contact'
    fill_in 'IP Ranges', with: "10.2.33.0/24\n10.2.34.0/24"
    fill_in 'Host names', with: "server.example.com\ngateway.example.com"

    submit
    assert_text 'successfully created'

    assert_equal 'jdoe', Institution.last.contact.login
    assert_equal 'campus', Institution.last.license.license_type.title
    assert_equal Date.new(2020, 4, 30), Institution.last.member_since
    assert_equal "10.2.33.0/24\r\n10.2.34.0/24", Institution.last.ipranges
    assert_equal ['server.example.com', 'gateway.example.com'], Institution.last.hostnames

    # render the edit form again to see if the values are correctly inserted
    # into the fields
    click_on 'Edit institution'
    assert_field 'Host names', with: "server.example.com\ngateway.example.com"
  end

  test 'list and filter institutions' do
    login_as 'superadmin'

    click_on 'Administration'
    section = find('h3', text: 'Institution').find(:xpath, 'following-sibling::*[1]')

    section.click_on 'List'
    assert_text 'Nowhere University'
    assert_text 'Köln, prometheus'

    within '.search_form' do
      fill_in 'value', with: 'nowhere'
      find('.submit_button').click
    end
    assert_text 'Nowhere University'
    assert_no_text 'Köln, prometheus'

    click_on 'Clear/Show all'
    assert_text 'Nowhere University'
    assert_text 'Köln, prometheus'

    click_on 'Köln'
    assert_no_text 'Nowhere University'
    assert_text 'Köln, prometheus'
  end

  test 'admin page search form' do
    login_as 'superadmin'

    click_on 'Administration'
    form = find("form[action='/en/institutions']")
    within form do
      fill_in 'value', with: 'now'
      submit 'Search'
    end
    assert_no_text 'Köln, prometheus'
    assert_text 'Nowhere, Nowhere University'
  end

  test 'list institutions without login' do
    visit '/en/institutions/licensed'
    assert_text 'Nowhere University'
  end

  test 'access for useradmins' do
    login_as 'jdupont'

    visit '/en/institutions/nowhere'
    assert_text 'Nowhere University'

    click_on 'Statistics'
    assert_text 'Csv stats'
    assert_field 'Institution', with: 'nowhere'
  end
end