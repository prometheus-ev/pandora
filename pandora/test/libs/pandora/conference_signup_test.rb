require 'test_helper'

class Pandora::ConferenceSignupTest < ActiveSupport::TestCase
  test 'validators' do
    signup = Pandora::ConferenceSignup.new(
      brauhaus: 12
    )
    assert_not signup.valid?
    assert_includes signup.errors[:base], 'Your email was empty...'

    signup.email = 'not an email'
    assert_not signup.valid?
    assert_includes signup.errors[:base], 'Your e-mail address is invalid'
  end
end