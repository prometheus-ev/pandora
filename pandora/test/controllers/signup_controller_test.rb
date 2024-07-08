require 'test_helper'
require 'rest-client'
require 'json'
require 'io/console'

class SignupControllerTest < ActionDispatch::IntegrationTest
  test 'mail address confirmation link' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_column :email_verified_at, nil

    timestamp, token = jdoe.token_auth

    get '/en/confirm_email_linkback', params: {
      login: 'jdoe',
      timestamp: timestamp,
      token: token
    }
    assert_match /has been confirmed/, flash[:notice]
  end

  test 'mail address confirmation link (expired)' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_column :email_verified_at, nil

    timestamp, token = jdoe.token_auth

    travel 25.hours do
      get '/en/confirm_email_linkback', params: {
        login: 'jdoe',
        timestamp: timestamp,
        token: token
      }
      assert_match /Link expired/, flash[:warning]
      assert_no_match /has been confirmed/, flash[:notice]
    end
  end

  test 'mail address confirmation link (invalid)' do
    jdoe = Account.find_by! login: 'jdoe'
    jdoe.update_column :email_verified_at, nil

    timestamp, token = jdoe.token_auth

    get '/en/confirm_email_linkback', params: {
      login: 'jdoe',
      timestamp: timestamp,
      token: "wrong-#{token}"
    }
    assert_match /Link is invalid/, flash[:warning]
    assert_no_match /has been confirmed/, flash[:notice]
  end

  # not really a test: simulates certain error conditions
  # test 'invalid encoding urls' do
  #   get '/en/signup/+++[+���������+]'
  #   get '/en/signup/+++[++]'
  #   get '/en/signup/+++' + "\xc2\xa1".force_encoding("UTF-8")
  # end
end
