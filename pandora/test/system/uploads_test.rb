require "application_system_test_case"

class UploadsTest < ApplicationSystemTestCase
  test 'show upload and verify keywords display' do
    login_as 'jdoe'

    click_on 'My Uploads'
    click_on 'A upload'

    assert_text 'Keywords painting'
  end

  test 'search' do
    login_as 'jdoe'

    visit '/uploads'

    select 'Artist', from: 'field'
    fill_in 'value', with: 'Jean'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    select 'Title', from: 'field'
    fill_in 'value', with: 'upload'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    select 'Location', from: 'field'
    fill_in 'value', with: 'Köln'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    select 'Description', from: 'field'
    fill_in 'value', with: 'art'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    select 'Keywords', from: 'field'
    fill_in 'value', with: 'painting'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    select 'Inventory no', from: 'field'
    fill_in 'value', with: '12345'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    login_as 'jnadie'
    create_upload('leonardo', {database: Account.find_by!(login: 'jnadie').database})

    visit '/uploads'

    select 'Database', from: 'field'
    fill_in 'value', with: 'Juan'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    select 'Database', from: 'field'
    fill_in 'value', with: 'Nadie'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    select 'Database', from: 'field'
    fill_in 'value', with: 'User'

    submit 'Search'
    assert_text 'Uploads 1 of 1'
  end

  test 'search umlaut' do
    upload_bar = create_upload('leonardo', {title: 'Bar'})
    upload_baer = create_upload('leonardo', {title: 'Bär'})

    login_as 'jdoe'

    visit '/uploads'

    select 'Title', from: 'field'
    fill_in 'value', with: 'bär'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    upload_bar.destroy
    upload_baer.destroy
  end

  test 'create an upload' do
    login_as 'jdoe'

    click_on 'My Uploads'
    find('div.button_middle', text: 'Create new upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/skull.jpg')
    fill_in 'Title', with: 'Mona Lisa'
    select 'In the public domain', from: 'upload[license]'
    choose 'upload_rights_work_rights_work_vgbk'
    assert_text 'Show this upload as search result (to all users)'
    submit
    assert_text 'successfully uploaded!'

    # check no index update on create (upload is not approved)
    upload = Upload.last
    assert_not upload.super_image.elastic_record['_found']

    # add a keyword using the suggest
    fill_in 'Keywords', with: 'pai'
    find('li', text: /painting/).click
    within '#object_basic-section' do
      submit('Save')
    end
    assert 'painting', Upload.last.keywords.first.title

    # check no index update on update (upload is still not approved)
    assert_not upload.super_image.elastic_record['_found']

    # add a location with html, see below
    within '#object_geographic-section' do
      fill_in 'Location', with: '<marquee>'
      submit
    end
    assert_text 'successfully updated!'

    click_on 'My Uploads'

    assert_link 'VG Bild-Kunst'
  end

  test 'create an upload with long metadata' do
    upload_long_metadata = create_upload(
      'leonardo',
      {
        title: 'Gemälderestauratorinnen Letizia Marcattilli und Maria Canavan, Bank of America Global Arts & Culture Executive Rena De Sisto, Kuratorin italienischer und spanischer Kunst Aoife Brady, Managerin des Bank of America Art Programme Nikki Wright in der National Gallery of Ireland',
        origin: "Anonyme Auktion London (Philips), 24. Juni 1980, Nr. 55 (als \"D. Ryckaert\"); anonyme Auktion, London (Sotheby's), 3. Juni 1981, Nr. 87 (als \"Sweerts\"); 1981, bei Sir Humphreys Wakefield & Partners, Ldt., London (als \"Sweerts\"); anonyme Auktion, New York (Sotheby's), 30. Januar 2014, Nr. 236 (als Umfeld von Michael Sweerts); 2015, im Kunsthandel Bijl-Van Urk, Alkmaar.",
        discoveryplace: "Cornelia Escher „GEAM and ZERO. Spaces between architecture and art“, in: Tiziana Caianiello u. Barbara Könches (Hrsgg.), Between the viewer and the work. Encounters in space: essays on ZERO art, Heidelberg 2019, S. 69–81, https://doi.org/10.11588/arthistoricum.541"
      }
    )

    login_as 'jdoe'

    visit '/uploads'

    select 'Title', from: 'field'
    fill_in 'value', with: 'Marcattilli'

    submit 'Search'
    assert_text 'Uploads 1 of 1'

    upload_long_metadata.destroy
  end

  test 'reuse latest metadata' do
    login_as 'jdoe'

    click_on 'My Uploads'
    find('div.button_middle', text: 'Create new upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/mona_lisa.jpg')
    fill_in 'Title', with: 'Mona Lisa'
    select 'In the public domain', from: 'upload[license]'
    choose 'upload_rights_work_rights_work_vgbk'
    submit
    assert_text 'successfully uploaded!'

    fill_in 'Artist', with: 'Leonardo da Vinci'
    fill_in 'Keywords', with: 'pai'
    find('li', text: /painting/).click
    within '#object_basic-section' do
      submit('Save')
    end
    assert 'painting', Upload.last.keywords.first.title

    assert_text 'successfully updated!'

    visit '/en/uploads'
    find('div.button_middle', text: 'Create new upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/john.jpg')
    fill_in 'Title', with: 'Saint John the Baptist'
    submit
    find('#reuse_latest_metadata').click

    assert_field 'Artist', with: 'Leonardo da Vinci'
    assert_field 'Title', with: 'Mona Lisa'
    assert_field 'Keywords', with: 'painting'

    open_section('object_rights')
    assert_field 'upload_license', with: 'In the public domain'
  end

  test 'modify upload @brittle' do
    login_as 'jdoe'

    click_on 'My Uploads'
    within '.list_row:first-child' do
      find('img.upload-edit-icon').click
    end

    within '#object_geographic-section' do
      fill_in 'Location', with: 'Happurg'
      using_wait_time 10 do
        find('#upload-location-search-result li:first-child').click
      end
      lat = find("input[name='upload[latitude]']").value.to_f
      lng = find("input[name='upload[longitude]']").value.to_f
      assert_in_delta 49.49277, lat, 0.005
      assert_in_delta 11.47152, lng, 0.005
      find('div.button_middle', text: 'Save').click
    end

    assert_text 'Object successfully updated!'

    click_on 'My Uploads' # Back to list
    assert_text 'Happurg'
  end

  test 'show upload and send email to owner' do
    login_as 'jdoe'

    click_on 'My Uploads'
    click_on 'A upload'

    find('div.email').click
    fill_in 'Message', with: 'hello'
    find('div.button_middle', text: 'Submit').click

    assert_text 'Your message has been delivered'
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  test 'delete an upload' do
    upload = Upload.last

    login_as 'jdoe'

    click_on 'My Uploads'

    within '.list_row:first-child' do
      accept_confirm do
        click_on 'Delete image from database'
      end
    end
    assert_text 'successfully deleted'
    assert_text 'Search uploads'
    assert_no_text 'A upload'

    # there should also not be any errors related to removing the index doc,
    # although it doesn't exist
  end

  test 'list uploads' do
    login_as 'superadmin'

    click_on 'My Uploads'
    assert_no_text 'A upload'

    click_submenu 'All'
    assert_text 'A upload'

    click_submenu 'Approved'
    assert_no_text 'A upload'

    click_submenu 'Unapproved'
    assert_text 'A upload'

    within '.list_row', text: /A upload/ do
      find('img.upload-edit-icon').click
    end

    within '#object_admin-section' do
      check 'Approved?'
      find('div.button_middle', text: 'Save').click
    end

    click_on 'My Uploads'
    assert_no_text 'A upload'

    click_submenu 'All'
    assert_text 'A upload'

    click_submenu 'Unapproved'
    assert_no_text 'A upload'

    click_submenu 'Approved'
    assert_text 'A upload'
  end

  test 'filter uploads' do
    with_real_images do
      create_upload 'leonardo'
      create_upload 'last_supper'

      login_as 'jdoe'
      click_on 'My Uploads'

      select 'Title', from: 'field'
      fill_in 'value', with: 'supper'
      submit 'Search'
      assert_text 'Last supper'
      assert_no_text 'Mona lisa'
      assert_no_text 'Leonardo'

      fill_in 'value', with: 'leo'
      submit 'Search'
      assert_no_text 'Last supper'
      assert_no_text 'Mona lisa'
      assert_text 'Leonardo'
    end
  end

  test 'associate with parent and release' do
    create_upload 'leonardo'

    login_as 'jdoe'
    click_on 'My Uploads'

    within '.list_row', text: /Leonardo/ do
      find('img.upload-edit-icon').click
    end

    open_section 'object_parent'
    select 'A upload', from: 'Connect the object with a parent object'
    submit 'Connect'
    assert_text 'successfully updated'

    # test associated action
    click_on 'Leonardo'
    click_on 'Show all...'
    assert_text 'A upload'
    assert_text 'Leonardo'

    within '.list_row', text: /Leonardo/ do
      find('img.upload-edit-icon').click
    end

    open_section 'object_parent'
    within '#object_parent-section' do
      assert_text 'A upload'
      assert_text '1 associated image'
    end
    accept_confirm do
      submit 'Disconnect parent object'
    end
    assert_text 'successfully disconnected'
  end

  test 'zoom function toggle' do
    with_real_images do
      login_as 'jdoe'

      click_on 'My Uploads'
      find_link('A upload').find('img').hover()
      find_link('A upload').find("img[src*='r140']")

      # wait for toggle to be ready (top & bottom), then click it
      assert_css('.toggle_results_zoom', count: 2)
      all('.toggle_results_zoom')[0].click

      find_link('A upload').find('img').hover()
      find_link('A upload').find("img[src*='r400']")
    end
  end

  test 'uploads are not available without login' do
    upload = Upload.last
    visit "/en/image/#{upload.pid}"
    assert_text 'Please log in first.'
  end

  test 'uploads are not available to other users' do
    login_as 'mrossi'

    upload = Upload.last
    visit "/en/image/#{upload.pid}"
    assert_text "You don't have privileges to access this"
  end

  test 'uploads are available to admins' do
    login_as 'superadmin'

    upload = Upload.last
    visit "/en/image/#{upload.pid}"
    assert_text 'A upload'

    sa = Account.find_by! login: 'superadmin'
    sa.roles = Role.where(title: 'admin')
    sa.save

    visit "/en/image/#{upload.pid}"
    assert_text 'A upload'
  end

  test 'edit selected images (multi edit)' do
    create_upload 'leonardo'

    login_as 'jdoe'

    click_on 'My Uploads'
    find('div.list_row:nth-child(1)').check('image[]')
    find('div.list_row:nth-child(2)').check('image[]')
    within '.position-top' do
      button = find('.edit_button', text: 'Edit selected images')
      scroll_to button
      button.click
    end
    within '#object_basic-section' do
      fill_in 'Artist', with: 'Luigi Davide'
      submit('Save')
    end
    assert_text 'successfully updated!'
    assert(Upload.all.to_a.all?{|u| u.artist == 'Luigi Davide'})
  end

  test 'geotag display' do
    with_real_images do
      create_upload 'skull'
      login_as 'jdoe'

      click_on 'My Uploads'
      within '.list_row', text: /Skull/ do
        click_on 'Edit upload'
      end
      assert_text 'Latitude 59.42078'
      assert_text 'Longitude 24.80317'
      assert_link href: /maps.google.com\/maps\?q=59/

      fill_in 'upload[latitude]', with: '32.7471823'
      fill_in 'upload[longitude]', with: '-117.2536688'

      within '#object_geographic-section' do
        submit
      end

      # shouldn't have changed the exif
      assert_text 'Latitude 59.42078'
      assert_text 'Longitude 24.80317'
      upload = Upload.find_by!(title: 'Skull')
      assert_equal 32.74720, upload.latitude
      assert_equal -117.25400, upload.longitude
    end
  end

  # TODO: test upload latest
  # TODO: test strong parameters
  # TODO: test "upload another file"

  test 'change quota' do
    login_as 'jdoe'
    click_on 'My Uploads'
    assert_text 'Using 70 KB of 1000 MB (about 0.01%)'
    logout

    login_as 'superadmin'
    click_on 'Administration'
    within(:xpath, ".//div[h3='Source']") do
      click_on 'List'
    end
    within(:xpath, ".//div[a='User database 3']") do
      click_on 'Edit'
    end
    source_quota = find('#source_quota')
    assert_equal "1000", source_quota.value
    fill_in 'source_quota', with: '0'
    submit('Save')
    logout

    login_as 'jdoe'
    click_on 'My Uploads'
    find('div.button_middle', text: 'Create new upload').click
    assert_text 'You\'ve reached your quota limit of 0 Bytes.'
    logout

    login_as 'superadmin'
    click_on 'Administration'
    within(:xpath, ".//div[h3='Source']") do
      click_on 'List'
    end
    within(:xpath, ".//div[a='User database 3']") do
      click_on 'Edit'
    end
    source_quota = find('#source_quota')
    assert_equal "0", source_quota.value
    fill_in 'source_quota', with: '1000'
    submit('Save')
    logout

    login_as 'jdoe'
    click_on 'My Uploads'
    find('div.button_middle', text: 'Create new upload').click
    assert_text 'Select a file and add the mandatory metadata'
    logout
  end

  test "approving an upload doesn't remove it from private collections" do
    login_as 'jdoe'
    click_on 'Collections'
    click_on 'Create a new collection'
    fill_in 'Title', with: 'A new private collection'
    submit

    click_on 'My Uploads'
    find('div.button_middle', text: 'Create new upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/skull.jpg')
    fill_in 'Title', with: 'Skull of a Skeleton with Burning Cigarette'
    submit
    assert_text 'successfully uploaded!'

    click_on "My Uploads"
    row = find('.list_row', text: 'Skull')
    row.find('.store_image .popup_toggle').click
    select "A new private collection", from: "own_collections_selector"
    assert_text "Image successfully stored in collection 'A new private collection'"

    click_on 'Collections'
    click_on "A new private collection"
    assert_text('1 Image')
    assert has_css?("div.image a img##{Upload.last.pid}")

    logout

    login_as 'superadmin'
    click_on 'Administration'

    within(:xpath, '//div[h3/text()="Upload"]') do
      click_on "Unapproved"
    end

    within('.list_row', text: 'Skull') do
      click_on 'Edit'
    end

    check "Approved?"
    find("#approve_table .submit_button").click
    assert_text "Object successfully updated!"
    logout

    # the upload is now approved and should therefore have ben indexed and
    # the (global) "sources" Source should reflect that
    upload = Upload.last
    doc = upload.super_image.elastic_record['_source']
    assert_equal ['Skull of a Skeleton with Burning Cigarette'], doc['title']
    assert_equal 1, Source.find_by!(name: 'uploads').record_count

    login_as 'jdoe'
    click_on 'Collections'
    click_on "A new private collection"
    assert_text('1 Image')
    assert has_css?("div.image a img##{Upload.last.pid}")
  end

  test 'records are removed from index when unapproved' do
    upload = Upload.last
    upload.update_column :approved_record, true
    upload.index_doc
    assert_equal 1, Source.find_by!(name: 'uploads').record_count

    login_as 'superadmin'
    click_on 'Administration'

    within(:xpath, '//div[h3/text()="Upload"]') do
      click_on "Approved"
    end

    within('.list_row', text: 'A upload') do
      click_on 'Edit'
    end

    uncheck "Approved?"
    find("#approve_table .submit_button").click
    assert_text "Object successfully updated!"

    # the index doc shouldn't exist anymore and the (global) "uploads" Source
    # should reflect that
    upload = Upload.last
    assert_not upload.super_image.elastic_record['found']
    assert_equal 0, Source.find_by!(name: 'uploads').record_count
  end

  test 'klapsch filter' do
    upload = Upload.last
    upload.update_column :title, 'a KlaPsCh pic!'

    login_as 'superadmin'
    click_on 'Administration'

    within(:xpath, '//div[h3/text()="Upload"]') do
      click_on "Unapproved"
    end

    within('.list_row', text: 'a KlaPsCh pic!') do
      click_on 'Edit'
    end
    check "Approved?"
    find("#approve_table .submit_button").click
    assert_text "Object successfully updated!"

    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries[0]
    assert_match /The upload has not been indexed/, mail.body.to_s
  end

  test 'returns working image url for indexed uploads (also after removing from index)' do
    with_env 'PM_USE_TEST_IMAGE' => 'false' do
      restore_images_dir

      upload = Upload.first
      upload.update_columns approved_record: true
      upload.index_doc

      pid = upload.pid.sub('upload-', 'uploads-')
      size = nil

      si = Pandora::SuperImage.new(pid)
      response = Faraday.get(si.image_url(:small))
      assert_equal 200, response.status
      size = response.body.size

      upload.update_columns approved_record: false
      upload.index_doc

      si = Pandora::SuperImage.new(pid)
      response = Faraday.get(si.image_url(:small))
      assert_equal 502, response.status

      # We check that no data is rendered for the (now) unapproved record
      si = Pandora::SuperImage.new(pid)
      mrossi = Account.find_by! login: 'mrossi'
      collection = Collection.create! owner: mrossi, title: 'mine'
      collection.images << si.image

      login_as 'mrossi'
      visit '/en/collections'
      assert_no_text 'A upload'
      click_on 'mine'
      assert_no_text 'A upload'
      click_on '[Not available]'
      assert_no_text 'A upload'
    end
  end

  # test 'add multiple uploads to a collection' do
  #   create_upload 'skull'
  #   login_as 'jdoe'

  #   click_on 'My Uploads'
  #   within '.position-top' do
  #     check 'Select all uploads'
  #     find('.store_button .button_middle').click
  #   end

  #   select "John's private collection"
  #   assert_text '2 images successfully stored'

  #   priv = Collection.find_by! title: "John's private collection"
  #   assert_equal 2, priv.images.count
  # end
end
