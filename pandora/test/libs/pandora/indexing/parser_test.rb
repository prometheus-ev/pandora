require 'test_helper'
Dir["./test/test_sources/*.rb"].each{|file| require file}

class ParserTest < ActiveSupport::TestCase
  test 'works for xml test source' do
    parser = XmlTestSource.new({name: 'xml_test_source'})
    parser.preprocess

    count = 0
    parser.to_enum.each do |doc|
      assert_same_elements ['record_id', 'artist_normalized', 'title', 'artist'], doc.keys
      count += 1
    end

    assert_equal 3, parser.total
    assert_equal 3, count
  end

  test 'works for xml test source with objects utf-8' do
    parser = XmlTestSourceObjectsUtf8.new({name: 'xml_test_source_objects_utf8'})
    parser.preprocess

    count = 0
    parser.to_enum.each do |doc|
      assert_same_elements ['record_id',
                            'record_object_id',
                            'record_object_id_count',
                            'artist_normalized',
                            'title',
                            'artist'], doc.keys
      assert_equal 2, doc['record_object_id_count'] if count == 0
      assert_equal 2, doc['record_object_id_count'] if count == 1
      assert_equal 1, doc['record_object_id_count'] if count == 2
      count += 1
    end

    assert_equal 3, parser.total
    assert_equal 3, count
  end

  test 'works for xml test source with objects iso-8859-1' do
    parser = XmlTestSourceObjects.new({name: 'xml_test_source_objects'})
    parser.preprocess

    count = 0
    parser.to_enum.each do |doc|
      assert_same_elements ['record_id',
                            'record_object_id',
                            'record_object_id_count',
                            'artist_normalized',
                            'title',
                            'artist'], doc.keys
      assert_equal 2, doc['record_object_id_count'] if count == 0
      assert_equal 2, doc['record_object_id_count'] if count == 1
      assert_equal 1, doc['record_object_id_count'] if count == 2
      count += 1
    end

    assert_equal 3, parser.total
    assert_equal 3, count
  end

  test 'works for json test source' do
    parser = JsonTestSource.new({name: 'json_test_source'})
    parser.preprocess

    count = 0
    parser.to_enum.each do |doc|
      assert_same_elements ['record_id', 'artist', 'title', 'location', 'date'], doc.keys
      count += 1
    end

    assert_equal 3, count
  end
end
