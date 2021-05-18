require "application_system_test_case"
Dir["./test/test_sources/*.rb"].each {|file| require file }

class ImagesTest < ApplicationSystemTestCase
  test 'display rights reproduction' do
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

    title = 'Rate this reproduction as "poor"'
    find("img[title='#{title}']").click

    within '#image_wrap .pm-ratings' do
      assert_text '2.0 in 1'
    end
  end

  if production_sources_available?
    test 'special rights links' do
      elastic = Pandora::Elastic.new
      elastic.update 'robertin', 'robertin-b0d69964270fc26b071969fa28cd5933133e75cc', {
        'rights_work' => ['rights_work_warburg'],
        'rights_reproduction' => ['http://creativecommons.org/publicdomain/zero/1.0/'],
        'authority_files_artist' => ['GND 118559737,http://d-nb.info/gnd/118559737'],
        'depository' => ['Lenbachhaus &lt;München&gt;,http://d-nb.info/gnd/4635860-2']
      }
      elastic.update 'robertin', 'robertin-ab3b223a34230a04ca72b64014edff82b63eed1e', {
        'rights_work' => ['rights_work_vgbk']
      }
      elastic.refresh

      login_as 'jdoe'

      # first image, warburg case
      # search
      fill_in 'search_value_0', with: 'b0d69964270fc26b071969fa28cd5933133e75cc'
      find('.search_query .submit_button').click
      assert_link 'The Warburg Institute, London', exact: true
      assert_link('http://creativecommons.org/publicdomain/zero/1.0/',
        href: 'http://creativecommons.org/publicdomain/zero/1.0/'
      )

      # single view
      visit '/en/image/robertin-b0d69964270fc26b071969fa28cd5933133e75cc'
      assert_link 'The Warburg Institute, London', exact: true
      assert_link 'GND 118559737', exact: true
      assert_link 'Lenbachhaus <München>', exact: true
      assert_link('http://creativecommons.org/publicdomain/zero/1.0/',
        href: 'http://creativecommons.org/publicdomain/zero/1.0/'
      )

      # collection view
      image = si('robertin-b0d69964270fc26b071969fa28cd5933133e75cc').image
      collection = Collection.find_by!(title: "John's private collection")
      collection.images << image
      visit "/en/collections/#{collection.id}"
      all(:link, 'List view').first.click
      assert_link('http://creativecommons.org/publicdomain/zero/1.0/',
        href: 'http://creativecommons.org/publicdomain/zero/1.0/'
      )

      # second image, vgbk case
      # search
      click_on 'Search'
      fill_in 'search_value_0', with: 'ab3b223a34230a04ca72b64014edff82b63eed1e'
      find('.search_query .submit_button').click
      assert_link 'VG Bild-Kunst', exact: true
      # single view
      visit '/en/image/robertin-ab3b223a34230a04ca72b64014edff82b63eed1e'
      assert_link 'VG Bild-Kunst', exact: true
    end
  end

  test 'miro' do
    with_real_images do
      elastic = Pandora::Elastic.new
      elastic.update 'daumier', 'daumier-4c26deb8710753c84e6a48d27129cf47c945c3d5', {
        'path' => 'miro'
      }
      elastic.refresh

      login_as 'jdoe'
      fill_in 'search_value_0', with: '4c26deb8710753c84e6a48d27129cf47c945c3d5'
      find('.search_query .submit_button').click

      img = find('img[id=daumier-4c26deb8710753c84e6a48d27129cf47c945c3d5]')
      assert_match /\/dummy\/r140\/miro.png/, img[:src]
      assert_match /\/dummy\/r400\/miro.png/, img[:_zoom_src]
    end
  end

  test 'show institution' do
    login_as 'jdoe'

    visit '/en/sources/daumier'
    click_on 'Information about the institution'
    assert_text "Ascona\nSwitzerland"
  end

  test 'iconclass links' do
    elastic = Pandora::Elastic.new
    elastic.update 'daumier', 'daumier-4c26deb8710753c84e6a48d27129cf47c945c3d5', {
      'iconclass' => ['42B7422']
    }
    elastic.refresh

    login_as 'jdoe'
    visit '/en/image/daumier-4c26deb8710753c84e6a48d27129cf47c945c3d5'
    assert_link '42B7422', href: 'http://iconclass.org/rkd/42B7422'
  end

  if production_sources_available?
    test 'show an image without elastic record' do
      login_as 'jdoe'

      image = Image.create!({
        pid: 'robertin-1234567890123456789012345678901234567890',
        source: Source.find_by!(name: 'robertin')
      }, without_protection: true)
      visit "/en/image/#{image.pid}"
      # assert_text 'This record is no longer available'
      assert_text 'ROBERTIN-database, Martin-Luther-Universität'

      # within a collection
      priv = Collection.find_by! title: "John's private collection"
      priv.images << image
      visit "/en/collections/#{priv.id}"
      assert_css "img[alt='[Not available]']"
      all('.list_controls').first.click_on 'List'
      assert_text 'This record is no longer available'
      assert_text 'ROBERTIN-database, Martin-Luther-Universität'
      all('.list_controls').first.click_on 'Gallery'
      assert_text 'This record is no longer available'
    end

    test 'access only open access images as dbuser' do
      Source.find_by!(name: 'daumier').update_attributes open_access: true

      visit '/en/sources/daumier/open_access' # daumier is now open access source
      find('#accepted').click
      find('.button_middle').click

      # daumier images are open access; they can be accessed by dbuser
      visit '/en/image/daumier-6c52234cbc832202fe66357580b836453732230c'
      assert_text " Enfin je vas donc t'être portière"

      # robertin images are not open access; they may not be accessed by dbuser
      visit '/en/image/robertin-b0d69964270fc26b071969fa28cd5933133e75cc'
      assert_text "You don't have privileges to access this images page. Please log in with a qualified account."
    end
  end
end
