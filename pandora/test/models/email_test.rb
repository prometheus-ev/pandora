require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  test 'address validations' do
    email = Email.new(from: 'newsletter')
    email.valid?
    assert_equal ['is invalid', 'has an invalid domain name'], email.errors[:from]

    email = Email.new(from: 'info@wendig.io')
    email.valid?
    assert_equal ['is invalid'], email.errors[:from]

    email = Email.new(from: 'prometheus <newsletter@example.com>')
    email.valid?
    assert_empty email.errors[:from]

    email = Email.new(to: 'someone')
    email.valid?
    assert_equal ['has an invalid domain name'], email.errors[:to]

    email = Email.new(to: 'someone@example.com')
    email.valid?
    assert_empty email.errors[:to]

    email = Email.new(to: 'newsletter')
    email.valid?
    assert_empty email.errors[:to]

    email = Email.new(to: 'admins')
    email.valid?
    assert_empty email.errors[:to]

    # why?
    email = Email.new(to: '#interesting')
    email.valid?
    assert_empty email.errors[:to]

    email = Email.new(to: ['newsletter', 'someone'])
    email.valid?
    assert_equal ['has an invalid domain name'], email.errors[:to]

    email = Email.new(to: nil)
    email.valid?
    assert_equal ["can't be blank"], email.errors[:to]

    email = Email.new(to: [])
    email.valid?
    assert_equal ["can't be blank"], email.errors[:to]
  end
end