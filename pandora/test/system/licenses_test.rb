require "application_system_test_case"

class LicensesTest < ApplicationSystemTestCase
  test 'edit institution without any license' do
    institution = Institution.find_by!(name: 'prometheus')

    now = Time.mktime(2019, 5, 28, 16, 11, 23)
    travel_to now do
      login_as 'superadmin'

      click_on 'Administration'
      section = find('h3', text: 'Institution').find(:xpath, 'following-sibling::*[1]')
      section.click_on 'List'

      within '.list_row', text: 'Köln, prometheus' do
        click_on 'Edit'
      end
      assert_text "Edit institution 'prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre'"
      assert_select 'License', selected: ''
      assert_select 'institution[license_attributes][valid_from(1i)]', selected: ''
      assert_select 'institution[license_attributes][valid_from(2i)]', selected: ''
      assert_select 'institution[license_attributes][valid_from(3i)]', selected: ''
      assert_select 'Paid from', selected: ''
      submit
      assert_equal 0, institution.licenses.count

      back
      reload_page
      select 'school (250)', from: 'License'
      submit
      assert_equal 1, institution.licenses.count

      back
      reload_page
      assert_select 'License', selected: 'school (250)'
      y, m, d = Date.today.strftime("%Y-%B-%d").split('-')
      assert_select 'institution[license_attributes][valid_from(1i)]', selected: y
      assert_select 'institution[license_attributes][valid_from(2i)]', selected: m
      assert_select 'institution[license_attributes][valid_from(3i)]', selected: d
      assert_select 'Paid from', selected: Pandora::Utils.quarter_for(Date.today)
      submit
      assert_equal 1, institution.licenses.count
    end

    # the fields should be empty if the license is expired
    travel_to now + 16.months do
      back
      reload_page
      assert_select 'License', selected: ''
      assert_select 'institution[license_attributes][valid_from(1i)]', selected: ''
      assert_select 'institution[license_attributes][valid_from(2i)]', selected: ''
      assert_select 'institution[license_attributes][valid_from(3i)]', selected: ''
      assert_select 'Paid from', selected: ''
    end

    travel_to now + 10.months do
      reload_page
      select 'library (250)', from: 'License'
      submit
      assert_equal 2, institution.licenses.count
      assert institution.licenses.first.expired?
      assert_not institution.licenses.last.expired?
      assert_equal 'library', institution.licenses.last.license_type.title

      back
      reload_page
      assert_select 'License', selected: 'library (250)'
      y, m, d = Date.today.strftime("%Y-%B-%d").split('-')
      assert_select 'institution[license_attributes][valid_from(1i)]', selected: y
      assert_select 'institution[license_attributes][valid_from(2i)]', selected: m
      assert_select 'institution[license_attributes][valid_from(3i)]', selected: d
      assert_select 'Paid from', selected: Pandora::Utils.quarter_for(Date.today)

      click_on 'List'
      within '.list_row:nth-child(3)' do
        assert_css 'input[type=checkbox]'
      end
    end
  end

  test 'renew multiple licenses (institution list)' do
    now = Time.mktime(2019, 5, 28, 16, 11, 23)
    travel_to now do
      institution = Institution.find_by!(name: 'prometheus')
      institution.licenses << License.new(
        license_type: LicenseType.find_by!(title: 'school'),
        paid_from_quarter: '2019/2'
      )

      login_as 'superadmin'

      click_on 'Administration'
      section = find('h3', text: 'Institution').find(:xpath, 'following-sibling::*[1]')
      section.click_on 'List'

      submit 'Renew licenses'
      assert_text 'You have to select at least one institution'

      within '.list_row:nth-child(3)' do
        check 'id[]'
      end
      submit 'Renew licenses'
      assert_text '1 licenses successfully renewed'

      assert_equal 2, institution.licenses.count
      assert_equal Date.new(2020, 12, 31), institution.licenses.last.expires_at.utc.to_date
    end
  end

  test 'renew license (institution edit form)' do
    now = Time.mktime(2019, 5, 28, 16, 11, 23)

    travel_to now do
      institution = Institution.find_by!(name: 'prometheus')
      institution.licenses << License.new(
        license_type: LicenseType.find_by!(title: 'school'),
        paid_from_quarter: '2019/2'
      )


      login_as 'superadmin'

      click_on 'Administration'
      section = find('h3', text: 'Institution').find(:xpath, 'following-sibling::*[1]')
      section.click_on 'List'
      within '.list_row', text: 'Köln, prometheus' do
        click_on 'Edit'
      end
      click_on 'Renew license'
      assert_text '1 licenses successfully renewed'

      assert_equal 2, institution.licenses.count
      assert_equal Date.new(2020, 12, 31), institution.licenses.last.expires_at.utc.to_date

      # try to delete the license
      open_section('details')
      accept_confirm do
        click_on 'Delete'
      end
      assert_text 'successfully deleted'
    end
  end
end