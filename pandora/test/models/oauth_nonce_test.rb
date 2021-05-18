require 'test_helper'

class OauthNounceTest < ActiveSupport::TestCase
  include OAuth::Helper

  setup do
    @oauth_nonce = OauthNonce.remember(generate_key, Time.now.to_i)
  end

  test "should be valid" do
    assert @oauth_nonce.valid?
  end

  test "should not have errors" do
    assert_empty @oauth_nonce.errors
  end

  test "should not be a new record" do
    assert_not @oauth_nonce.new_record?
  end

  test "should not allow a second one with the same values" do
    assert_not OauthNonce.remember(@oauth_nonce.nonce, @oauth_nonce.timestamp)
  end
end