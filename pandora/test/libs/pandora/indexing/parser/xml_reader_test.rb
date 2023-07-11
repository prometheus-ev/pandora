require 'test_helper'

class XmlReaderTest < ActiveSupport::TestCase
  test 'iterates properly, finds elements' do
    source = Source.find_and_update_or_create_by(name: 'xml_test_source')
    reader = Pandora::Indexing::Parser::XmlReader.new(
      source,
      record_node_name: 'row',
      namespaces: false
    )
    reader.filename = "#{ENV['PM_DUMPS_DIR']}xml_test_source.xml"

    assert_equal 3, reader.to_enum.count
  end
end
