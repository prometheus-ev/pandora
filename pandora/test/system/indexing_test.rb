require "application_system_test_case"
Dir["./test/test_sources/*.rb"].each {|file| require file }

class IndexingTest < ApplicationSystemTestCase
  test 'index multi word synonyms' do
    with_all_synonyms do
      Pandora::Indexing::Indexer.index(['test_source_multi_word_synonyms'])
      #TestSourceMultiWordSynonyms.index
    end

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: 'Museum Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_multi_word_synonyms]'
      end
    end

    fill_in 'search_value_0', with: 'Mona Lisa'
    submit 'Search'

    page.assert_selector('.list_row', count: 4)

    fill_in 'search_value_0', with: ''
    fill_in 'search_value_2', with: 'Mona Lisa'
    submit 'Search'

    page.assert_selector('.list_row', count: 4)

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'vgbk link with pknd rudolf bauer' do
    with_all_synonyms do
      TestSourceVgbk.index
    end

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_vgbk]'
      end
    end

    fill_in 'search_value_0', with: 'R. Bauer'
    submit 'Search'

    page.assert_selector('.list_row', count: 1)

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'index synonyms masternames' do
    with_all_synonyms do
      TestSourceMasternames.index
    end

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_masternames]'
      end
    end

    fill_in 'search_value_0', with: 'Veronikameister'
    submit 'Search'

    page.assert_selector('.list_row', count: 3)

    fill_in 'search_value_0', with: ''
    fill_in 'search_value_1', with: 'Veronikameister'
    submit 'Search'

    page.assert_selector('.list_row', count: 3)

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'index synonym de en' do
    with_all_synonyms do
      TestSourceDeEn.index
    end

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_de_en]'
      end
    end

    fill_in 'search_value_0', with: 'müller'
    submit 'Search'

    page.assert_selector('.list_row', count: 3)

    fill_in 'search_value_0', with: ''
    fill_in 'search_value_1', with: 'müller'
    submit 'Search'

    page.assert_selector('.list_row', count: 2)

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'index synonym sonnenblume asterisk' do
    with_all_synonyms do
      TestSourceSunflowerAsterisk.index
    end

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: '<Kind> Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source_sunflower_asterisk]'
      end
    end

    fill_in 'search_value_0', with: 'sunflower*'
    submit 'Search'

    page.assert_selector('.list_row', count: 4)

    fill_in 'search_value_0', with: ''
    fill_in 'search_value_0', with: 'sonnenblume*'
    submit 'Search'

    page.assert_selector('.list_row', count: 4)

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'asterisk search order' do
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

    assert_field 'order', with: 'title'
    assert_link 'Sort descending' # so current direction is 'ascending'
    fill_in 'search_value_0', with: ''

    fill_in 'search_value_1', with: '*'
    submit 'Search'

    assert_field 'order', with: 'artist'
    assert_link 'Sort descending' # so current direction is 'ascending'
    fill_in 'search_value_1', with: ''

    fill_in 'search_value_2', with: '*'
    submit 'Search'

    assert_field 'order', with: 'title'
    assert_link 'Sort descending' # so current direction is 'ascending'
    fill_in 'search_value_2', with: ''

    fill_in 'search_value_3', with: '*'
    submit 'Search'

    assert_field 'order', with: 'location'
    assert_link 'Sort descending' # so current direction is 'ascending'
    fill_in 'search_value_3', with: ''

    fill_in 'search_value_0', with: '*'
    fill_in 'search_value_1', with: '*'
    submit 'Search'

    assert_field 'order', with: 'title'
    assert_link 'Sort descending' # so current direction is 'ascending'
    assert_text "Please use the '*' search in one search field only. The first one has been used for this search."

    fill_in 'search_value_0', with: '*'
    fill_in 'search_value_1', with: 'Albrecht'
    submit 'Search'

    assert_field 'order', with: 'relevance'
    assert_link 'Sort ascending' # so current direction is 'descending'
    assert_text "Please do not use the '*' search in combination with other search values. '*' inputs have been removed for this search."

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'artist array field ordering' do
    skip 'Waiting for Elastic forum feedback...'

    TestSourceOrder.index
    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: 'Museum Databases (0/1)' do
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

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'index pknd simple advanced all and artist search' do
    with_all_synonyms do
      TestSourcePknd.index
    end

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

    page.assert_selector('.list_row', count: 1)

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'index vgbk expired artist' do
    with_all_synonyms do
      TestSourceVgbk.index
    end

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

    within '.list_row', text: /Title 1/ do
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

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'index vgbk expired artist source without date_range' do
    with_all_synonyms do
      TestSource.index
    end

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: 'Museum Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source]'
      end
    end

    fill_in 'search_value_0', with: '*'
    submit 'Search'

    within '.list_row', text: 'Florenz' do # Katźe auf Stuhl
      assert_text 'VG Bild-Kunst'
    end

    within '.list_row', text: 'Katze auf Stuhl (Seitenansicht)' do
      assert_text 'VG Bild-Kunst'
    end

    within '.list_row', text: 'Hamster auf Stuhl' do
      assert_no_text 'VG Bild-Kunst'
    end

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'index, rate, reindex, search and sort by rating count and average' do
    TestSource.index

    login_as 'jdoe'

    find_link('Advanced search').find('div').click

    within '.pm-source-list' do
      uncheck 'all'
      within '.pm-groups > li', text: 'Museum Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source]'
      end
    end

    fill_in 'search_value_0', with: 'Hamster auf Stuhl'
    submit 'Search'
    within '.list_row:nth-child(1)' do
      find("img[title='View full record']").find(:xpath, '..').click
    end

    # Rate Title 1 with 2.
    title = 'Rate this reproduction as "poor"'
    find("img[title='#{title}']").click

    back

    fill_in 'search_value_0', with: 'Maus auf Stuhl'
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
      within '.pm-groups > li', text: 'Museum Databases (0/1)' do
        find('.pm-toggle a').click
        check 'indices[test_source]'
      end
    end

    fill_in 'search_value_2', with: 'Maus auf Stuhl'
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
      assert_text 'Maus auf Stuhl'
    end

    within '.list_row:nth-child(2)' do
      assert_text 'Hamster auf Stuhl'
    end

    # Sort by rating average.
    within '.list_controls:last-child' do
      select 'Rating average', from: 'order'
    end

    within '.list_row:nth-child(1)' do
      assert_text 'Hamster auf Stuhl'
    end

    within '.list_row:nth-child(2)' do
      assert_text 'Maus auf Stuhl'
    end

    Pandora::Elastic.new.destroy_index('test*')
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
      within '.pm-groups > li', text: 'Museum Databases (0/1)' do
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

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'raise exception when no encoding is given' do
    # TODO: wouldn't have to be a system test

    assert_raises Pandora::Exception do
      TestSourceNonAscii.index
    end
  end
end
