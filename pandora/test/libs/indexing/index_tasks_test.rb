require 'test_helper'

class IndexTasksTest < ActiveSupport::TestCase
  if production_sources_available?
    setup do
      tasks = Indexing::IndexTasks.new
      tasks.drop(['robertin'])
      tasks.load(['robertin'])
    end

    def teardown
      # we do this so that a prestine index situation is provided for following
      # tests
      tasks = Indexing::IndexTasks.new
      tasks.drop(['robertin'])
      tasks.load(['robertin'])
    end

    test 'revert' do
      elastic = Pandora::Elastic.new
      tasks = Indexing::IndexTasks.new

      assert_equal 'robertin_1', elastic.index_name_from(alias_name: 'robertin')
      assert elastic.index_exists?('robertin_1')
      assert_not elastic.index_exists?('robertin_2')

      tasks.load(['robertin'])
      assert_equal 'robertin_2', elastic.index_name_from(alias_name: 'robertin')
      assert elastic.index_exists?('robertin_1')
      assert elastic.index_exists?('robertin_2')

      tasks.revert('robertin')
      assert_equal 'robertin_1', elastic.index_name_from(alias_name: 'robertin')
      assert elastic.indices.find{|i| i['index'] == 'robertin_1'}
      assert elastic.indices.find{|i| i['index'] == 'robertin_2'}
    end
  end
end
