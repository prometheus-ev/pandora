require "application_system_test_case"

class SearchTest < ApplicationSystemTestCase
  setup do
    TestSource.index
    TestSourceSorting.index
  end

  test 'normal search' do
    login_as 'jdoe'

    fill_in 'search_value_0', with: 'stuhl'
    find('.search_query .submit_button').click
    assert_text /Record 1 - 10 of \d+ records/
    assert_text 'Katze auf Stuhl'

    all('.icon_next').first.click
    assert_text /Record 11 - 13 of \d+ records/

    within '.list_controls:last-child' do
      select 'Title', from: 'order'
    end
    assert_text /Record 1 - 10 of \d+ records/
    assert_no_text 'Wellensittich auf Stuhl'

    within '.list_controls:last-child' do
      click_on 'Sort descending'
    end
    assert_no_text 'Affe auf Stuhl'
    within '.list_controls:last-child' do
      click_on 'Sort ascending'
    end
    assert_no_text 'Wellensittich auf Stuhl'

    within '.pm-top' do
      find_field('page').send_keys "2\n"
    end

    assert_text 'Record 11 - 13 of 13 records'

    within '.pm-top' do
      find_field('page').send_keys "1\n"
    end

    assert_text 'Affe auf Stuhl'

    within '.pm-top' do
      select '20', from: 'per_page'
    end
    assert_text /Record 1 - 13 of \d+ records/
    assert_text 'Affe auf Stuhl'

    # check per_page isn't changed by a page change
    all('.icon_next').first.click
    within '.pm-top' do
      find_field('per_page', with: '20')
    end
    all('.icon_prev').first.click

    all(:link, 'Gallery view').first.click
    assert_css '.image_list.view-gallery'

    within '.list_row:nth-child(1)' do
      assert_text 'Affe auf Stuhl'
    end
    within '.list_row:nth-child(2)' do
      assert_text 'Fliege auf Stuhl'
    end
    within '.list_row:nth-child(3)' do
      assert_text 'Hamster auf Stuhl'
    end
    all(:link, 'List view').first.click
    assert_css '.image_list.view-list'

    within '.list_row:nth-child(1)' do
      find("img[title='Download image and metadata.']").find(:xpath, '..').click
    end
    # the file downloads but checking success here is difficult. We will just
    # be happy that there is no exception for now

    within '.list_row:nth-child(1)' do
      link = find("img[title='Link to image in original database']").find(:xpath, '..')
      assert_match /nothing.nowhere/, link['href']
    end

    within '.list_row:nth-child(1)' do
      find("img[title='Copyright and publishing information']").find(:xpath, '..').click
    end
    assert_text 'The permission to publish this image cannot be obtained directly via prometheus'

    back
    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end
    assert_text 'Details'
    assert_text 'Comments'
    # Disabled, see #1225.
    # assert_text 'Related images'

    back
    within '.list_row:nth-child(1)' do
      find("img[title='View original']").find(:xpath, '..').click
    end
    # again, we are happy with no errors since the result is difficult to
    # check
  end

  test 'advanced search' do
    login_as 'jdoe'

    find_link('Advanced search').find('div').click
    within '.pm-source-list' do
      groups = all('.pm-groups .pm-header').map{|e| e.text.strip}
      assert_equal ['Museum Databases (1/1)', 'Research Databases (1/1)'], groups

      click_on 'City'
      groups = all('.pm-groups .pm-header').map{|e| e.text.strip}
      assert_equal ['Ascona (1/1)', 'Halle (1/1)'], groups

      click_on 'Keywords'
      groups = all('.pm-groups .pm-header').map{|e| e.text.strip}
      assert_equal ['Archaeology (1/1)', 'Art history (1/1)'], groups

      click_on 'Open access'
      groups = all('.pm-groups .pm-header').map{|e| e.text.strip}
      assert_equal ['Non Open Access (2/2)'], groups

      click_on 'Title'
      groups = all('.pm-groups .pm-header').map{|e| e.text.strip}
      titles = ["Test Source (1/1)", "Test Source (Sorting) (1/1)"]
      assert_equal titles, groups
      titles.each do |title|
        within '.pm-groups > li', text: title do
          find('* > .pm-header .pm-toggle a').click
        end
      end

      click_on 'Kind'
      within '.pm-groups > li', text: 'Museum Databases (1/1)' do
        find('* > .pm-header .pm-toggle a').click
      end
      assert_text 'TEST-Source'
      assert_text 'Museum database, Halle, Archaeology'

      within '.pm-groups > li', text: 'Research Databases (1/1)' do
        find('* > .pm-header .pm-toggle a').click
      end
      assert_text 'TEST-Source (sorting)'

      within '.pm-groups > li', text: 'Research Databases' do
        find('* > .pm-header .pm-toggle a').click
      end
      assert_no_text 'TEST-Source (sorting)'
    end

    link = find_link("Go to the database's homepage")
    assert_match /nothing.nowhere/, link['href']

    click_on("Information about the database")
    switch_to_tab 1
    assert_text 'TEST-Source'
    assert_text '12 records'
    switch_to_tab 0

    # test adding more criteria
    find('div.row-adder').click
    assert_css "input[name*='search_value']", count: 5
    field = all("input[name*='search_value']")[4]
    assert_equal 'search_value_4', field['id']
    assert_equal 'search_value[4]', field['name']
    assert_equal '5', field['tabindex']

    # do an actual search
    fill_in 'search_value_0', with: 'stuhl'
    submit

    assert_css '#image_list_form .list_row' # there is at least one result
  end

  test 'advanced search boolean or' do
    TestSourceBoolean.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    assert_text '3 databases selected'

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_boolean]'
      end
    end

    fill_in 'search_value_0', with: 'katze'
    submit 'Search'

    assert_text 'Record 1 - 2 of 2 records'

    select 'and', from: 'boolean_fields_selected[1]'
    select 'Artist', from: 'search_field[1]'
    fill_in 'search_value_1', with: 'leonardo'
    submit 'Search'

    assert_text 'Record 1 - 1 of 1 records'

    select 'or', from: 'boolean_fields_selected[1]'
    submit 'Search'

    assert_text 'Record 1 - 3 of 3 records'

    Indexing::Index.delete("test_source_boolean*")
  end

  test 'advanced search boolean and' do
    login_as 'jdoe'

    fill_in 'search_value_0', with: 'Donatello Stuhl'
    submit 'Search'
    assert_text 'Record 1 - 10 of 11 records'

    fill_in 'search_value_0', with: 'Donatello AND Stuhl'
    submit 'Search'
    assert_text 'Record 1 - 10 of 11 records'

    fill_in 'search_value_0', with: 'Affe AND Stuhl'
    submit 'Search'
    assert_text 'Record 1 - 1 of 1 records'
  end

  test 'sample search' do
    login_as 'superadmin'

    click_on 'Search'
    click_submenu 'Advanced search'

    fill_in 'search_value_0', with: 'stuhl'
    submit 'Search'
    check 'Filter by sample'
    submit 'Filter'
    assert_css '.list_row', count: 2
    assert_css 'td.source-field', text: 'TEST-Source,', count: 1
    assert_css 'td.source-field', text: 'TEST-Source (sorting)', count: 1

    fill_in 'sample_size', with: 2
    submit 'Search'
    assert_css '.list_row', count: 3
    assert_css 'td.source-field', text: 'TEST-Source,', count: 2
    assert_css 'td.source-field', text: 'TEST-Source (sorting)', count: 1
  end

  test 'open access sources (without login)' do
    visit '/'
    click_on 'Sitemap'
    click_on 'Open Access'
    assert_text 'Sorry, there are currently no databases available for Open Access.'

    Source.find_by!(name: 'test_source').update open_access: true

    click_on 'Sitemap'
    click_on 'Open Access'
    assert_text 'TEST-Source'
    click_on 'Enter "TEST-Source"'

    # need to accept terms
    check 'I read the terms of use carefully and agree!'
    submit

    fill_in 'search_value[0]', with: 'stuhl'
    submit 'Search'
    assert_text 'Record 1 - 10 of 12 records'
    within '#statusbar' do
      assert_link('TEST-Source', href: /\/en\/sources\/test_source$/)
    end
  end

  test "honor user's search settings" do
    login_as 'jdoe'

    # check without specific settings
    fill_in 'search_value_0', with: 'stuhl'
    find('.search_query .submit_button').click
    assert_text 'Record 1 - 10'
    assert has_select?('order', selected: 'Relevance')
    assert has_link?('Sort ascending') # the default should be descending for order by relevance
    assert_css('.pm-top [id=link-to-list].inactive') # so the current view is the list
    assert has_css?('.toggle_results_zoom[_zoom_enabled=true]')

    within '.list_controls:last-child' do
      select 'Rating average', from: 'order'
      assert has_link?('Sort ascending')
      select 'Rating count', from: 'order'
      assert has_link?('Sort ascending')
      select 'Artist', from: 'order'
      assert has_link?('Sort descending')
      select 'Title', from: 'order'
      assert has_link?('Sort descending')
      select 'Location', from: 'order'
      assert has_link?('Sort descending')
      select 'Date', from: 'order'
      assert has_link?('Sort descending')
      select 'Credits', from: 'order'
      assert has_link?('Sort descending')
      select 'Rights work', from: 'order'
      assert has_link?('Sort descending')
      select 'Rights reproduction', from: 'order'
      assert has_link?('Sort descending')
    end

    # change the settings
    click_on 'Your profile'
    open_section 'search_settings'
    within '#search_settings-section' do
      select 'Rating average', from: 'Sort order for result list'
      fill_in 'Number of results per page', with: 5
      select 'Gallery', from: 'Preferred view'
      uncheck 'Zoom thumbnails?'
      submit
    end
    assert_text 'successfully updated'

    # verify settings' effect
    click_on 'Search'
    fill_in 'search_value_0', with: 'stuhl'
    find('.search_query .submit_button').click
    assert_text 'Record 1 - 5'
    assert has_select?('order', selected: 'Rating average')
    assert has_link?('Sort ascending') # so the current direction is descending
    assert_css('.pm-top [id=link-to-gallery].inactive') # so the current view is the gallery
    assert has_css?('.toggle_results_zoom[_zoom_enabled=false]')
  end

  test "search page one if sort order direction is changed" do
    login_as 'jdoe'
    fill_in 'search_value_0', with: '*'
    find('.search_query .submit_button').click
    all('.icon_next').first.click
    all('.sort_icon').first.click

    assert_equal '1', all("input[name='page']").first['placeholder']
  end

  test 'credits teaser display' do
    pid = pid_for(1)

    elastic = Pandora::Elastic.new
    record = elastic.record(pid)
    record['_source']['credits'] = 30.times.map do |i|
      "lorem #{i} ipsum is a long sentence with little message!"
    end
    record['_source']['credits'] += [
      'https://wendig.io',
      'Wendig OÜ,https://wendig.io',
      "Musée Carnavalet, Paris Musées,http://parismuseescollections.paris.fr/"
    ]
    elastic.update('test_source', pid, record['_source'])
    elastic.refresh

    login_as 'jdoe'
    fill_in 'search_value_0', with: 'ipsum'
    submit

    credits = find('td.credits-field')
    assert credits.text.size <= 500
    assert_match /more/, credits.text

    find('td.credits-field').find('span.a.dim').click
    assert_link 'https://wendig.io'
    assert_link 'Wendig OÜ', href: 'https://wendig.io'
    assert_link 'Musée Carnavalet, Paris Musées', href: 'http://parismuseescollections.paris.fr/'

    # check proper link rendering when truncation doesn't kick in
    record['_source']['credits'] = [
      'ipsum',
      "Musée Carnavalet, Paris Musées,http://parismuseescollections.paris.fr/"
    ]
    elastic.update('test_source', pid, record['_source'])
    elastic.refresh
    reload_page
    assert_link 'Musée Carnavalet, Paris Musées', href: 'http://parismuseescollections.paris.fr/'
  end

  test 'missing image source' do
    login_as 'jdoe'

    pid = pid_for(1)

    visit "/en/image/#{pid}"

    # now we delete the source from a specific image and reload the page
    image = Image.find_by! pid: pid
    image.update_column :source_id, nil
    reload_page

    # this used to raise errors because super_image wouldn't ensure the source
    # on the image provided to the constructor
    assert_text 'Katze auf Stuhl'
  end

  # TODO: test image and metadata download when date is not an array, see #492

  test 'simple time query' do
    login_as 'jdoe'

    visit '/en/searches/advanced'
    fill_in 'search_value_0', with: '*'
    submit

    check 'Filter by date'
    fill_in 'From year', with: '1970'
    fill_in 'To year', with: '1980'
    submit 'Filter'

    assert_text 'Record 1 - 1 of 1 records'
    assert_text 'Artist 1'
  end
end
