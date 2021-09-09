require 'test_helper'
require 'rest-client'
require 'json'
require 'io/console'

class ApiTest < ActionDispatch::IntegrationTest

  # examples

  test 'wadl de' do
    get '/de/pandora.wadl'
    assert response.successful?
    assert_equal 'http://www.example.com/', xml['application']['resources']['base']

    # test wrong content type
    get '/en/pandora.wadl', headers: {'accept' => 'text/html'}
    assert_response :success
    assert_equal "application/xml", response.content_type
  end

  test 'upload listing' do
    get '/api/json/upload/list'
    assert_equal 401, response.status

    get '/api/xml/upload/list'
    assert_equal 401, response.status

    get '/api/json/upload/list', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 1, json['uploads'].size

    get '/api/xml/upload/list', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 1, xml['uploads'].size
  end

  test 'basic information' do
    get '/api/v1/json/about'
    assert response.successful?
    assert_match /\d+ Databases/, json['facts'][1]

    get '/api/v1/xml/about'
    assert response.successful?
    assert_match /\d+ Databases/, xml['pandora']['facts'][1]
  end

  if production_sources_available?
    test 'counts' do
      get '/api/v1/json/search/hits', params: {term: 'tree'}
      assert response.successful?
      assert json['count'] > 0

      get '/api/v1/xml/search/hits', params: {term: 'tree'}
      assert response.successful?
      assert xml['hits']['count'] > 0
    end

    test 'search' do
      get '/api/json/search/search', params: {s: ['robertin'], term: 'baum'}
      assert_equal 401, response.status

      get '/api/xml/search/search', params: {s: ['robertin'], term: 'baum'}
      assert_equal 401, response.status

      get '/api/json/search/search', params: {s: ['robertin'], term: 'baum'}, headers: api_auth('jdoe')
      assert response.successful?
      assert json.size > 0

      # see #398
      get '/api/xml/search/search', params: {s: ['robertin'], term: 'baum'}, headers: api_auth('jdoe')
      assert response.successful?
      assert xml['objects'].size > 0

      # see #1233
      jdoe = Account.find_by! login: 'jdoe'
      jdoe.update_columns accepted_terms_of_use_revision: nil
      get '/api/json/search/search', headers: api_auth('jdoe')
      assert_match /Bitte akzeptieren Sie unsere Nutzungsbedingungen/, json['message']
      get '/api/xml/search/search', headers: api_auth('jdoe')
      assert_match /Bitte akzeptieren Sie unsere Nutzungsbedingungen/, xml['hash']['message']
    end
  end

  test 'image data and metadata (blob, upload)' do
    with_real_images do
      # we need to restore the upload for other test not to be affected
      restore_images_dir

      id = Upload.first.image_id

      get '/api/blob/image/medium', params: {id: id}
      assert_equal 401, response.status

      get '/api/blob/image/small', params: {id: id}, headers: api_auth('jdoe')
      assert response.redirect?
      assert_match /rack-images/, response.location
      assert_match /r140/, response.location

      get '/api/blob/image/medium', params: {id: id}, headers: api_auth('jdoe')
      assert response.redirect?
      assert_match /rack-images/, response.location
      assert_match /r400/, response.location

      get '/api/blob/image/large', params: {id: id}, headers: api_auth('jdoe')
      assert_equal 'image/jpeg', response.content_type

      get "/api/blob/image/large/#{id}", headers: api_auth('jdoe')
      assert_equal 'image/jpeg', response.content_type
    end
  end

  test 'image data with custom resolutions' do
    with_real_images do
      restore_images_dir

      # dimensions: 402x599
      id = Upload.first.image_id

      get '/api/blob/image/r440', params: {id: id}
      assert_equal 401, response.status

      # fit image into 440x440 box
      get '/api/blob/image/r440', params: {id: id}, headers: api_auth('jdoe')
      follow_redirect!
      dim = dimensions_for(response.body)
      assert_equal({width: 295, height: 440}, dim)

      # fit image into 800x800 box -> no changes
      get '/api/blob/image/r800', params: {id: id}, headers: api_auth('jdoe')
      follow_redirect!
      dim = dimensions_for(response.body)
      assert_equal({width: 402, height: 599}, dim)

      # shrink smaller side to 300
      get '/api/blob/image/r300m', params: {id: id}, headers: api_auth('jdoe')
      follow_redirect!
      dim = dimensions_for(response.body)
      assert_equal({width: 300, height: 447}, dim)

      # shrink smaller side to 500 -> no changes
      get '/api/blob/image/r500m', params: {id: id}, headers: api_auth('jdoe')
      follow_redirect!
      dim = dimensions_for(response.body)
      assert_equal({width: 402, height: 599}, dim)
    end
  end

  test "blob format doesn't bomb ApplicationController on errors" do
    id = 'artemis_bk-03e10816731d37704ce69269ef641d85a19bf92e'
    get "/api/blob/image/r448/#{id}", headers: api_auth('jdoe')
    assert_equal 404, response.status
    assert_equal 'not found', response.body
  end

  test 'image data and metadata (xml, upload)' do
    id = Upload.first.image_id

    get '/api/xml/image/show', params: {id: id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A upload', xml['image']['title']

    get "/api/xml/image/show/#{id}", headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A upload', xml['image']['title']
  end

  test 'image data and metadata (json, upload)' do
    id = Upload.first.image_id

    get '/api/json/image/show', params: {id: id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A upload', json['title']

    get "/api/json/image/show/#{id}", params: {id: id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A upload', json['title']
  end

  if production_sources_available?
    test 'image data and metadata (blob, non upload)' do
      with_real_images do
        id = 'robertin-d8f0b98afb49373f88c11a7736745a146ff5b910'

        get '/api/blob/image/medium', params: {id: id}
        assert_equal 401, response.status

        get '/api/blob/image/small', params: {id: id}, headers: api_auth('jdoe')
        assert response.redirect?
        assert_match /rack-images/, response.location
        assert_match /r140/, response.location

        get '/api/blob/image/medium', params: {id: id}, headers: api_auth('jdoe')
        assert response.redirect?
        assert_match /rack-images/, response.location
        assert_match /r400/, response.location

        get '/api/blob/image/large', params: {id: id}, headers: api_auth('jdoe')
        assert_equal 'image/jpeg', response.content_type

        get "/api/blob/image/large/#{id}", headers: api_auth('jdoe')
        assert_equal 'image/jpeg', response.content_type
      end
    end

    test 'image data and metadata (xml, non upload)' do
      id = 'robertin-1811fba6f39dfb273cad00155b6a9d87112a35dd'

      get '/api/xml/image/show', params: {id: id}, headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 'Fragment eines Kraters, griechisch, Kriegerkopf (Halle/Saale ROBERTINUM', xml['image']['descriptive_title']

      get "/api/xml/image/show/#{id}", headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 'Fragment eines Kraters, griechisch, Kriegerkopf (Halle/Saale ROBERTINUM', xml['image']['descriptive_title']
    end

    test 'image data and metadata (json, non upload)' do
      id = 'robertin-1811fba6f39dfb273cad00155b6a9d87112a35dd'

      get '/api/json/image/show', params: {id: id}, headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 'Fragment eines Kraters, griechisch, Kriegerkopf', json['title']

      get "/api/json/image/show/#{id}", params: {id: id}, headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 'Fragment eines Kraters, griechisch, Kriegerkopf', json['title']

      # JSON 404
      id = 'some-1234'
      get "/api/json/image/show/#{id}", params: {id: id}, headers: api_auth('jdoe')
      assert_equal 404, response.status
      assert_equal 'not found', json['message']

      # XML 404
      get "/api/xml/image/show/#{id}", params: {id: id}, headers: api_auth('jdoe')
      assert_equal 404, response.status
      assert_equal 'not found', xml['hash']['message']
    end
  end

  test 'create an upload' do
    params = {
      upload: {
        title: 'Mona Lisa',
        rights_work: 'some work rights',
        rights_reproduction: 'some rights',
        credits: 'some credits',
        file: fixture_file_upload('files/mona_lisa.jpg','image/jpeg')
      }
    }

    post '/api/xml/upload/create', params: params
    assert_equal 401, response.status

    post '/api/json/upload/create', params: params
    assert_equal 401, response.status

    post '/api/xml/upload/create', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 2, Account.find_by(login: 'jdoe').database.uploads.count

    post '/api/json/upload/create', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 3, Account.find_by(login: 'jdoe').database.uploads.count
  end

  test 'fetch single entry' do
    id = Upload.first.id

    get "/api/xml/upload/edit", params: {id: id}
    assert_equal 401, response.status

    get "/api/json/upload/edit", params: {id: id}
    assert_equal 401, response.status

    get "/api/xml/upload/edit", params: {id: id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A upload', xml['upload']['title']

    get "/api/json/upload/edit", params: {id: id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A upload', json['title']

    # we also test the record action
    get "/api/json/upload/#{id}", headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A upload', json['title']
  end

  test 'update upload' do
    params = {id: Upload.first.id, upload: {title: 'A new title'}}

    put '/api/xml/upload/edit', params: params
    assert_equal 401, response.status

    put '/api/json/upload/edit', params: params
    assert_equal 401, response.status

    put '/api/xml/upload/edit', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A new title', xml['upload']['title']

    put '/api/json/upload/edit', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'A new title', json['title']
  end

  test 'delete upload (xml)' do
    id = Upload.first.id

    delete "/api/xml/upload/destroy/#{id}"
    assert_equal 401, response.status

    delete "/api/xml/upload/destroy/#{id}", headers: api_auth('jdoe')
    assert response.successful?
    assert_nil Upload.find_by(id: id)
  end

  test 'delete upload (json)' do
    id = Upload.first.id

    delete "/api/json/upload/destroy/#{id}"
    assert_equal 401, response.status

    delete "/api/json/upload/destroy/#{id}", headers: api_auth('jdoe')
    assert response.successful?
    assert_nil Upload.find_by(id: id)
  end


  # docs

  test 'GET show account (json, xml)' do
    superadmin = Account.find_by(login: 'superadmin')

    get '/api/json/account/show', params: {id: superadmin.id}
    assert_equal 401, response.status

    # TODO: see https://prometheus-srv1.uni-koeln.de/redmine/issues/764
    get '/api/json/account/show', params: {id: superadmin.id}, headers: api_auth('jdoe')
    assert_equal 200, response.status

    get '/api/json/account/show'
    assert response.successful?
    assert_equal 'John', json['firstname']

    jdoe = Account.find_by(login: 'jdoe')
    get '/api/json/account/show', params: {id: jdoe.id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'John', json['firstname']

    get '/api/xml/account/show', params: {id: jdoe.id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'John', xml['account']['firstname']
  end

  test 'GET /account/terms_of_use (json, xml -> html)' do
    get '/api/json/account/terms_of_use'
    assert response.successful?
    assert_equal 'text/html', response.content_type
    assert_match /General terms/, response.body

    get '/api/xml/account/terms_of_use'
    assert response.successful?
    assert_equal 'text/html', response.content_type
    assert_match /General terms/, response.body
  end

  test 'POST /account/terms_of_use (json, xml)' do
    user = Account.find_by(login: 'jdoe')

    post '/api/json/account/terms_of_use', params: {accepted: true}
    assert_equal 401, response.status

    post '/api/xml/account/terms_of_use', params: {accepted: true}
    assert_equal 401, response.status

    user.update({accepted_terms_of_use_revision: nil}, without_protection: true)
    post '/api/json/account/terms_of_use', params: {accepted: true}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal TERMS_OF_USE_REVISION, json['accepted_terms_of_use_revision']
    assert_equal TERMS_OF_USE_REVISION, user.reload.accepted_terms_of_use_revision

    user.update({accepted_terms_of_use_revision: nil}, without_protection: true)
    post '/api/xml/account/terms_of_use', params: {accepted: true}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal TERMS_OF_USE_REVISION, xml['account']['accepted_terms_of_use_revision']
    assert_equal TERMS_OF_USE_REVISION, user.reload.accepted_terms_of_use_revision
  end

  test 'GET /announcement/current (json, xml)' do
    user = Account.find_by(login: 'jdoe')

    get '/api/json/announcement/current'
    assert response.successful?
    assert json.is_a?(Array)

    get '/api/xml/announcement/current'
    assert response.successful?
    assert_equal 0, xml['nil_classes'].size

    # we don't verify the content because athene isn't part of pandora yet and
    # therefore its difficult to ensure consistent test data
  end

  test 'POST /box/create' do
    jdoe = Account.find_by(login: 'jdoe')
    id = Image.first.id
    params = {
      box: {id: id, controller: 'images'}
    }

    post '/api/json/box/create', params: params
    assert_equal 401, response.status

    post '/api/xml/box/create', params: params
    assert_equal 401, response.status

    post '/api/json/box/create', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert json['id'] > 0
    assert_equal id, jdoe.boxes.first.image_id

    jdoe.boxes.destroy_all
    post '/api/xml/box/create', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert xml['box']['id'] > 0
    assert_equal id, jdoe.reload.boxes.first.image_id
  end

  test 'DELETE /box/delete' do
    box = Box.create!(
      ref_type: 'image',
      image: Upload.first.image,
      owner: Account.find_by(login: 'jdoe')
    )

    delete '/api/xml/box/delete', params: {id: box.id}
    assert_equal 401, response.status

    delete '/api/json/box/delete', params: {id: box.id}
    assert_equal 401, response.status

    delete '/api/xml/box/delete', params: {id: box.id}, headers: api_auth('jdoe')
    assert_equal 0, Box.count

    box = Box.create!(
      ref_type: 'image',
      image: Upload.first.image,
      owner: Account.find_by(login: 'jdoe')
    )
    delete '/api/json/box/delete', params: {id: box.id}, headers: api_auth('jdoe')
    assert_equal 0, Box.count
  end

  test 'GET /box/list' do
    box = Box.create!(
      ref_type: 'image',
      image: Upload.first.image,
      owner: Account.find_by(login: 'jdoe')
    )

    get '/api/json/box/list'
    assert_equal 200, response.status

    get '/api/xml/box/list'
    assert_equal 200, response.status

    get '/api/json/box/list', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal Upload.first.image_id, json.last['image_id']

    get '/api/xml/box/list', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal Upload.first.image_id, xml['boxes'].last['image_id']
  end

  test 'GET /facts' do
    get '/api/json/facts'
    assert response.successful?
    assert_match /^[0-9\.]+$/, json['version']

    get '/api/xml/facts'
    assert response.successful?
    assert_match /^[0-9\.]+$/, xml['pandora']['version']
  end

  test 'GET /image/display_fields' do
    get '/api/json/image/display_fields'
    assert_equal 401, response.status

    get '/api/xml/image/display_fields'
    assert_equal 401, response.status

    get '/api/json/image/display_fields', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'Artist', json['artist']

    get '/api/xml/image/display_fields', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'Artist', xml['hash']['artist']
  end

  test 'GET /source/list' do
    get '/api/json/source/list'
    assert response.successful?
    assert_equal 2, json.size

    get '/api/json/source/list', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 2, json.size
  end

  test 'POST /collection/create' do
    id = Upload.first.image_id
    params = {collection: {title: 'custom', images: [id], public_access: 'write'}}

    post '/api/json/collection/create', params: params
    assert_equal 401, response.status

    post '/api/xml/collection/create', params: params
    assert_equal 401, response.status

    post '/api/json/collection/create', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'custom', json['title']
    assert_equal 'write', json['public_access']

    post '/api/json/collection/create', params: params, headers: api_auth('jdoe')
    assert_equal 406, response.status
    assert_equal ['has already been taken'.t], json['title']

    params[:collection][:title] = 'another one'
    post '/api/xml/collection/create', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 'another one', xml['collection']['title']
  end

  test 'DELETE /collection/delete (json)' do
    id = Collection.find_by(title: "John's private collection").id

    delete '/api/json/collection/delete', params: {id: id}
    assert_equal 401, response.status

    delete '/api/json/collection/delete', params: {id: id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal id, json['id']
    assert_nil Collection.find_by(title: "John's private collection")
  end

  test 'DELETE /collection/delete (xml)' do
    id = Collection.find_by(title: "John's private collection").id

    delete '/api/xml/collection/delete', params: {id: id}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal id, xml['collection']['id'].to_i
    assert_nil Collection.find_by(title: "John's private collection")
  end

  test 'GET /collection/number_of_pages' do
    jdoe = Account.find_by! login: 'jdoe'
    10.times do |i|
      Collection.create!({
        title: "John's collection #{i}",
        description: 'only John can see it',
        owner: jdoe
      }, without_protection: true)
    end

    get '/api/json/collection/number_of_pages', params: {type: 'shared'}
    assert_equal 401, response.status

    # See #402
    get '/api/json/collection/number_of_pages', params: {type: 'own'}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 2, json['number_of_pages']

    jdoe.collection_settings.update list_per_page: 3
    get '/api/json/collection/number_of_pages', params: {type: 'own'}, headers: api_auth('jdoe')
    assert response.successful?
    # 3 results from test data, 10 from above
    assert_equal 5, json['number_of_pages']

    # see #402
    get '/api/json/collection/number_of_pages', params: {type: 'shared'}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 0, json['number_of_pages']

    get '/api/xml/collection/number_of_pages', params: {type: 'own'}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 5, xml['hash']['number_of_pages']

    # see #796#note-62
    get '/api/json/collection/number_of_pages', params: {type: 'public'}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 1, json['number_of_pages']

    get '/api/xml/collection/number_of_pages', params: {type: 'public'}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 1, xml['hash']['number_of_pages']

    # invalid type
    get '/api/json/collection/number_of_pages', params: {type: 'invalid'}, headers: api_auth('jdoe')
    assert response.not_found?

    get '/api/xml/collection/number_of_pages', params: {type: 'invalid'}, headers: api_auth('jdoe')
    assert response.not_found?
  end

  test 'GET /collection/own' do
    get '/api/json/collection/own'
    assert_equal 401, response.status

    get '/api/json/collection/own', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 3, json.size

    get '/api/json/collection/own', params: {field: 'title', value: 'collaboration'}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal "John's collaboration collection", json[0]['title']

    get '/api/xml/collection/own', params: {field: 'title', value: 'collaboration'}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal "John's collaboration collection", xml['collections'][0]['title']
  end

  # test 'GET /collection/own_all' do
  #   jdoe = Account.find_by! login: 'jdoe'
  #   # TODO: why is this necessary?
  #   jdoe.build_collection_settings
  #   jdoe.collection_settings.update list_per_page: 2

  #   get '/api/json/collection/own_all'
  #   assert_equal 401, response.status

  #   # see 407
  #   get '/api/json/collection/own_all', headers: api_auth('jdoe')
  #   assert response.successful?
  #   assert_equal 3, json.size

  #   # see 407
  #   get '/api/xml/collection/own_all', headers: api_auth('jdoe')
  #   assert response.successful?
  #   assert_equal 3, xml['collections'].size
  # end

  test 'GET /collection/public' do
    get '/api/json/collection/public'
    assert_equal 401, response.status

    get '/api/json/collection/public', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 3, json.size

    get '/api/xml/collection/public', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 3, xml['collections'].size
  end

  test 'GET /collection/shared' do
    get '/api/json/collection/shared'
    assert_equal 401, response.status

    get '/api/json/collection/shared', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 0, json.size

    # see #408
    get '/api/xml/collection/shared', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 0, xml['nil_classes'].size

    collection = Collection.find_by! title: "John's private collection"
    mrossi = Account.find_by! login: 'mrossi'
    collection.viewers << mrossi

    get '/api/json/collection/shared', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 1, json.size

    get '/api/xml/collection/shared', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 1, xml['collections'].size
  end

  test 'GET /collection/public_owners_fullname' do
    get '/api/json/collection/public_owners_fullname'
    assert_equal 401, response.status

    get '/api/json/collection/public_owners_fullname', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 2, json.size
    assert_equal 'John Doe', json[0]['fullname']

    get '/api/xml/collection/public_owners_fullname', headers: api_auth('jdoe')
    assert response.successful?
    assert_equal 2, xml['objects'].size
    assert_equal 'John Doe', xml['objects'][0]['fullname']
  end

  test 'GET /collection/shared_owners_fullname' do
    get '/api/json/collection/shared_owners_fullname'
    assert_equal 401, response.status

    collection = Collection.find_by! title: "John's private collection"
    mrossi = Account.find_by! login: 'mrossi'
    collection.viewers << mrossi

    get '/api/json/collection/shared_owners_fullname', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 1, json.size
    assert_equal 'John Doe', json[0]['fullname']

    get '/api/xml/collection/shared_owners_fullname', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 1, xml['objects'].size
    assert_equal 'John Doe', xml['objects'][0]['fullname']
  end

  test 'GET /collection/writable' do
    mrossi = Account.find_by! login: 'mrossi'
    Collection.create!({
      title: "Mario's private collection",
      description: 'only Mario can see it',
      owner: mrossi
    }, without_protection: true)

    get '/api/json/collection/writable'
    assert_equal 401, response.status

    get '/api/json/collection/writable', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 2, json.size

    collection = Collection.find_by! title: "John's private collection"
    mrossi = Account.find_by! login: 'mrossi'
    collection.collaborators << mrossi

    get '/api/json/collection/writable', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 3, json.size

    get '/api/xml/collection/writable', headers: api_auth('mrossi')
    assert response.successful?
    assert_equal 3, xml['collections'].size
  end

  test 'POST /collection/store' do
    collection = Collection.find_by! title: "John's private collection"
    image = Upload.last.image
    params = {collection: {collection_id: collection.id}, image: [image.id]}

    post '/api/json/collection/store', params: params
    assert_equal 401, response.status

    post '/api/json/collection/store', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert json.is_a?(Hash)
    collection.reload
    assert collection.images.include?(image)
    assert_equal image.pid, collection.thumbnail_id

    collection.images.delete image
    post '/api/xml/collection/store', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert xml.is_a?(Hash)
    collection.reload
    assert collection.images.include?(image)
  end

  test 'POST /collection/remove' do
    collection = Collection.find_by! title: "John's private collection"
    image = Upload.first.image
    collection.images << image
    collection.reload
    assert_equal image.pid, collection.thumbnail_id

    params = {id: collection.id, image: image.id}

    post '/api/json/collection/remove', params: params
    assert_equal 401, response.status

    post '/api/json/collection/remove', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert json.is_a?(Hash)
    collection.reload
    assert_not collection.images.include?(image)
    assert_nil collection.thumbnail_id

    collection.images << image
    post '/api/xml/collection/remove', params: params, headers: api_auth('jdoe')
    assert response.successful?
    assert xml.is_a?(Hash)
    collection.reload
    assert_not collection.images.include?(image)
    assert_nil collection.thumbnail_id
  end

  test 'GET /collection/images' do
    collection = Collection.find_by! title: "John's private collection"
    collection.images << create_upload('skull', approved_record: true).image
    collection.images << create_upload('john', approved_record: true).image
    collection.images << create_upload('rembrandt', approved_record: true).image
    collection.images << create_upload('leonardo', approved_record: true).image

    get "/api/json/collection/images/#{collection.id}", params: {per_page: 3}
    assert_equal 401, response.status

    get "/api/json/collection/images/#{collection.id}", params: {per_page: 3}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal collection.id, json['id']
    assert_equal 3, json['images'].size

    get "/api/xml/collection/images/#{collection.id}", params: {per_page: 3}, headers: api_auth('jdoe')
    assert response.successful?
    assert_equal collection.id, xml['hash']['collection']['id'].to_i

    # this seems intentional, see CollectionController#images
    assert_equal 3, xml['hash']['images'].size
  end

  if production_sources_available?
    test 'GET /image/list' do
      # see #399

      get '/api/json/image/list'
      assert_equal 422, response.status
      assert_equal 'source has to be specified', json['message']

      get '/api/json/image/list', params: {source: 'xxx'}
      assert_equal 404, response.status
      assert_equal 'source not found', json['message']

      get '/api/json/image/list', params: {source: 'daumier'}
      assert_equal 403, response.status
      assert_equal 'permission denied to read non-open access source', json['message']

      get '/api/json/image/list', params: {source: 'daumier'}, headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 10, json.size

      get '/api/json/image/list', params: {source: 'daumier', per_page: 20}, headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 20, json.size

      get '/api/xml/image/list', params: {source: 'daumier'}, headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 10, xml['strings'].size
    end

    test 'the api is also available under /pandora' do
      # we just test one call since the mechanism applies to all api routes

      get '/pandora/api/json/image/list', params: {source: 'daumier'}, headers: api_auth('jdoe')
      assert response.successful?
      assert_equal 10, json.size
    end
  end

  test 'rate limiting' do
    with_env 'PM_API_RATE_LIMIT' => '3' do
      get '/api/v1/json/about'
      assert_equal 3, response.headers['X-RateLimit-Limit']
      assert_equal 2, response.headers['X-RateLimit-Remaining']
      assert_equal 1, RateLimit.count

      get '/api/v1/json/about'
      assert_equal 1, response.headers['X-RateLimit-Remaining']

      get '/api/v1/json/about'
      assert_equal 0, response.headers['X-RateLimit-Remaining']

      get '/api/v1/json/about'
      assert_equal 503, response.status
      assert_equal 'Rate Limit Exceeded', json['message']

      travel 2.hours do
        get '/api/v1/json/about'
        assert_equal 3, response.headers['X-RateLimit-Limit']
        assert_equal 2, response.headers['X-RateLimit-Remaining']
        assert_equal 2, RateLimit.count
      end
    end
  end
end
