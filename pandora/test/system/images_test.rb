require "application_system_test_case"
Dir["./test/test_sources/*.rb"].each{|file| require file}

class ImagesTest < ApplicationSystemTestCase
  test 'display rights reproduction' do
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

    fill_in 'search_value_0', with: 'Katze'
    submit 'Search'

    within '.list_row:nth-child(1)' do
      assert_link 'Q1250020', href: 'https://www.wikidata.org/wiki/Q1250020'
      assert_link 'CC BY SA 4.0 international', href: 'https://creativecommons.org/licenses/by-sa/4.0/legalcode'

      find("img[title='View full record']").find(:xpath, '..').click
    end

    assert_link 'Q1250020', href: 'https://www.wikidata.org/wiki/Q1250020'
    assert_link 'CC BY SA 4.0 international', href: 'https://creativecommons.org/licenses/by-sa/4.0/legalcode'

    find("img[title='Copyright and publishing information']").find(:xpath, '..').click

    assert_link 'Q1250020', href: 'https://www.wikidata.org/wiki/Q1250020'
    assert_link 'CC BY SA 4.0 international', href: 'https://creativecommons.org/licenses/by-sa/4.0/legalcode'

    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'rate an image' do
    login_as 'jdoe'

    click_on 'My Uploads'
    find("img[title='View full record']").click

    assert_no_text 'Owner'

    title = 'Rate this reproduction as "poor"'
    find("img[title='#{title}']").click

    within '#image_wrap .pm-ratings' do
      assert_text '2.0 in 1'
    end

    assert_not Upload.last.super_image.elastic_record['found']
  end

  test 'special rights links' do
    TestSource.index

    elastic = Pandora::Elastic.new
    pid_1 = pid_for(1)
    pid_2 = pid_for(2)

    # elastic.update 'robertin', 'robertin-b0d69964270fc26b071969fa28cd5933133e75cc', {
    elastic.update 'test_source', pid_1, {
      'rights_work' => ['rights_work_warburg'],
      'rights_reproduction' => ['http://creativecommons.org/publicdomain/zero/1.0/'],
      'authority_files_artist' => ['GND 118559737,http://d-nb.info/gnd/118559737'],
      'depository' => ['Lenbachhaus &lt;München&gt;,http://d-nb.info/gnd/4635860-2']
    }
    # elastic.update 'robertin', 'robertin-ab3b223a34230a04ca72b64014edff82b63eed1e', {
    elastic.update 'test_source', pid_2, {
      'rights_work' => ['rights_work_vgbk']
    }
    elastic.refresh

    login_as 'jdoe'

    # first image, warburg case
    # search
    fill_in 'search_value_0', with: pid_1
    find('.search_query .submit_button').click
    assert_link 'The Warburg Institute, London', exact: true
    assert_link(
      'http://creativecommons.org/publicdomain/zero/1.0/',
      href: 'http://creativecommons.org/publicdomain/zero/1.0/'
    )

    # single view
    visit "/en/image/#{pid_1}"
    assert_link 'The Warburg Institute, London', exact: true
    assert_link 'GND 118559737', exact: true
    assert_link 'Lenbachhaus <München>', exact: true
    assert_link(
      'http://creativecommons.org/publicdomain/zero/1.0/',
      href: 'http://creativecommons.org/publicdomain/zero/1.0/'
    )

    # collection view
    image = si(pid_1).image
    collection = Collection.find_by!(title: "John's private collection")
    collection.images << image
    visit "/en/collections/#{collection.id}"
    all(:link, 'List view').first.click
    assert_link(
      'http://creativecommons.org/publicdomain/zero/1.0/',
      href: 'http://creativecommons.org/publicdomain/zero/1.0/'
    )

    # second image, vgbk case
    # search
    click_on 'Search'
    fill_in 'search_value_0', with: pid_2
    find('.search_query .submit_button').click
    assert_link 'VG Bild-Kunst', exact: true
    # single view
    visit "/en/image/#{pid_2}"
    assert_link 'VG Bild-Kunst', exact: true
  end

  test 'miro' do
    with_real_images do
      TestSource.index

      pid = pid_for(1)

      elastic = Pandora::Elastic.new
      elastic.update 'test_source', pid, {
        'path' => 'miro'
      }
      elastic.refresh

      login_as 'jdoe'
      fill_in 'search_value_0', with: pid
      find('.search_query .submit_button').click

      img = find("img[id=#{pid}]")
      assert_match /\/dummy\/r140\/miro.png/, img[:src]
      assert_match /\/dummy\/r400\/miro.png/, img[:_zoom_src]
    end
  end

  test 'show institution' do
    TestSourceSorting.index

    login_as 'jdoe'

    visit '/en/sources/test_source_sorting'
    click_on 'Information about the institution'
    assert_text "Ascona\nSwitzerland"
  end

  test 'iconclass links' do
    TestSource.index

    pid = pid_for(1)

    elastic = Pandora::Elastic.new
    elastic.update 'test_source', pid, {
      'iconclass' => ['42B7422']
    }
    elastic.refresh

    login_as 'jdoe'
    visit "/en/image/#{pid}"
    assert_link '42B7422', href: 'http://iconclass.org/rkd/42B7422'
  end

  test 'show an image without elastic record' do
    TestSource.index

    login_as 'jdoe'

    pid = pid_for(99)

    image = Image.create!(
      pid: pid,
      source: Source.find_by!(name: 'test_source')
    )
    visit "/en/image/#{image.pid}"
    # assert_text 'This record is no longer available'
    assert_text 'TEST-Source, University of Halle'

    # within a collection
    priv = Collection.find_by! title: "John's private collection"
    priv.images << image
    visit "/en/collections/#{priv.id}"
    assert_css "img[alt='[Not available]']"
    all('.list_controls').first.click_on 'List'
    assert_text 'This record is no longer available'
    assert_text 'TEST-Source, University of Halle'
    all('.list_controls').first.click_on 'Gallery'
    assert_text 'This record is no longer available'
  end

  test 'access only open access images as dbuser' do
    TestSource.index
    TestSourceSorting.index

    Source.find_by!(name: 'test_source').update open_access: true

    visit '/en/sources/test_source/open_access'
    find('#accepted').click
    find('.button_middle').click

    # TestSource images are open access; they can be accessed by dbuser
    pid = pid_for(1)
    visit "/en/image/#{pid}"
    assert_text "Katze auf Stuhl"

    # TestImageSorting images are not open access; they may not be accessed by dbuser
    pid = pid_for(1, 'test_source_sorting')
    visit "/en/image/#{pid}"
    assert_text "You don't have privileges to access this images page. Please log in with a qualified account."
  end
end
