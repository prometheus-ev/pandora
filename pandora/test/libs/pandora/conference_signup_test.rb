require 'test_helper'

class Pandora::ConferenceSignupTest < ActiveSupport::TestCase
  test 'validators' do
    signup = Pandora::ConferenceSignup.new(
      presence: 'physical',
      empfang: true,
      feier: true,
      abendessen: true
    )

    assert_not signup.valid?
    assert_includes signup.errors[:base], 'Your email was empty...'

    signup.email = 'not an email'
    assert_not signup.valid?
    assert_includes signup.errors[:base], 'Your e-mail address is invalid'

    signup.email = 'test@example.com'
    signup.first_name = 'Joe'
    signup.last_name = 'Doe'
    signup.street = 'Am Dreifuß 13'
    signup.postal_code = '55433'
    signup.city = 'Frankfurt am Main'
    signup.country = 'Germany'
    assert signup.valid?
  end
end
