require 'test_helper'

class ClientApplicationTest < ActiveSupport::TestCase
  setup do
    @application = ClientApplication.create!(
      name: 'Agree2',
      url: 'http://agree2.com'
    )
  end

  test "should be valid" do
    assert @application.valid?
  end

  test "should have key and secret" do
    assert_not_nil @application.key
    assert_not_nil @application.secret
  end

  test "should have credentials" do
    assert_not_nil @application.credentials
    assert_equal @application.key, @application.credentials.key
    assert_equal @application.secret, @application.credentials.secret
  end
end

