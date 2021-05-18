require 'test_helper'

class PowerPointRequestTest < ActionDispatch::IntegrationTest
  test 'not logged in' do
    collection = Collection.find_by! title: "John's private collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_redirected_to /\/en\/login/

    collection = Collection.find_by! title: "John's public collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_redirected_to /\/en\/login/

    collection = Collection.find_by! title: "John's collaboration collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_redirected_to /\/en\/login/
  end

  test 'logged in as user, foreign private collection' do
    login_as 'mrossi'

    collection = Collection.find_by! title: "John's private collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_redirected_to /\/en\/login/
  end

  test 'logged in as user, foreign shared collection (ro)' do
    login_as 'mrossi'

    collection = Collection.find_by! title: "John's private collection"
    mrossi = Account.find_by! login: 'mrossi'
    collection.viewers << mrossi
    get "/en/powerpoint/collection/#{collection.id}"
    assert_response :success
  end

  test 'logged in as user, foreign shared collection (rw)' do
    login_as 'mrossi'

    collection = Collection.find_by! title: "John's private collection"
    mrossi = Account.find_by! login: 'mrossi'
    collection.collaborators << mrossi
    get "/en/powerpoint/collection/#{collection.id}"
    assert_response :success
  end

  test 'logged in as user, own private collection' do
    login_as 'jdoe'

    collection = Collection.find_by! title: "John's private collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_response :success
  end

  test 'logged in as user, public collection (ro)' do
    login_as 'mrossi'

    collection = Collection.find_by! title: "John's public collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_response :success
  end

  test 'logged in as user, public collection (rw)' do
    login_as 'mrossi'

    collection = Collection.find_by! title: "John's collaboration collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_response :success
  end

  test 'logged in as admin, private collection' do
    login_as 'jnadie'
    
    collection = Collection.find_by! title: "John's private collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_redirected_to /\/en\/login/
  end

  test 'logged in as ipuser, public collection (ro)' do
    campus_login

    collection = Collection.find_by! title: "John's public collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_response :success
  end

  test 'logged in as ipuser, public collection (rw)' do
    campus_login

    collection = Collection.find_by! title: "John's collaboration collection"
    get "/en/powerpoint/collection/#{collection.id}"
    assert_response :success
  end

  test 'content type and filename' do
    login_as 'jdoe'

    collection = Collection.find_by! title: "John's private collection"
    get "/en/powerpoint/collection/#{collection.id}"

    assert_equal 'application/vnd.openxmlformats-officedocument.presentationml.presentation', response.content_type
    assert_match 'attachment', response.headers['content-disposition']
    assert_match 'filename="presentation.pptx"', response.headers['content-disposition']
  end
end
