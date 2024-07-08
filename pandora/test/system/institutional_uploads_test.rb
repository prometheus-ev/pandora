require "application_system_test_case"

class InstitutionalUploadsTest < ApplicationSystemTestCase
  setup do
    u = Account.find_by(login: "jdoe")
    u.roles << Role.find_by(title: 'dbadmin')
  end

  test 'create institutional uploads database' do
    login_as 'superadmin'
    click_on 'Administration'

    section = find('h3', text: 'Source').find(:xpath, 'following-sibling::*[1]')
    section.click_on 'Create'
    fill_in 'Name', with: 'my_first_institutional_uploads_database'
    fill_in 'Title', with: 'My first institutional uploads database'
    select 'Köln, prometheus - Das verteilte ...', from: 'Institution'
    select 'Institutional database', from: 'Kind'
    select 'upload', from: 'Type'
    fill_in 'Keywords', with: 'institutional uploads database'
    select 'jdoe', from: 'source_admins'
    submit
    my_first_institutional_uploads_database = Source.find_by(name: 'my_first_institutional_uploads_database')
    assert_equal("upload", my_first_institutional_uploads_database.type)
    assert_equal("Institutional database", my_first_institutional_uploads_database.kind)
    assert (admin = my_first_institutional_uploads_database.source_admins.first)
    assert_equal("jdoe", admin.login)
  end

  test 'create institutional upload' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus, Köln'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/galette.jpg')
    fill_in 'Title', with: 'Bal du moulin de la Galette'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'


    # the source isn't auto-approving, so the index isn't populated
    doc = Upload.last.super_image.elastic_record['_source']
    assert_nil doc['title']

    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus, Köln'

    assert_text "Galette"
  end

  test 'read_institutional_upload' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])
    upload = institutional_upload(database, "galette", options = {})

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus, Köln'

    within "div[data-upload-id=\"#{upload.id}\"]" do
      find(:xpath, "//a[img[@id=\"#{upload.image.pid}\"]]").click
    end

    assert_text 'Rating of this image\'s reproduction quality'
  end

  test 'update institutional upload' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])
    upload = institutional_upload(database, "galette", options = {})

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus, Köln'

    within "div[data-upload-id=\"#{upload.id}\"]" do
      click_on "Edit upload"
    end

    fill_in 'Artist', with: 'Pierre-Auguste Renoir'
    within "#object_basic-section" do
      submit
    end
    assert_text "Object successfully updated!"

    find(:xpath, '//a[img[@title="Back to institutional_uploads"]]').click
    assert_text "Pierre-Auguste Renoir"
  end

  test 'delete institutional upload' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])
    upload = institutional_upload(database, "galette", options = {})

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus, Köln'

    within "div[data-upload-id=\"#{upload.id}\"]" do
      accept_confirm do
        click_on "Delete image from database"
      end
    end

    assert_no_text "Galette"
  end

  test 'switch between institutional user databases' do
    jdoe = Account.find_by!(login: "jdoe")
    database1 = institutional_upload_source([jdoe])

    nowhere = Institution.find_by(name: "nowhere")
    database2 = institutional_upload_source([jdoe], nowhere)

    prometheus = Institution.find_by(name: "prometheus")
    database3 = Source.new(
      title: "Prometheus 2",
      kind: "Institutional database",
      type: "upload",
      institution: prometheus,
      owner_id: prometheus.id,
      keywords: [Keyword.find_by!(title: 'institutional upload')],
      quota: Institution::DEFAULT_DATABASE_QUOTA
    )

    database3.name = "prometheus_2"
    database3.source_admins = [jdoe]
    database3.save!

    prometheus.databases.push database3
    prometheus.save!

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    assert_equal(3, (options = (select = find('#institutional_uploads_database')).find_all('option')).size)
    assert_equal("Nowhere, Nowhere", options[0].text)
    assert_equal("Prometheus, Köln", options[1].text)
    assert_equal("Prometheus 2, Köln", options[2].text)

    select.select 'Prometheus, Köln'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/galette.jpg')
    fill_in 'Title', with: 'Bal du moulin de la Galette'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'

    find(:xpath, '//a[img[@title="Back to institutional_uploads"]]').click
    assert_text 'Galette'

    # no prompt, when database is selected
    assert_equal(3, (options = (select = find('#institutional_uploads_database')).find_all('option')).size)
    select.select 'Nowhere, Nowhere'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/john.jpg')
    fill_in 'Title', with: 'Saint John the Baptist'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'

    find(:xpath, '//a[img[@title="Back to institutional_uploads"]]').click
    assert_text 'John'

    select.select 'Prometheus 2, Köln'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/rembrandt.jpg')
    fill_in 'Title', with: 'Self portrait'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'

    find(:xpath, '//a[img[@title="Back to institutional_uploads"]]').click
    assert_text 'Self portrait'

    select.select 'Prometheus, Köln'
    assert_text 'Galette'
  end

  test 'index institutional_upload and search' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])

    TestSource.index
    TestSourceSorting.index

    institutional_upload(database, "galette", options = {})

    database.index
    # It takes a short time for the index to show up in advancde search.
    sleep 1

    login_as 'jdoe'
    find_link('Advanced search').find('div').click
    within '.pm-source-list' do
      groups = all('.pm-groups .pm-header').map{|e| e.text.strip}
      assert_equal(
        [
          'Institutional Databases (1/1)',
          'Museum Databases (1/1)',
          'Research Databases (1/1)'
        ],
        groups
      )
    end

    find('#group_Museum_databases').click
    find('#group_Research_databases').click

    fill_in 'search_value_0', with: 'Galette'
    find('.search_query .submit_button').click
    assert_text 'Galette'
    assert_text 'Prometheus, prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre'

    find('div.image a img[title="Galette"]').click
    assert_link 'One'
    assert_link 'Two'
  end

  test 'add institutional upload to collection' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])

    upload = institutional_upload(database, "galette", options = {})

    Collection.create!(
      title: "John's institutional uploads collection",
      description: 'John\'s institutional uploads',
      owner: jdoe,
      keywords: [Keyword.new(title: 'institutional uploads')],
    )

    login_as 'jdoe'
    click_on 'Uploads'
    click_on 'Institutional'
    select = find('#institutional_uploads_database')
    select.select "Prometheus, Köln"

    find(:xpath, "//div[@data-upload-id=\"#{upload.id}\"]").find("div.store_image").click
    within 'div.store_images.popup' do
      select "John's institutional uploads collection", from: 'own_collections_selector'
    end
    assert_text "Image successfully stored in collection 'John's institutional uploads collection'"

    click_on "Collections"
    click_on "John's institutional uploads collection"
    assert_text "1 Image"
    assert find('div.image a img[title="Galette"]')

    click_on 'Edit'
    assert_text 'Change public access or share as soon as all your database images included in your collection are approved!'

    upload.update(approved_record: true)
    reload_page
    assert_no_text 'Change public access or share as soon as all your database images included in your collection are approved!'

    click_on "Collections"
    click_on "John's institutional uploads collection"
    click_on 'Edit'

    choose 'Readable'
    submit
    assert_text "Collection 'John's institutional uploads collection' successfully updated!"

    logout
    login_as 'mrossi'
    click_on "Collections"
    click_on "Public"

    click_on "John's institutional uploads collection"
    assert_text "1 Image"
    assert find('div.image a img[title="Galette"]')
    find('div.image a img[title="Galette"]').click
    assert "Database  Prometheus, prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre"
  end

  test 'remove dbadmin role for institutional uploads database' do
    jdoe = Account.find_by!(login: "jdoe")
    jdoe.boxes.destroy_all
    database = institutional_upload_source([jdoe])

    upload = institutional_upload(database, "galette", options = {})

    collection = Collection.create!(
      title: "John's institutional uploads collection",
      description: "John's institutional uploads",
      owner: jdoe,
      keywords: [Keyword.new(title: 'institutional uploads')]
    )

    collection.images.push(Pandora::SuperImage.new(upload.pid).image)
    collection.save

    login_as 'jdoe'
    click_on 'My Uploads'
    click_on 'Institutional'
    select = find('#institutional_uploads_database')
    select.select "Prometheus, Köln"
    find(:xpath, "//div[@data-upload-id=\"#{upload.id}\"]").find("div.store_image").click
    within 'div.store_images.popup' do
      click_on 'Add image to sidebar'
    end

    within(all("div.sidebar_box")[0]) do
      assert_text 'Galette'
    end

    click_on 'Collections'
    click_on 'John\'s institutional uploads collection'
    click_on 'Add collection to sidebar'

    within('div#boxes') do # why are there 2 div#boxes? couldn't find out how 2nd div is generated
      within("div.sidebar_box:nth-child(2)") do
        assert_text "John's institutio..."
        assert_css '.thumbnail', count: 1
      end
    end

    logout

    login_as 'superadmin'
    click_on "Administration"

    within(:xpath, '//div[h3="Source"]') do
      click_on 'List'
    end

    click_on 'Prometheus'
    click_on 'Edit'

    select = find('#source_admins')
    assert_equal("jdoe", select.text)
    select.unselect('jdoe')

    submit

    assert_text "Source 'prometheus' successfully updated!"
    logout


    login_as 'jdoe'

    # we want to check that the uploads aren't shown in the sidebar anymore
    within("div#boxes") do
      assert_no_css "a[href='/en/image/#{upload.pid}']"
    end

    click_on "My Uploads"
    assert_no_match("Institutional", body)

    # we still can't access the upload via the institutional uploads controller
    visit institutional_databases_path(:locale => 'en')
    assert_text "You don't have privileges to access this institutional_uploads page. Please log in with a qualified account."
    visit "/en/image/#{upload.pid}"
    assert_text "You don't have privileges to access this images page. Please log in with a qualified account."

    click_on "Collections"
    within(:xpath, "//tr[td/div/a[contains(text(), \"John's institutional uploads collection\")]]") do
      assert has_no_css?("td.thumbnail img")
      assert_text "1 image (of which 0 images are visible to your user)"
    end

    click_on "John's institutional uploads collection"
    assert has_no_css?("div.thumbnail div.image img")
    assert_no_text "1 image"
    within('#images-section') do
      assert_text 'none'
    end
  end

  test 'delete institutional user database' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])

    upload = institutional_upload(database, "galette", options = {})

    collection = Collection.create!(
      title: "John's institutional uploads collection",
      description: 'John\'s institutional uploads',
      owner: jdoe,
      keywords: [Keyword.new(title: 'institutional uploads')],
    )

    collection.images.push(Pandora::SuperImage.new(upload.pid).image)
    collection.save

    login_as 'jdoe'
    click_on 'My Uploads'
    click_on 'Institutional'
    select = find('#institutional_uploads_database')
    select.select "Prometheus, Köln"
    find("[title='Store image in...']").find(:xpath, '..').click
    click_on 'Add image to sidebar'

    within '#sidebar' do
      assert_text 'Galette'
    end

    logout

    # sources can't be deleted via GUI!
    database.destroy

    login_as 'jdoe'
    assert jdoe.admin_sources.empty?
  end

  test 'have several admins for institutional uploads databases' do
    mrossi = Account.find_by(login: "mrossi")
    mrossi.roles.push(Role.find_by(title: 'dbadmin'))
    mrossi.save!

    prometheus = Institution.find_by(name: "prometheus")
    institutional_upload_source([], prometheus)

    login_as 'superadmin'
    click_on "Administration"

    within(:xpath, '//div[h3="Source"]') do
      click_on 'List'
    end

    click_on 'Prometheus'
    click_on 'Edit'

    select = find('#source_admins')
    select.select('jdoe')
    select.select('mrossi')

    submit

    assert_text "Source 'prometheus' successfully updated!"
    logout

    login_as 'jdoe'
    click_on 'My Uploads'
    click_on 'Institutional'
    assert_equal("Prometheus, Köln", find('#institutional_uploads_database option').text)
    logout

    login_as 'mrossi'
    click_on 'My Uploads'
    click_on 'Institutional'
    assert_equal("Prometheus, Köln", find('#institutional_uploads_database option').text)
  end

  test 'klapsch filter' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])
    database.update_column :auto_approve_records, true

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus, Köln'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/galette.jpg')
    fill_in 'Title', with: 'Bal du moulin de la Galette'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'

    within '#object_basic-section' do
      fill_in 'Artist', with: 'Mr. klapSCH and friends'
      submit
    end

    assert_equal 1, ActionMailer::Base.deliveries.count
    mail = ActionMailer::Base.deliveries[0]
    assert_match /The upload has not been indexed/, mail.body.to_s
  end

  test 'indexing institutional uploads handles index_record_id' do
    jdoe = Account.find_by!(login: "jdoe")
    database = institutional_upload_source([jdoe])
    upload = institutional_upload(database, "galette", approved_record: true)
    upload_pid = upload.image_id
    db_pid = "#{database.name}-#{upload_pid.split('-')[1]}"

    si = Pandora::SuperImage.new(upload_pid)
    si.index_doc

    # the file should have been copied from 'upload' to 'prometheus'
    si = Pandora::SuperImage.new(db_pid)
    file = "#{ENV['PM_IMAGES_DIR']}/#{database.name}/original/#{upload_pid}.jpg"
    assert File.exist?(file)

    si = Pandora::SuperImage.new(upload_pid)
    si.remove_index_doc
    assert_not File.exist?(file)
  end
end
