require 'test_helper'

class RequestTokenTest < ActiveSupport::TestCase
  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
  end

  test "should have a token" do
    assert_not_nil @token.token
  end

  test "should have a secret" do
    assert_not_nil @token.secret
  end

  test "should not be authorized" do
    assert_not @token.authorized?
  end

  test "should not be invalidated" do
    assert_not @token.invalidated?
  end

  test "should not have a verifier" do
    assert_nil @token.verifier
  end

  test "should not be oob" do
    assert_not @token.oob?
  end
end

class RequestTokenContext01Test < ActiveSupport::TestCase
  # context: with user
  # context: with provided callback

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'http://test.com/callback'
  end

  test "[context: uc] should not be oob" do
    assert_not @token.oob?
  end

  test "should return 1.0a style to_query" do
    value = "oauth_token=#{@token.token}&oauth_token_secret=#{@token.secret}&oauth_callback_confirmed=true"
    assert_equal value, @token.to_query
  end
end

class RequestTokenContext02Test < ActiveSupport::TestCase
  # context: with user
  # context: with provided callback
  # context: authorize request

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'http://test.com/callback'
    @token.authorize! @user
  end

  test "should be authorized" do
    assert @token.authorized?
  end

  test "should have authorized at" do
    assert_not_nil @token.authorized_at
  end

  test "should have user set" do
    assert_equal @user, @token.user
  end

  test "should have verifier" do
    assert_not_nil @token.verifier
  end
end

class RequestTokenContext03Test < ActiveSupport::TestCase
  # context: with user
  # context: with provided callback
  # context: authorize request
  # context: exchange for access token

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'http://test.com/callback'
    @token.authorize! @user
    @token.provided_oauth_verifier = @token.verifier
    @access = @token.exchange!
  end

  test "should be valid" do
    assert @access.valid?
  end

  test "should not have errors" do
    assert_empty @access.errors
  end

  test "should invalidate request token" do
    assert @token.invalidated?
  end

  test "should set user on access token" do
    assert_equal @user, @access.user
  end

  test "should authorize accesstoken" do
    assert @access.authorized?
  end
end

class RequestTokenContext04Test < ActiveSupport::TestCase
  # context: with user
  # context: with provided callback
  # context: authorize request
  # context: attempt exchange with invalid verifier (OAuth 1.0a)

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'http://test.com/callback'
    @token.authorize! @user
    @value = @token.exchange!
  end

  test "should return false" do
    assert_not @value
  end

  test "should not invalidate request token" do
    assert_not @token.invalidated?
  end
end

class RequestTokenContext05Test < ActiveSupport::TestCase
  # context: with user
  # context: with provided callback
  # context: attempt exchange without authorization

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'http://test.com/callback'
    @value = @token.exchange!
  end

  test "should return false" do
    assert_not @value
  end

  test "should not invalidate request token" do
    assert_not @token.invalidated?
  end
end

class RequestTokenContext06Test < ActiveSupport::TestCase
  # context: with user
  # context: with oob callback
  # context: authorize request

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'oob'
    @token.authorize!(@user)
  end

  test "should be authorized" do
    assert @token.authorized?
  end

  test "should have authorized at" do
    assert_not_nil @token.authorized_at
  end

  test "should have user set" do
    assert_equal @user, @token.user
  end

  test "should have verifier" do
    assert_not_nil @token.verifier
  end
end

class RequestTokenContext07Test < ActiveSupport::TestCase
  # context: with user
  # context: with oob callback
  # context: authorize request
  # context: exchange for access token

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'oob'
    @token.authorize!(@user)
    @token.provided_oauth_verifier = @token.verifier
    @access = @token.exchange!
  end

  test "should invalidate request token" do
    assert @token.invalidated?
  end

  test "should set user on access token" do
    assert_equal @user, @access.user
  end

  test "should authorize accesstoken" do
    assert @access.authorized?
  end
end

class RequestTokenContext08Test < ActiveSupport::TestCase
  # context: with user
  # context: with oob callback
  # context: authorize request
  # context: attempt exchange with invalid verifier (OAuth 1.0a)

  setup do
    @token = RequestToken.create!(client_application: ClientApplication.first)
    @user = Account.find_by! login: 'jdoe'
    @token.callback_url = 'oob'
    @token.authorize!(@user)
    @access = @token.exchange!
  end

  test "should return false" do
    assert_not @value
  end

  test "should not invalidate request token" do
    assert_not @token.invalidated?
  end
end
