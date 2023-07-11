require "application_system_test_case"

class WikidataTest < ApplicationSystemTestCase
  test "add/edit/delete wikidata on 'artist' (write to 'artist_wikidata')" do
    TestSource.index
    login_as 'jdoe'

    pid = pid_for(1)
    visit "/en/image/#{pid}"

    click_on 'add a Wikidata ID'
    fill_in 'wikidata_id.label', with: 'Raphael'
    find('li', text: "Italian painter and architect").click
    click_on 'Save'

    assert_link 'go to the Wikidata Page', href: 'https://www.wikidata.org/wiki/Q5597'

    # the new value should immediately be searchable
    click_on 'search'
    assert_field 'search_value[0]', with: 'Q5597'
    assert_text 'Katze auf Stuhl'

    # the new value should persist through re-indexing
    TestSource.index
    reload_page
    assert_text 'Katze auf Stuhl'

    # edit
    back
    click_on 'edit'
    fill_in 'wikidata_id.label', with: 'Raphael'
    find('li', text: "fictional Teenage Mutant Ninja Turtles character").click
    click_on 'Save'

    assert_link 'go to the Wikidata Page', href: 'https://www.wikidata.org/wiki/Q2078291'

    # delete
    click_on 'edit'
    click_on 'Delete'
    assert_text 'add a Wikidata ID'
    assert_no_link 'go to the Wikidata Page', href: 'https://www.wikidata.org/wiki/Q2078291'
  end

  test "edit existing wikidata for 'artist'" do
    TestSourceNestedFields.index
    login_as 'jdoe'

    pid = pid_for(1, 'test_source_nested_fields')
    visit "/en/image/#{pid}"

    click_on 'add a Wikidata ID'
    fill_in 'wikidata_id.label', with: 'Raphael'
    find('li', text: "fictional Teenage Mutant Ninja Turtles character").click
    click_on 'Save'

    assert_link 'go to the Wikidata Page', href: 'https://www.wikidata.org/wiki/Q2078291'

    # the new value should persist through a page reload
    reload_page
    assert_link 'go to the Wikidata Page', href: 'https://www.wikidata.org/wiki/Q2078291'

    click_on 'edit'
    fill_in 'wikidata_id.label', with: 'Raphael'
    find('li', text: "Italian painter and architect").click
    click_on 'Save'

    assert_link 'go to the Wikidata Page', href: 'https://www.wikidata.org/wiki/Q5597'
  end

  test 'shows existing wikidata id in search result (nested artist)' do
    TestSourceNestedFields.index
    login_as 'jdoe'

    pid = pid_for(1, 'test_source_nested_fields')
    visit '/en/searches'
    fill_in 'search_value[0]', with: pid
    submit

    within '.list_row' do
      assert_no_link 'Q183458'
      assert_no_link 'Q762'

      within ".artist", text: /Andrea del Verrocchio/ do
        assert_no_link 'edit'
      end
    end
  end

  test 'shows existing wikidata id in search result' do
    TestSource.index
    login_as 'jdoe'

    pid = pid_for(3, 'test_source')
    elastic.update('test_source', pid, {artist_wikidata: 'Q42'})
    elastic.refresh

    visit '/en/searches'
    fill_in 'search_value[0]', with: pid
    submit

    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    assert_link 'Q42'
  end
end
