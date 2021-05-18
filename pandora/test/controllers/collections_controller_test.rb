require 'test_helper'

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  test 'ipuser: redirect to login' do
    campus_login

    get '/en/collections'
    assert_redirected_to login_path

    get '/en/collections/1'
    assert_redirected_to login_path
  end

  test 'dbuser: redirect to login' do
    source = Source.find_by!(name: 'robertin')
    source.update_attributes open_access: true

    db_login 'robertin'

    get '/en/collections'
    assert_redirected_to login_path(return_to: collections_url)

    get '/en/collections/1'
    assert_redirected_to login_path(return_to: collection_url(1))
  end

  test 'useradmin: redirect to login' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.roles = Role.where(title: ['useradmin'])

    login_as 'jdoe'

    get '/en/collections'
    assert_redirected_to login_path

    get '/en/collections/1'
    assert_redirected_to login_path
  end

  test 'user: view and download publicly readable' do
    pub = Collection.find_by! title: "John's public collection"

    login_as 'mrossi'

    get collection_path(pub)
    assert_response :success

    get download_collection_path(pub)
    assert_response :success

    patch collection_path(pub), params: {collection: {title: 'new title'}}
    assert_redirected_to login_path

    delete collection_path(pub)
    assert_redirected_to login_path

    pid = 'robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc'
    post store_collections_path(id: pub.id), params: {image: [pid]}
    assert_redirected_to login_path

    post remove_collection_path(pub), params: {image: [pid]}
    assert_redirected_to login_path
  end

  if production_sources_available?
    test 'user: view, download, store, remove for publicly writable' do
      pub = Collection.find_by! title: "John's collaboration collection"

      login_as 'mrossi'

      get collection_path(pub)
      assert_response :success

      get download_collection_path(pub)
      assert_response :success

      patch collection_path(pub), params: {collection: {
        title: 'new title',
        thumbnail_id: 15,
        public_access: 'read',
        collaborator_list: 'mrossi'
      }}
      assert_redirected_to collection_path(pub)
      # should work but the title and thumbnail shouldn't be changeable (see #796)
      assert_equal "John's collaboration collection", pub.reload.title
      assert_nil pub.reload.thumbnail_id
      assert_equal 'write', pub.reload.public_access
      assert_equal '', pub.reload.collaborator_list

      delete collection_path(pub)
      assert_redirected_to login_path

      pid = 'robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc'
      post store_collections_path(id: pub.id), params: {image: [pid]}
      assert_redirected_to searches_path
      assert_equal 1, pub.reload.images.count

      post remove_collection_path(pub), params: {image: [pid]}
      assert_redirected_to collection_path(pub)
      assert_equal 0, pub.reload.images.count
    end
  end

  test "admin: redirect to login for non-owned" do
    mrossi = Account.find_by! login: 'mrossi'
    mrossi.roles = Role.where(title: ['admin', 'user'])
    priv = Collection.find_by! title: "John's private collection"

    login_as 'mrossi'

    get collection_path(priv)
    assert_redirected_to login_path
  end

  test 'viewer: view and download' do
    mrossi = Account.find_by! login: 'mrossi'
    priv = Collection.find_by! title: "John's private collection"
    priv.viewers << mrossi

    login_as 'mrossi'

    get collection_path(priv)
    assert_response :success

    get download_collection_path(priv)
    assert_response :success

    patch collection_path(priv), params: {collection: {title: 'new title'}}
    assert_redirected_to login_path

    delete collection_path(priv)
    assert_redirected_to login_path

    pid = 'robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc'
    post store_collections_path(id: priv.id), params: {image: [pid]}
    assert_redirected_to login_path

    post remove_collection_path(priv), params: {image: [pid]}
    assert_redirected_to login_path
  end

  if production_sources_available?
    test 'collaborator: view, download, store, remove' do
      mrossi = Account.find_by! login: 'mrossi'
      priv = Collection.find_by! title: "John's private collection"
      priv.collaborators << mrossi

      login_as 'mrossi'

      get collection_path(priv)
      assert_response :success

      get download_collection_path(priv)
      assert_response :success

      patch collection_path(priv), params: {collection: {
        title: 'new title',
        thumbnail_id: 15,
        public_access: 'read',
        viewer_list: 'mrossi'
      }}
      assert_redirected_to collection_path(priv)
      # should work but the title and thumbnail shouldn't be changeable (see #796)
      assert_equal "John's private collection", priv.reload.title
      assert_nil priv.reload.thumbnail_id
      assert_nil priv.reload.public_access
      assert_equal '', priv.reload.viewer_list

      delete collection_path(priv)
      assert_redirected_to login_path

      pid = 'robertin-f96840893b1b89d486ade4ed4aa1d907e4eb20dc'
      post store_collections_path(id: priv.id), params: {image: [pid]}
      assert_redirected_to searches_path
      assert_equal 1, priv.reload.images.count

      post remove_collection_path(priv), params: {image: [pid]}
      assert_redirected_to collection_path(priv)
      assert_equal 0, priv.reload.images.count
    end
  end

  test 'user: share own' do
    priv = Collection.find_by! title: "John's private collection"

    login_as 'jdoe'

    patch collection_path(priv), params: {collection: {
      title: 'new title',
      thumbnail_id: 15,
      public_access: 'read',
      viewer_list: 'mrossi',
      collaborator_list: 'jdupont'
    }}
    assert_equal 'new title', priv.reload.title
    assert_equal '15', priv.reload.thumbnail_id
    assert_equal 'read', priv.reload.public_access
    assert_equal 'mrossi', priv.reload.viewer_list
    assert_equal 'jdupont', priv.reload.collaborator_list
  end

  test 'unapproved uploads' do
    priv = Collection.find_by! title: "John's private collection"
    pub = Collection.find_by! title: "John's public collection"
    collab = Collection.find_by! title: "John's collaboration collection"
    upload = Upload.first
    upload.update_attributes approved_record: false
    pid = Upload.first.image.pid

    login_as 'jdoe'

    # add unapproved upload to private collection: should work
    post store_collections_path(id: priv.id), params: {image: [pid]}
    assert_redirected_to searches_path
    assert_equal 1, priv.reload.images.count

    # add unapproved upload to public collection: shouldn't work
    post store_collections_path(id: pub.id), params: {image: [pid]}
    assert_redirected_to searches_path
    assert_equal 0, pub.reload.images.count

    # add unapproved upload to shared collection: shouldn't work
    post store_collections_path(id: collab.id), params: {image: [pid]}
    assert_redirected_to searches_path
    assert_equal 0, collab.reload.images.count

    # share private collection with unapproved upload: shouldn't work
    patch collection_path(priv), params: {collection: {viewer_list: 'mrossi'}}
    assert_equal 422, response.status
    assert_empty priv.reload.viewers

    # make private collection with unapproved upload public: shouldn't work
    patch collection_path(priv), params: {collection: {public_access: 'read'}}
    assert_equal 422, response.status
    assert_nil priv.reload.public_access
  end

  test 'use only string when adding image to collection' do
    priv = Collection.find_by! title: "John's private collection"
    upload = Upload.first
    pid = Upload.first.image.pid
    
    login_as 'jdoe'

    post store_collections_path(id: priv.id), params: {image: pid}
    assert_redirected_to searches_path
    assert_equal 1, priv.reload.images.count
  end

  test 'no exception when neither image(s) nor collection are given' do
    login_as 'jdoe'

    post store_collections_path
    assert_redirected_to searches_path
    assert_equal 'Please select images to store in this collection!', flash[:warning]
  end

  test 'search by owner' do
    login_as 'superadmin'

    get public_collections_path, params: {field: 'owner', value: 'jdoe'}
    # jdoe has two public collections
    assert_equal 2, css_select('table.list > tr').count

    get public_collections_path, params: {field: 'owner', value: 'john'}
    # there is also "John Expired" who has a public collection
    assert_equal 3, css_select('table.list > tr').count

    get public_collections_path, params: {field: 'owner', value: 'doe'}
    assert_equal 2, css_select('table.list > tr').count
  end

  test 'suggest unused keyword' do
    login_as 'jdoe'

    Keyword.create! title: 'cold'

    post '/en/collections/suggest_keywords', params: {terms: 'old'}
    assert response.successful?
  end

  # test 'user: share own with self'
end
