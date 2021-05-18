require "application_system_test_case"
Dir["./test/test_sources/*.rb"].each {|file| require file }

class IndexingTest < ApplicationSystemTestCase
  setup do
    Pandora::Elastic.new.destroy_index('test*')
  end

  teardown do
    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'artist array field ordering' do
    skip 'Waiting for Elastic forum feedback...'

    TestSourceOrder.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_order]'
      end
    end

    fill_in 'search_value_0', with: '*'
    submit 'Search'

    within '.list_controls:last-child' do
      select 'Artist', from: 'order'
    end

    within '.list_row:nth-child(1)' do
      assert_text 'Albrecht | Efangus'
    end
    within '.list_row:nth-child(2)' do
      assert_text 'Bogus | Dolittle'
    end
  end

  test 'index pknd simple advanced all and artist search' do
    TestSourcePknd.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_pknd]'
      end
    end

    fill_in 'search_value_0', with: 'Raphael'
    submit 'Search'

    page.assert_selector('.list_row', count: 1)

    fill_in 'search_value_0', with: ''
    fill_in 'search_value_1', with: 'Raphael'
    submit 'Search'

    page.assert_selector('.list_row', count: 1)

    fill_in 'search_value_0', with: 'Michel Angelo Bonarota'
    fill_in 'search_value_1', with: ''
    submit 'Search'

    page.assert_selector('.list_row', count: 1)

    fill_in 'search_value_0', with: ''
    fill_in 'search_value_1', with: 'Michel Angelo Bonarota'
    submit 'Search'

    # TODO: there is no synonym for this in the test pknd.txt, but perhaps there
    # should be?
    # page.assert_selector('.list_row', count: 1)
  end

  test 'index vgbk expired artist' do
    TestSourceVgbk.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_vgbk]'
      end
    end

    fill_in 'search_value_0', with: '*'
    submit 'Search'

    within '.list_row:nth-child(1)' do
      assert_no_text 'VG Bild-Kunst'
    end

    within '.list_row:nth-child(2)' do
      assert_text 'VG Bild-Kunst'
    end

    within '.list_row:nth-child(3)' do
      assert_text 'VG Bild-Kunst'
    end

    within '.list_row:nth-child(4)' do
      assert_text 'VG Bild-Kunst'
    end
  end

  test 'index vgbk expired artist source without date_range' do
    TestSource.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source]'
      end
    end

    fill_in 'search_value_0', with: '*'
    submit 'Search'

    within '.list_row:nth-child(1)' do
      assert_text 'VG Bild-Kunst'
    end

    within '.list_row:nth-child(2)' do
      assert_text 'VG Bild-Kunst'
    end

    within '.list_row:nth-child(3)' do
      assert_no_text 'VG Bild-Kunst'
    end
  end

  test 'index, rate, reindex, search and sort by rating count and average' do
    # Index.
    TestSource.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source]'
      end
    end

    fill_in 'search_value_0', with: 'Title 1'
    submit 'Search'

    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    # Rate Title 1 with 2.
    title = 'Rate this reproduction as "poor"'
    find("img[title='#{title}']").click

    back

    fill_in 'search_value_0', with: 'Title 2'
    submit 'Search'

    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    # Rate Titel 2 with 1.
    title = 'Rate this reproduction as "unusable"'
    find("img[title='#{title}']").click

    login_as 'mrossi'

    click_submenu 'Advanced search'

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source]'
      end
    end

    fill_in 'search_value_0', with: 'Title 2'
    submit 'Search'

    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    # Rate Title 2 with 2.
    title = 'Rate this reproduction as "poor"'
    find("img[title='#{title}']").click

    # Reindex.
    TestSource.index

    click_on 'Search'
    click_submenu 'Advanced search'

    # Search.
    fill_in 'search_value_0', with: '*'
    submit 'Search'

    # Sort by rating count.
    within '.list_controls:last-child' do
      select 'Rating count', from: 'order'
    end

    within '.list_row:nth-child(1)' do
      assert_text 'Title 2'
    end

    within '.list_row:nth-child(2)' do
      assert_text 'Title 1'
    end

    # Sort by rating average.
    within '.list_controls:last-child' do
      select 'Rating average', from: 'order'
    end

    within '.list_row:nth-child(1)' do
      assert_text 'Title 1'
    end

    within '.list_row:nth-child(2)' do
      assert_text 'Title 2'
    end
  end

  test 'index, comment, answer comment, reindex, search comment' do
    comment_text = 'I will be indexed in just a moment. I am a injustamomentindexed comment.'
    comment_answer_text = 'I am a prettysoonindexed answer!'

    # Index.
    TestSource.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source]'
      end
    end

    fill_in 'search_value_0', with: '*'
    submit 'Search'

    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    # some of this is really slow
    using_wait_time 10 do
      open_section 'comments'

      # Comment.
      within '#comments-section' do
        click_on 'Leave a comment'
        fill_in 'Your comment', with: comment_text
        submit
      end
      assert_text 'successfully saved'

      # Answer comment.
      within '#comments-section' do
        click_on 'Leave a reply to this comment'
        fill_in 'Your reply', with: comment_answer_text
        submit
      end
      assert_text 'successfully saved'
    end

    # Reindex.
    TestSource.index

    click_on 'Search'
    click_submenu 'Advanced search'

    # Search comment.
    fill_in 'search_value_0', with: 'injustamomentindexed'
    submit 'Search'

    page.assert_selector('.list_row', count: 1)

    click_submenu 'Advanced search'

    # Search comment.
    fill_in 'search_value_0', with: 'prettysoonindexed'
    submit 'Search'

    page.assert_selector('.list_row', count: 1)
  end

  test 'raise exception when no encoding is given' do
    # TODO: wouldn't have to be a system test

    assert_raises Pandora::Exception do
      TestSourceNonAscii.index
    end
  end
end
