require 'test_helper'

class FieldValidatorTest < ActiveSupport::TestCase
  setup do
  end

  def teardown
  end

  test 'path validation' do
    field_validator = Indexing::FieldValidator.new

    assert_raise Pandora::Exception do
      field_validator.validate('path', '/my-image.jpg')
    end

    assert_equal('my-image.jpg', field_validator.validate('path', 'my-image.jpg'))
  end
end
