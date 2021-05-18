require 'test_helper'
require "test_sources/test_source"

class SourceTest < ActiveSupport::TestCase
  test 'record count updates when new source is indexed' do
    TestSource.index
    assert_equal 3, Source.find_by_name('test_source').record_count
  end

  test 'record count updates when existing source is indexed' do
    TestSource.index
    assert_equal 3, Source.find_by_name('test_source').record_count

    # TODO: Stub the file to index after indexing is refactored.
    FileUtils.cp 'test/fixtures/data/test_source.xml', 'test/fixtures/data/test_source.xml.backup'
    doc = Nokogiri::XML(File.open('test/fixtures/data/test_source.xml'))
    row = doc.at_css "row"
    row.add_next_sibling "<row><id>4</id></row>"
    File.write('test/fixtures/data/test_source.xml', doc.to_xml)

    TestSource.index
    assert_equal 4, Source.find_by_name('test_source').record_count

  ensure
    if File.exist?('test/fixtures/data/test_source.xml.backup')
      FileUtils.cp 'test/fixtures/data/test_source.xml.backup', 'test/fixtures/data/test_source.xml'
      FileUtils.remove_file 'test/fixtures/data/test_source.xml.backup'
    end
  end
end
