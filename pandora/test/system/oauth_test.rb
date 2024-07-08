# require 'test_helper'

require "application_system_test_case"

class OAuthTest < ApplicationSystemTestCase
  def setup
    # post, get etc. were removed from rails so we need some other way to do
    # back channel requests
    @faraday = Faraday.new 'http://127.0.0.1:47001' do |builder|
      builder.use :cookie_jar
      builder.adapter Faraday.default_adapter
    end

    super
  end

  def get(url, params = nil)
    @response = @faraday.get(url, params)
  end

  def post(url, headers = {})
    @response = @faraday.post url do |r|
      r.headers.update(headers)
    end
  end

  def assert_redirected_to(path)
    assert redirect?

    actual_path = URI.parse(@response.headers['location']).path
    assert_match path, actual_path
  end

  def response_successful?
    @response.success?
  end

  def redirect?
    assert_equal 302, @response.status
  end

  test 'json format flow' do
    TestSource.index

    sp = 'http://127.0.0.1:47001'
    c = 'http://app.example.com/oauth/callback'
    consumer = OAuth::Consumer.new('somekey', 'somesecret', :site => sp)

    # we request the request_token with which we can calculate the authorize url
    # for the next step
    request_token = consumer.get_request_token(oauth_callback: c)
    authorize_url = request_token.authorize_url(oauth_callback: c)

    # In general, the authorize url doesn't yield any information but it activates the
    # request token within pandora (the token thereby gets associated with jdoe,
    # since he is current_user)

    # we try to go to the url without authentication, it shouldn't work, both
    # with html or json we receive the appropriate answer from pandora
    post authorize_url
    assert_redirected_to /\/en\/login/
    post authorize_url, {'accept' => 'application/json'}
    assert_equal 401, @response.status

    # we use jdoe (requesting json, because the html format would depend on
    # session)
    post authorize_url, api_auth('jdoe').merge('accept' => 'application/json')
    assert response_successful?
    verifier = JSON.parse(@response.body)['oauth_verifier']
    assert_not_equal 'authorize failure', verifier

    # we finally get our access token
    access_token = request_token.get_access_token oauth_verifier: verifier

    # so we make a test request (first without the access token)
    res = consumer.request(:get, '/api/json/collection/own')
    assert_equal '401', res.code

    # ... then we include it
    res = consumer.request(:get, '/api/json/collection/own', access_token)
    assert_equal '200', res.code
    assert_equal 3, JSON.parse(res.body).count

    # search index request
    system 'touch', '/tmp/x'
    res = consumer.request(:get, "/api/json/search/search/?term=Stuhl&per_page=100", access_token)
    res_json = JSON.parse(res.body)
    assert_equal '200', res.code
    assert_equal 12, res_json.count

    res = consumer.request(:get, "/api/json/search/index/?term=Stuhl&per_page=100", access_token)
    res_json = JSON.parse(res.body)
    assert_equal 12, res_json.count

    # upload index request
    res = consumer.request(:get, "/api/json/upload/list", access_token)
    res_json = JSON.parse(res.body)
    assert_equal 1, res_json['uploads'].count

    res = consumer.request(:get, "/api/json/upload/index", access_token)
    res_json = JSON.parse(res.body)
    assert_equal 1, res_json['uploads'].count

    without_forgery_protection do
      # now we try a POST request
      data = {collection: {title: 'My Collection'}}
      res = consumer.request(:post, '/api/json/collection/create?', access_token, {}, data)
      assert_equal '200', res.code
      assert_equal 'My Collection', Collection.find(JSON.parse(res.body)['id']).title

      # and another request
      res = consumer.request(
        :post,
        '/api/json/collection/create?collection%5Bpublic_access%5D=&collection%5Btitle%5D=Testwebapp',
        access_token, {}, data
      )
      assert_equal '200', res.code
      assert_equal 'Testwebapp', Collection.find(JSON.parse(res.body)['id']).title

      # we need to support the trailing slash for now
      res = consumer.request(
        :post,
        '/api/json/collection/create/?collection%5Bpublic_access%5D=&collection%5Btitle%5D=Another',
        access_token, {}, data
      )
      assert_equal '200', res.code
      assert_equal 'Another', Collection.find(JSON.parse(res.body)['id']).title
    end

    # and another request
    id = pid_for(1)
    res = consumer.request(:get, "/api/blob/image/large/#{id}", access_token)
    assert_equal '200', res.code

    # different ImageMagick versions produce different file sizes, so we just
    # make a rough check
    assert res.body.size > 15000

    # now lets try revoking it (we are still logged in as jdoe)
    get "/oauth/revoke", {token: access_token.token}
    assert redirect?

    # access should subsequently not be granted anymore
    res = consumer.request(:get, '/api/json/collection/own', access_token)
    assert_equal '401', res.code
  end

  test 'works with /pandora prefix' do
    TestSource.index

    sp = 'http://127.0.0.1:47001/pandora'
    c = 'http://app.example.com/oauth/callback'
    consumer = OAuth::Consumer.new('somekey', 'somesecret', :site => sp)

    # we request the request_token with which we can calculate the authorize url
    # for the next step
    request_token = consumer.get_request_token oauth_callback: c
    authorize_url = request_token.authorize_url(oauth_callback: c)

    # In general, the authorize url doesn't yield any information but it activates the
    # request token within pandora (the token thereby gets associated with jdoe,
    # since he is current_user)

    # we try to go to the url without authentication, it shouldn't work, both
    # with html or json we receive the appropriate answer from pandora
    post authorize_url
    assert_redirected_to /\/en\/login/
    post authorize_url, {'accept' => 'application/json'}
    assert_equal 401, @response.status

    # we use jdoe (requesting json, because the html format would depend on
    # session)
    post authorize_url, api_auth('jdoe').merge('accept' => 'application/json')
    assert response_successful?
    verifier = JSON.parse(@response.body)['oauth_verifier']
    assert_not_equal 'authorize failure', verifier

    # we finally get our access token
    access_token = request_token.get_access_token oauth_verifier: verifier

    # so we make a test request (first without the access token)
    res = consumer.request(:get, '/api/json/collection/own')
    assert_equal '401', res.code

    # ... then we include it
    res = consumer.request(:get, '/api/json/collection/own', access_token)
    assert_equal 3, JSON.parse(res.body).count

    # search request
    res = consumer.request(:get, "/api/json/search/search/?term=Stuhl&per_page=100", access_token)
    res_json = JSON.parse(res.body)
    assert_equal 12, res_json.count

    res = consumer.request(:get, "/api/json/search/index/?term=Stuhl&per_page=100", access_token)
    res_json = JSON.parse(res.body)
    assert_equal 12, res_json.count

    # upload index request
    res = consumer.request(:get, "/api/json/upload/list", access_token)
    res_json = JSON.parse(res.body)
    assert_equal 1, res_json['uploads'].count

    res = consumer.request(:get, "/api/json/upload/index", access_token)
    res_json = JSON.parse(res.body)
    assert_equal 1, res_json['uploads'].count

    # and another request
    id = pid_for(1)
    res = consumer.request(:get, "/api/blob/image/large/#{id}", access_token)
    assert_equal '200', res.code
    # different ImageMagick versions produce different file sizes, so we just
    # make a rough check
    assert res.body.size > 15000

    # now lets try revoking it (we are still logged in as jdoe)
    get "#{sp}/oauth/revoke", {token: access_token.token}
    assert redirect?

    # access should subsequently not be granted anymore
    res = consumer.request(:get, '/api/json/collection/own', access_token)
    assert_equal '401', res.code
  end

  # just for documentation, this is the manual way of doing a test request
  # req = Net::HTTP::Get.new('/api/json/account/show')
  # helper = OAuth::Client::Helper.new(req,
  #   request_uri: "#{sp}/api/json/account/show",
  #   consumer: consumer,
  #   token: access_token
  # )

  # Net::HTTP.start '127.0.0.1', 47001 do |http|
  #   response = http.request(req)
  #   assert_equal '401', response.code

  #   req['Authorization'] = helper.header
  #   response = http.request(req)
  #   assert_equal 'Doe', JSON.parse(response.body)['lastname']
  # end
end
