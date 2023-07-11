require "application_system_test_case"

class NestedFieldsTest < ApplicationSystemTestCase
  setup do
    require_test_sources
  end
  
  test 'seach nested artist name and dating' do
    skip 'still stashed'

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
end
