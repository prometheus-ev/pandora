require 'test_helper'
require "test_sources/test_source"

class IndexTasksTest < ActiveSupport::TestCase
  setup do
    TestSource.index
  end

  teardown do
    Indexing::Index.delete("test*")
    
    system "rm -f #{ENV['PM_INDEX_PACK_DIR']}/test_source.json.gz"
  end

  test 'dump and load index task' do
    alias_name = 'test_source'
    elastic = Pandora::Elastic.new

    assert_equal 'test_source_1', elastic.index_name_from(alias_name: alias_name)

    Indexing::IndexTasks.new.dump(['test_source'])
    Indexing::IndexTasks.new.load(['test_source'])

    assert_equal 'test_source_2', elastic.index_name_from(alias_name: alias_name)
    assert elastic.index_exists?('test_source_1')

    Indexing::IndexTasks.new.load(['test_source'])

    assert_equal 'test_source_3', elastic.index_name_from(alias_name: alias_name)
    assert elastic.index_exists?('test_source_2')
    assert_not elastic.index_exists?('test_source_1')
  end

  test 'stripping attachments' do
    pid = 'test_source-356a192b7913b04c54574d18c28d46e6395428ab'
    # we update elasticsearch manually to be able to test that dumping strips
    # the attachment values
    elastic = Pandora::Elastic.new
    elastic.update 'test_source', pid, {
      'rating_average' => 3.0,
      'rating_count' => 22,
      'comment_count' => 3,
      'user_comments' => [
        'nice picture',
        'the title should actually be "something else"',
        'another interesting fact'
      ].join('; ')
    }
    elastic.refresh
    image = Pandora::SuperImage.find(pid)
    assert_equal 3.0, image.elastic_record['_source']['rating_average']

    Indexing::IndexTasks.new.dump(['test_source'])

    # dumping should have stripped the attachment values
    pack = JSON.parse(
      `cat #{ENV['PM_INDEX_PACK_DIR']}/test_source.json.gz | gunzip -c`
    )
    record = pack['records'].find{|r| r['_id'] == pid}
    assert_nil record['_source']['rating_average']
    assert_nil record['_source']['rating_count']
    assert_nil record['_source']['comment_count']
    assert_nil record['_source']['user_comments']

    # loading should add existing comments and ratings to the index, but we need
    # to add that data first
    jdoe = Account.find_by! login: 'jdoe'
    Comment.create! author: jdoe, image_id: pid, text: 'nice picture'
    Comment.create! author: jdoe, image_id: pid, text: 'the title should actually be "something else"'
    Comment.create! author: jdoe, image_id: pid, text: 'another interesting fact'
    Image.create!({
      source: Source.find_by!(name: 'test_source'),
      pid: pid,
      score: 22 * 3,
      votes: 22
    }, without_protection: true)

    # now, the load task can pick them up
    Indexing::IndexTasks.new.load(['test_source'])
    elastic.refresh
    image = Pandora::SuperImage.find(pid)
    assert_equal 3.0, image.elastic_record['_source']['rating_average']
  end
end
