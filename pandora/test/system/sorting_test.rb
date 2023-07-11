require "application_system_test_case"

class SortingTest < ApplicationSystemTestCase
  test 'title sorting' do
    TestSourceSorting.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: 'Research Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_sorting]'
      end
    end

    fill_in 'search_value_0', with: '*'
    submit 'Search'

    within '.pm-top' do
      select '20', from: 'per_page'
    end

    results = all('.list_row .title-field').map{|e| e.text}
    expected = [
      'äa',
      '"Ab',
      '!ac',
      'Äd',
      '_äe',
      'Af',
      'ag',
      '*Ba',
      'bb',
      '*Bc',
      "12 | c'11 | cKs",
      'Hase auf Stuhl',
      '123'
    ]
    assert_equal expected, results
  end
end
