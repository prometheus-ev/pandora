require "application_system_test_case"

class CollectionsTest < ApplicationSystemTestCase
  test 'filter & sort collections' do
    collection = Collection.find_by!(title: "John's private collection")
    collection.update_attributes(
      keyword_list: "fotografie\nwelthauptstadt der fotografie"
    )

    login_as 'jdoe'

    click_on 'Collections'

    # check https://redmine.prometheus-srv.uni-koeln.de/issues/1138
    select 'Keywords', from: 'field'
    fill_in 'value', with: 'fotografie'
    find('.submit_button', text: 'Search').click
    assert_text "John's private collection", count: 1
    
    select 'Title', from: 'field'
    fill_in 'value', with: 'collaboration'
    find('.submit_button', text: 'Search').click
    assert_text '1 of 1'
    assert_text "John's collaboration collection"
    assert_no_text "John's private collection"
    assert_no_text "John's public collection"

    click_on 'Clear/Show all'
    assert_text '3 of 3'

    all(:field, name: 'order').first.select 'Owner'
    # no error is good
  end

  test 'create a collection' do
    login_as 'jdoe'

    click_on 'Collections'
    find('.plus_button').click
    fill_in 'Title', with: 'nice ones'
    fill_in 'Description', with: 'my collection of nice pics'
    fill_in 'Keywords', with: 'tree'
    fill_in 'Links', with: "https://example.com\nhttps://wendig.io"
    fill_in 'References', with: "Some\nthing"
    choose 'Readable'
    fill_in 'Collaborators', with: 'mrossi'
    submit

    assert_text "Collection 'nice ones' successfully created!", wait: 5

    assert_text 'nice ones'
    assert_text 'my collection of nice pics'
    assert_text 'Publicly readable'
    assert_text '0 image'
    assert_text '2 link'
    assert_text '2 references'

    find('#details-section .expand').click

    within '#details-section' do
      assert_text 'You'
      assert_text 'Mario Rossi'
      assert_text 'tree'
    end

    # correct edit form field population
    collection = Collection.find_by! title: 'nice ones'
    visit "/en/collections/#{collection.id}/edit"
    assert_field 'Links', with: "https://example.com\nhttps://wendig.io"
    assert_field 'References', with: "Some\nthing"
  end

  test 'shared collections' do
    login_as 'mrossi'

    click_on 'Collections'
    assert_no_text "John's private collection"

    click_submenu 'Public'
    assert_text "John's public collection"
    assert_text "John's collaboration collection"

    click_on "John's collaboration collection"
    click_on 'Edit'
    fill_in 'Description', with: 'something new'
    submit

    assert_text "Collection 'John's collaboration collection' successfully updated!"
    assert_text 'something new'
  end

  test 'public expired collection' do
    login_as 'mrossi'

    click_on 'Collections'
    click_submenu 'Public'
    assert_text "John Expired's public collection"
    assert_text "by John Expired"

    click_on "John Expired's public collection"
    assert_text "by John Expired"

    click_on 'Add collection to sidebar'
    within '#sidebar' do
      assert_text "by John Expired"
    end
  end

  test 'add an image to a collection, download it, then remove the image' do
    login_as 'jdoe'

    fill_in 'search_value_0', with: 'baum'
    find('.search_query .submit_button').click

    row = find('.list_row', text: 'Femme sous un arbre')
    row.find('.store_image .popup_toggle').click
    select "John's private collection", from: "own_collections_selector"
    assert_text "Image successfully stored in collection 'John's private collection'"

    click_on 'Collections'
    click_on "John's private collection"

    # test list view
    within_upper_list_controls do
      click_on 'List'
    end
    assert_text 'Femme sous un arbre'

    click_on 'Download collection'

    # we are happy with no errors here: The zip content will be verified in an
    # API test

    within '#images-section' do
      accept_confirm do
        click_on 'Delete image from collection'
      end
      assert_text 'none'
    end

    click_on 'Deutsch'
    click_on 'Suche'

    fill_in 'search_value_0', with: 'baum'
    find('.search_query .submit_button').click

    row = find('.list_row', text: 'Femme sous un arbre')
    row.find('.store_image .popup_toggle').click
    select "John's private collection", from: "own_collections_selector"
    assert_text "Bild erfolgreich in der Bildsammlung 'John's private collection' gespeichert."

    click_on 'Bildsammlungen'
    click_on "John's private collection"

    # test list view
    within_upper_list_controls do
      click_on 'Listenansicht'
    end
    assert_text 'Femme sous un arbre'

    within '#images-section' do
      accept_confirm do
        click_on 'Lösche das Bild aus der Bildsammlung'
      end
    end
  end

  test 'add several images to an existing collection at once' do
    collection = Collection.find_by!(title: "John's private collection")
    ca = collection.created_at
    ua = collection.updated_at

    login_as 'jdoe'

    fill_in 'search_value_0', with: 'baum'
    find('.search_query .submit_button').click

    results = all('.list_row')
    results[0..2].each do |r|
      r.find('input[type=checkbox]').click
    end

    find('.store_controls.position-top .button_middle').click
    select("John's private collection")
    assert_text '3 images successfully stored'

    collection.reload
    assert_equal collection.created_at, ca
    assert collection.updated_at > ua
  end

  test 'add several images to a new collection at once' do
    login_as 'jdoe'

    fill_in 'search_value_0', with: 'baum'
    find('.search_query .submit_button').click

    results = all('.list_row')
    results[0..2].each do |r|
      r.find('input[type=checkbox]').click
    end

    find('.store_controls.position-top .button_middle').click
    find('.button_middle', text: 'New Collection').click

    fill_in 'Title', with: 'my collection'
    submit

    assert_text '3 images successfully stored'
    assert_text 'Advanced search'
  end

  test 'try to add upload to a public collection' do
    login_as 'jdoe'
    click_on "Uploads"

    results = all('.list_row').first.find('input[type=checkbox]').click

    find('div.store_image').click
    #debugger
    assert_text "This image of your database is not available to public collections until approval of the prometheus office."
    # select("John's public collection")
    # assert_text 'Unapproved uploads cannot be added to publicly visible collections'
    # assert !Collection.find_by(title: 'Johņ\'s public collection').images.include?(Upload.find_by(title: 'A upload'))
  end
  
  test 'remove image from collaboration collection' do
    collection = Collection.find_by!(title: "John's private collection")
    collection.images << Upload.first.image
    Upload.first.update_column :approved_record, true
    mrossi = Account.find_by! login: 'mrossi'
    collection.collaborators << mrossi
    collection.update_column :public_access, 'write'
    
    login_as 'mrossi'
    click_on 'Collections'
    click_on 'Shared with you'
    click_on "John's private collection"
    accept_confirm do
      click_on "Delete image from collection"
    end
    assert_text 'Image successfully removed from collection'
    
    collection.images << Upload.first.image
    click_on 'Shared with you'
  end
  
  test 'remove image from shared collection' do
    collection = Collection.find_by!(title: "John's private collection")
    collection.images << Upload.first.image
    Upload.first.update_column :approved_record, true
    mrossi = Account.find_by! login: 'mrossi'
    collection.update_column :public_access, 'write'
    
    login_as 'mrossi'
    click_on 'Collections'
    click_on 'Public'
    click_on "John's private collection"
    accept_confirm do
      click_on "Delete image from collection"
    end
    assert_text 'Image successfully removed from collection'
  end

  test 'edit a collection' do
    collection = Collection.find_by!(title: "John's private collection")
    collection.images << Upload.first.image
    Upload.first.update_column :approved_record, true
    ca = collection.created_at
    ua = collection.updated_at

    login_as 'jdoe'

    click_on 'Collections'
    click_on "John's private collection"
    click_on 'Edit'
    fill_in 'Description', with: 'something different'
    choose 'Writable'
    submit
    assert_text "Collection 'John's private collection' successfully updated!"
    assert_text 'something different'
    assert_text 'Publicly writable'

    collection.reload
    assert_equal collection.created_at, ca
    assert collection.updated_at > ua
    assert_equal 1, collection.images.count
  end

  test 'change thumbnail' do
    with_real_images do
      leonardo = create_upload 'leonardo'
      mona_lisa = Upload.find_by! title: 'A upload'
      c = Collection.find_by! title: "John's private collection"
      c.images << leonardo.image
      c.images << mona_lisa.image

      login_as 'jdoe'

      click_on 'Collections'
      base64 = RackImages::Resizer.encode64(leonardo.image_id)
      assert_match base64, find('.list tr:nth-child(2) .thumbnail img')['src']

      click_on "John's private collection"
      click_on 'Edit'
      find("img[title='Jean-Baptiste Dupont: A upload (Köln)']").click
      submit 'Save'

      click_on 'Collections'
      base64 = RackImages::Resizer.encode64(mona_lisa.image_id)
      assert_match base64, find('.list tr:nth-child(2) .thumbnail img')['src']
    end
  end

  test 'add collaborators to a private collection' do
    login_as 'jdoe'

    click_on 'Collections'
    click_on "John's private collection"
    click_on 'Edit'

    sleep 2 # we need to wait so the js event handler gets attached to the element
    open_section 'details'
    fill_in 'Viewers', with: 'mrossi', wait: 5
    fill_in 'Collaborators', with: 'mrossi'
    submit
    
    # should have generated notification to mrossi
    mail = ActionMailer::Base.deliveries.first
    assert_match /Added as collaborator/, mail.subject
    assert_equal ['mrossi@prometheus-bildarchiv.de'], mail.to

    logout

    login_as 'mrossi'
    click_on 'Collections'
    click_submenu 'Shared with you'

    # first go to jdoe's profile page to verify that the shared collection is
    # rendered
    click_on 'John Doe'
    assert_text '2 public collection'
    assert_text '1 shared collection'
    back
    assert_text 'Search shared collections'

    assert_text "John's private collection"
    assert_text 'Writable'

    logout

    login_as 'jdoe'
    click_on 'Collections'
    click_on "John's private collection"
    click_on 'Edit'
    open_section 'details'
    fill_in 'Collaborators', with: 'mrossi'
    submit

    logout

    login_as 'mrossi'
    click_on 'Collections'
    click_submenu 'Shared with you'
    assert_text "John's private collection"
    assert_text 'Writable'
    
    logout
    
    login_as 'jdoe'
    click_on 'Collections'
    within 'tr.list_row', text: /John's private collection/ do
      click_on 'Edit'
    end
    sleep 2 # we need to wait so the js event handler gets attached to the element
    open_section 'details'
    fill_in 'Collaborators', with: ''
    submit
    
    # should have generated notification to mrossi
    mail = ActionMailer::Base.deliveries[1]
    assert_match /Removed as collaborator/, mail.subject
    assert_equal ['mrossi@prometheus-bildarchiv.de'], mail.to
  end

  test 'add non-existing collaborator or viewer to collection' do
    login_as 'jdoe'
    click_on 'Collections'
    click_on "John's private collection"
    click_on 'Edit'

    open_section 'details'
    fill_in 'Viewers', with: 'Dr. Oetker'
    fill_in 'Collaborators', with: 'Dr. Martens'
    submit

    assert_text 'Viewers -- some users were invalid or could not be found: Dr. Oetker', wait: 5
    assert_text 'Collaborators -- some users were invalid or could not be found: Dr. Martens'
  end

  test 'delete a collection' do
    login_as 'jdoe'

    click_on 'Collections'
    click_on "John's private collection"
    accept_confirm do
      click_on 'Delete'
    end
    assert_text "successfully deleted!", wait: 5
  end

  test 'sort collection images' do
    leonardo = create_upload 'leonardo', approved_record: true
    mona_lisa = Upload.find_by! title: 'A upload'
    mona_lisa.update_attributes approved_record: true
    c = Collection.find_by! title: "John's private collection"
    c.images << leonardo.image
    c.images << mona_lisa.image

    login_as 'jdoe'

    click_on 'Collections'
    click_on "John's private collection"

    all(:field, name: 'order').first.select 'Insertion order'
    assert has_link?('Sort ascending')
    within '.list_row:first-child' do
      assert find('div.image a img[title="Jean-Baptiste Dupont: A upload, Köln"]')
    end
    all(:field, name: 'order').first.select 'Artist'
    assert has_link?('Sort descending')
    all(:field, name: 'order').first.select 'Title'
    assert has_link?('Sort descending')
    all(:field, name: 'order').first.select 'Location'
    assert has_link?('Sort descending')
    all(:field, name: 'order').first.select 'Credits'
    assert has_link?('Sort descending')
    all(:field, name: 'order').first.select 'Source title'
    assert has_link?('Sort descending')
    all(:field, name: 'order').first.select 'Rating average'
    assert has_link?('Sort descending')
    all(:field, name: 'order').first.select 'Rating count'
    assert has_link?('Sort descending')
    all(:field, name: 'order').first.select 'Comments'
    assert has_link?('Sort descending')
    # no error is good
  end

  test 'show correct collection counts in profile' do
    mrossi = Account.find_by!(login: 'mrossi')
    collection = Collection.find_by!(title: "John's private collection")
    collection.collaborators << mrossi

    login_as 'jdoe'
    within '#statusbar' do
      click_on 'John Doe'
    end
    click_on('2 public collection')
    assert_text "John's collaboration collection"
    assert_text "John's public collection"
    assert_no_text "John's private collection"
    back

    login_as 'mrossi'
    visit 'en/accounts/jdoe'
    assert_css 'a', text: /2 public collection/
    click_on '1 shared collection'
    assert_no_text "John's collaboration collection"
    assert_no_text "John's public collection"
    assert_text "John's private collection"

    within '#statusbar' do
      click_on 'Mario Rossi'
    end
    assert_no_text /\d+ public collection/
    assert_no_text /\d+ shared collection/
  end

  test 'adhere to user settings for per_page defaults' do
    jdoe = Account.find_by!(login: 'jdoe')
    jdoe.collection_settings = CollectionSettings.new(per_page: 20)
    collection = Collection.find_by!(title: "John's private collection")
    upload = Upload.first
    upload.update_attributes approved_record: true
    collection.images << upload.image
    login_as 'jdoe'

    click_on 'Collections'
    click_on "John's private collection"
    within '.list_controls:first-child' do
      assert_field 'per_page', with: '20'
    end
  end

  test 'add several images to a collection at the same time' do
    login_as 'jdoe'

    fill_in 'search_value_0', with: 'baum'
    find('.search_query .submit_button').click

    find('.list_row:nth-child(1) .image_list_item').click
    find('.list_row:nth-child(2) .image_list_item').click

    find('div.store_controls.position-top .button_middle', text: 'Store images in...').click
    select "John's collaboration collection", from: 'own_collections_selector'
    assert_text "2 images successfully stored in collection 'John's collaboration collection'"
  end

  test "using viewer/collaborator autocomplete shouldn't lead to login" do
    login_as 'jdoe'

    click_on 'Collections'
    click_on 'Create a new collection'

    fill_in 'Title', with: 'my collection'
    fill_in 'Collaborators', with: 'superadmin'

    # the above collaborator tests click the submit button before the ajax
    # request can return and trigger the redirect to the login page
    assert_no_text "You don't have privileges"

    submit
    assert 'successfully created'
  end

  test 'use upload as thumbnail, then delete it' do
    collection = Collection.find_by!(title: "John's private collection")
    collection.images << Upload.first.image
    Upload.first.update_column :approved_record, true

    assert_equal collection.thumbnail_id, Upload.first.image_id

    login_as 'jdoe'

    click_on 'My Uploads'
    accept_confirm do
      click_on 'Delete image from database'
    end
    assert_text 'Upload successfully deleted'

    click_on 'Collections'
    click_on "John's private collection"
    within '#images-section' do
      assert_text 'none'
    end
  end

  test 'keyword links' do
    priv = Collection.find_by!(title: "John's private collection")
    priv.update_attributes(
      keyword_list: "gold\nsilver"
    )

    pub = Collection.find_by!(title: "John's public collection")
    pub.update_attributes(
      keyword_list: 'gold'
    )

    login_as 'jdoe'

    click_on 'Collections'
    click_on 'silver'

    assert_text 'Search own collections'
    assert_text "John's private collection"
    assert_no_text "John's public collection"
    assert_no_text "John's collaboration collection"

    click_on 'Collections'
    all(:link, 'gold').first.click
    assert_text 'Search own collections'
    assert_text "John's private collection"
    assert_text "John's public collection"
    assert_no_text "John's collaboration collection"

    click_on 'Public'
    click_on 'gold'
    assert_text 'Search public collections'
    assert_no_text "John's private collection"
    assert_text "John's public collection"
    assert_no_text "John's collaboration collection"
  end
  
  test 'non-existing pages' do
    collection = Collection.find_by!(title: "John's private collection")
    collection.images << Upload.first.image
    Upload.first.update_column :approved_record, true

    login_as 'jdoe'
    click_on 'Collections'
    click_on "John's private collection"
    lc = all('.list_controls').first
    lc.fill_in 'page', with: "2\n"
    # shouldn't throw an error
  end

  test 'add unapproved upload to collections' do
    jdoe = Account.find_by(login: "jdoe")
    mrossi = Account.find_by(login: "mrossi")

    shared_by_collection = Collection.create!({
      title: "John's shared collection",
      description: 'shared by John with Mario',
      viewers: [mrossi],
      collaborators: [mrossi],
      owner: jdoe
    }, without_protection: true)

    login_as 'jdoe'
    click_on 'Uploads'
    find(:xpath, "//div[@data-upload-id=1]").find("div.store_image").click
    within 'div.store_images.popup' do
      select "John's private collection", from: 'own_collections_selector'
    end
    assert_text "Image successfully stored in collection 'John's private collection'"
    click_on 'Collections'
    click_on 'Own'
    click_on "John's private collection"
    assert_text "1 Image"
    assert find('div.image a img[title="Jean-Baptiste Dupont: A upload, Köln"]')

    click_on 'Uploads'
    find(:xpath, "//div[@data-upload-id=1]").find("div.store_image").click
    assert_text "This image of your database is not available to public collections until approval of the prometheus office."
  end
end
