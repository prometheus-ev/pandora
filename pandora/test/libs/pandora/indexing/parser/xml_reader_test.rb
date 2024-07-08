require 'test_helper'
require 'test_sources/xml_test_source'

class XmlReaderTest < ActiveSupport::TestCase
  test 'iterates properly, finds elements' do
    source = Source.find_and_update_or_create_by(name: 'xml_test_source')
    reader = XmlTestSource.new(source)
    reader.filename = "#{ENV['PM_DUMPS_DIR']}xml_test_source.xml"

    assert_equal 3, reader.to_enum.count
  end
end
