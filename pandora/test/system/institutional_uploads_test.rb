require "application_system_test_case"

class InstitutionalUploadsTest < ApplicationSystemTestCase
  setup do
    @jdoe = Account.find_by(login: "jdoe")
    @jdoe.roles.push(Role.find_by(title: 'dbadmin'))
    @jdoe.save!
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
    database = initialize_prometheus_institutional_uploads_database

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/galette.jpg')
    fill_in 'Title', with: 'Bal du moulin de la Galette'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'

    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus'

    assert_text "Galette"
  end

  test 'read_institutional_upload' do
    database = initialize_prometheus_institutional_uploads_database
    upload = create_institutional_upload(database, "galette", options = {})

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus'

    within "div[data-upload-id=\"#{upload.id}\"]" do
      find(:xpath, "//a[img[@id=\"#{upload.image.pid}\"]]").click
    end

    assert_text 'Rating of this image\'s reproduction quality'
  end

  test 'update institutional upload' do
    database = initialize_prometheus_institutional_uploads_database
    upload = create_institutional_upload(database, "galette", options = {})

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus'

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
    database = initialize_prometheus_institutional_uploads_database
    upload = create_institutional_upload(database, "galette", options = {})

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    find('#institutional_uploads_database').select 'Prometheus'

    within "div[data-upload-id=\"#{upload.id}\"]" do
      accept_confirm do
        click_on "Delete image from database"
      end
    end

    assert_no_text "Galette"
  end

  test 'switch between institutional user databases' do
    database1 = initialize_prometheus_institutional_uploads_database

    nowhere = Institution.find_by(name: "nowhere")
    database2 = create_institutional_upload_database(nowhere)
    database2.source_admins = [@jdoe]
    database2.save!

    prometheus = Institution.find_by(name: "prometheus")
    database3 = Source.new(
      :title       => "Prometheus 2",
      :kind        => "Institutional database",
      :type        => "upload",
      :institution => prometheus,
      :owner_id    => prometheus.id,
      :keywords    => [Keyword.ensure('Institutional Upload')],
      :quota       => Institution::DEFAULT_DATABASE_QUOTA
    )

    database3.name = "prometheus_2"
    database3.source_admins = [@jdoe]
    database3.save!

    prometheus.databases.push database3
    prometheus.save!

    login_as 'jdoe'
    click_on "My Uploads"
    click_on "Institutional"

    assert_equal(3, (options = (select = find('#institutional_uploads_database')).find_all('option')).size)
    assert_equal("Nowhere", options[0].text)
    assert_equal("Prometheus", options[1].text)
    assert_equal("Prometheus 2", options[2].text)

    select.select 'Prometheus'

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
    select.select 'Nowhere'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/john.jpg')
    fill_in 'Title', with: 'Saint John the Baptist'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'

    find(:xpath, '//a[img[@title="Back to institutional_uploads"]]').click
    assert_text 'John'

    select.select 'Prometheus 2'

    find('div.button_middle', text: 'Create new institutional upload').click
    attach_file 'File', Rails.root.join('test/fixtures/files/rembrandt.jpg')
    fill_in 'Title', with: 'Self portrait'
    select 'In the public domain', from: 'upload[license]'
    choose 'In the public domain'
    submit
    assert_text 'successfully uploaded!'

    find(:xpath, '//a[img[@title="Back to institutional_uploads"]]').click
    assert_text 'Self portrait'

    select.select 'Prometheus'
    assert_text 'Galette'
  end

  if production_sources_available?
    test 'index institutional_upload and search' do
      database = initialize_prometheus_institutional_uploads_database

      create_institutional_upload(database, "galette", options = {})

      database.index
      # It takes a short time for the index to show up in advancde search.
      sleep 1

      login_as 'jdoe'
      find_link('Advanced search').find('div').click
      within '.pm-source-list' do
        groups = all('.pm-groups .pm-header').map{|e| e.text.strip}
        assert_equal ['Institutional Databases (1/1)', 'Museum Databases (1/1)', 'Research Databases (1/1)'], groups
      end

      find('#group_Museum_databases').click
      find('#group_Research_databases').click

      fill_in 'search_value_0', with: 'Galette'
      find('.search_query .submit_button').click
      assert_text 'Galette'
      assert_text 'Prometheus, prometheus - Das verteilte digitale Bildarchiv für Forschung & Lehre'

      puts "end"
    end
  end

  test 'add institutional upload to collection (should be auto-approved)' do
    database = initialize_prometheus_institutional_uploads_database

    upload = create_institutional_upload(database, "galette", options = {})

    Collection.create!({
      title: "John's institutional uploads collection",
      description: 'John\'s institutional uploads',
      owner: @jdoe,
      keywords: [Keyword.new(title: 'institutional uploads')],
    }, without_protection: true)

    login_as 'jdoe'
    click_on 'Uploads'
    click_on 'Institutional'
    select = find('#institutional_uploads_database')
    select.select "Prometheus"

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
    @jdoe.boxes.destroy_all
    database = initialize_prometheus_institutional_uploads_database

    upload = create_institutional_upload(database, "galette", options = {})

    collection = Collection.create!({
      title: "John's institutional uploads collection",
      description: 'John\'s institutional uploads',
      owner: @jdoe,
      keywords: [Keyword.new(title: 'institutional uploads')],
    }, without_protection: true)

    collection.images.push(Pandora::SuperImage.new(upload.pid).image)
    collection.save

    login_as 'jdoe'
    click_on 'My Uploads'
    click_on 'Institutional'
    select = find('#institutional_uploads_database')
    select.select "Prometheus"
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

    within(all("div#boxes")[0]) do # why are there 2 div#boxes? couldn't find out how 2nd div is generated
      within("div#boxes div.sidebar_box:nth-child(2)") do
        assert_text "John's institutiona..."
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

    # we want to check that the uploads aren't shown in the sidebar anymore but
    # with #1211, institutional uploads are auto-approved so they remain visible

    login_as 'jdoe'

    assert has_xpath?("//div[contains(@id, 'sidebar_box-')]")
    within("div#boxes div.sidebar_box:nth-child(2)") do
      assert_text "John's institutiona..."
      assert has_css?(".thumbnail")
    end

    click_on "My Uploads"
    assert_no_match("Institutional", body)

    # we still can't access the upload via the institutional uploads controller
    visit institutional_databases_path(:locale => 'en')
    assert_text "You don't have privileges to access this institutional_uploads page. Please log in with a qualified account."
    visit "/en/image/#{upload.pid}"
    assert_no_text "You don't have privileges to access this images page. Please log in with a qualified account."

    click_on "Collections"
    within(:xpath, "//tr[td/div/a[contains(text(), \"John's institutional uploads collection\")]]") do
      assert has_css?("td.thumbnail img")
      assert_no_text "1 image (of which 0 images are visible to your user)"
    end
    
    click_on "John's institutional uploads collection"
    assert has_css?("div.thumbnail div.image img")
    assert_text "1 image"
    within('#images-section .image') do
      assert has_css?("img")
    end
  end

  test 'delete institutional user database' do
    database = initialize_prometheus_institutional_uploads_database

    upload = create_institutional_upload(database, "galette", options = {})

    collection = Collection.create!({
      title: "John's institutional uploads collection",
      description: 'John\'s institutional uploads',
      owner: @jdoe,
      keywords: [Keyword.new(title: 'institutional uploads')],
    }, without_protection: true)

    collection.images.push(Pandora::SuperImage.new(upload.pid).image)
    collection.save

    login_as 'jdoe'
    click_on 'My Uploads'
    click_on 'Institutional'
    select = find('#institutional_uploads_database')
    select.select "Prometheus"
    find("[title='Store image in...']").find(:xpath, '..').click
    click_on 'Add image to sidebar'

    within '#sidebar' do
      assert_text 'Galette'
    end

    logout

    # sources can't be deleted via GUI!
    database.destroy

    login_as 'jdoe'
    assert @jdoe.admin_sources.empty?
  end

  test 'have several admins for institutional uploads databases' do
    mrossi = Account.find_by(login: "mrossi")
    mrossi.roles.push(Role.find_by(title: 'dbadmin'))
    mrossi.save!

    prometheus = Institution.find_by(name: "prometheus")
    create_institutional_upload_database(prometheus)
    
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
    assert_equal("Prometheus", find('#institutional_uploads_database option').text)
    logout

    login_as 'mrossi'
    click_on 'My Uploads'
    click_on 'Institutional'
    assert_equal("Prometheus", find('#institutional_uploads_database option').text)
  end

  def initialize_prometheus_institutional_uploads_database
    prometheus = Institution.find_by(name: "prometheus")

    database = create_institutional_upload_database(prometheus)
    database.source_admins = [@jdoe]
    database.save!
    database
  end

  def create_institutional_upload_database(institution)
    src = Source.new(
      :title       => institution.name.titleize,
      :kind        => "Institutional database",
      :type        => "upload",
      :institution => institution,
      :owner_id    => institution.id,
      :keywords    => [Keyword.ensure('Institutional Upload')],
      :quota       => Institution::DEFAULT_DATABASE_QUOTA
    )


    src.name = institution.name
    src.save!

    institution.databases.push src
    institution.save!

    src
  end

  def create_institutional_upload(database, filename, options = {})
    options.reverse_merge!(
      database: database,
      title: filename.humanize.capitalize,
      rights_reproduction: 'None, do not use!',
      rights_work: 'None, do not use!',
      file: Rack::Test::UploadedFile.new(
        "#{Rails.root}/test/fixtures/files/#{filename}.jpg",
        'image/jpeg'
      ),
      approved_record: true
    )

    Upload.create!(options)
  end

end
