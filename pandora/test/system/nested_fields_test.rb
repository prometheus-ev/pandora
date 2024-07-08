require "application_system_test_case"

class NestedFieldsTest < ApplicationSystemTestCase
  setup do
    require_test_sources
  end

  # skip: still stashed
  test 'seach nested artist name and dating @skip' do
    TestSourceNestedFields.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_nested_fields]'
      end
    end

    fill_in 'search_value_1', with: 'Artist Sonnenblume'
    submit 'Search'

    page.assert_selector('.list_row', count: 2)

    fill_in 'search_value_1', with: '1920-2020'
    submit 'Search'

    page.assert_selector('.list_row', count: 1)
  end

  test 'linkified nested location' do
    TestSourceNestedFields.index
    login_as 'jdoe'
    pid = pid_for(1, 'test_source_nested_fields')

    visit "/en/image/#{pid}"
    assert_link('8410588', href: 'http://sws.geonames.org/8410588')

    # see also api_test.rb: "image data and metadata (xml, upload)"
  end
end
