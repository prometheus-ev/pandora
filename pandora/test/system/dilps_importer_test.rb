require "application_system_test_case"
Dir["./test/test_sources/*.rb"].each {|file| require file }

class DilpsImporterTest < ApplicationSystemTestCase
  setup do
    Upload.destroy_all
    Pandora::Elastic.new.destroy_index('darmstadt_tu*')
  end

  teardown do
    Upload.destroy_all
    Pandora::Elastic.new.destroy_index('darmstadt_tu*')
  end

  if production_sources_available?
    test 'index dilps source and create institutional uploads of darmstadt tu twice' do
      DarmstadtTu.index(create_institutional_uploads: true)

      login_as 'superadmin'

      click_on 'My Uploads'
      click_submenu 'Approved'

      assert_text 'Uploads 1 - 3 of 3'

      DarmstadtTu.index(create_institutional_uploads: true)

      login_as 'superadmin'

      click_on 'My Uploads'
      click_submenu 'Approved'

      assert_text 'Uploads 1 - 3 of 3'
    end

    test 'dilps importer run darmstadt tu' do
      login_as 'superadmin'

      click_on 'Search'
      click_submenu 'Advanced search'

      assert_text '2 databases selected'

      Pandora::DilpsImporter.new('darmstadt_tu').import
      click_submenu 'Advanced search'

      assert_text '3 databases selected'

      within '.pm-source-list' do
        uncheck 'all'
        within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
          find('.pm-toggle a').click
          check 'indices[darmstadt_tu]'
        end
      end

      fill_in 'search_value_0', with: '*'
      submit 'Search'

      check_records

      click_on 'My Uploads'
      click_submenu 'Approved'

      assert_text 'Uploads 1 - 3 of 3'

      assert_link 'Damenfrisur (Nachlass Lehmberg) 1', href: /\/en\/image\/upload-/
      assert_link 'Damenfrisur (Nachlass Lehmberg) 2', href: /\/en\/image\/upload-/
      assert_link 'Rückansicht einer Damenfrisur (Nachlass Lehmberg)', href: /\/en\/image\/upload-/

      check_records

      # Index institutional uploads.
      Source.find_by_name('darmstadt_tu').index

      sleep 1 # We need to wait a sec until the index is ready.

      click_on 'Search'
      click_submenu 'Advanced search'

      within '.pm-source-list' do
        uncheck 'all'
        within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
          find('.pm-toggle a').click
          check 'indices[darmstadt_tu]'
        end
      end

      fill_in 'search_value_0', with: '*'
      submit 'Search'

      check_records
    end
  end

  def check_records
    within '.list_row:nth-child(1)' do
      assert_text 'Artist 1'
      assert_text 'Damenfrisur (Nachlass Lehmberg) 1'
      assert_text 'location 1'
      assert_text '1950/1959 1'
      assert_text 'literature 1'
    end

    within '.list_row:nth-child(2)' do
      assert_text 'Artist 2'
      assert_text 'Damenfrisur (Nachlass Lehmberg) 2'
      assert_text 'location 2'
      assert_text '1950/1959 2'
      assert_text 'Dia-Lehrsammlung Wella'
      assert_text 'unbekannt'
    end

    within '.list_row:nth-child(3)' do
      assert_text 'Artist 3'
      assert_text 'Rückansicht einer Damenfrisur (Nachlass Lehmberg)'
      assert_text 'location 3'
      assert_text '1950/1959 3'
      assert_text 'Dia-Lehrsammlung Wella'
      assert_text 'unbekannt'
    end

    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    back

    within '.list_row:nth-child(2)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    back

    within '.list_row:nth-child(3)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end
  end
end

