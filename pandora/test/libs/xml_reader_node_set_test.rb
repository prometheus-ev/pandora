require 'test_helper'
require 'test_sources/test_source_xml_reader'

class SourceTest < ActiveSupport::TestCase
  def test_xmlReaderNodeSet_countTestSourceRecords_threeRecords
    TestSourceXmlReader.index
    result = TestSourceXmlReader.new.records.count

    # http://guides.rubyonrails.org/testing.html#available-assertions
    assert_equal(4, result)
  end
end
