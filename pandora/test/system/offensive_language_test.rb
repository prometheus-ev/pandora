require "application_system_test_case"
require 'test_sources/test_source_offensive'

class OffensiveLanguageTest < ApplicationSystemTestCase
  setup do
    TestSourceOffensive.index
    login_as 'jdoe'
  end

  test 'terms are initially hidden and showing/hiding works' do
    within '#menu' do
      click_on 'Search'
    end
    fill_in 'search_value_0', with: "*"
    find('.submit_button').click

    assert_text 'Der Z***'
    assert_text 'Drei N***'
    assert_text 'Ein M*** im Hemd'

    # display one of the terms
    within '.metadata', text: 'Ein M*** im Hemd' do
      click_on '***'
    end
    click_on 'Display'
    assert_text 'Der Z***'
    assert_text 'Drei N***'
    assert_text 'Ein Mohr* im Hemd'

    # hide it again
    within '.metadata', text: 'Ein Mohr* im Hemd' do
      click_on '*'
    end
    click_on 'Hide'
    assert_text 'Der Z***'
    assert_text 'Drei N***'
    assert_text 'Ein M*** im Hemd'

    # display all terms
    within '.metadata', text: 'Der Z***' do
      click_on '***'
    end
    click_on 'Display all'
    assert_text 'Der Zigeunerwagen*'
    assert_text 'Drei Negerinnen*'
    assert_text 'Ein Mohr* im Hemd'

    # hide all terms
    within '.metadata', text: 'Drei Negerinnen*' do
      click_on '*'
    end
    click_on 'Hide all'
    assert_text 'Der Z***'
    assert_text 'Drei N***'
    assert_text 'Ein M*** im Hemd'
  end

  test 'show/hide settings are reverted on page load' do
    within '#menu' do
      click_on 'Search'
    end
    fill_in 'search_value_0', with: "*"
    find('.submit_button').click

    within '.metadata', text: 'Ein M*** im Hemd' do
      click_on '***'
    end

    reload_page

    assert_text 'Der Z***'
    assert_text 'Drei N***'
    assert_text 'Ein M*** im Hemd'
  end

  test 'title attributes are taken into account' do
    within '#menu' do
      click_on 'Search'
    end
    fill_in 'search_value_0', with: "*"
    find('.submit_button').click

    assert_text 'Svenja Maler'

    page.all('div.image img').each do |img|
      assert_match /\*\*\*/, img['title']
    end
  end
end
