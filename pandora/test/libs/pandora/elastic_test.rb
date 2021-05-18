require 'test_helper'

class ElasticTest < ActiveSupport::TestCase
  setup do
    TestSource.index
  end

  teardown do
    Pandora::Elastic.new.destroy_index('test*')
  end

  test 'create_index_and_switch_alias' do
    elastic = Pandora::Elastic.new
    alias_name = 'test_source'

    new_index_name = elastic.create_index alias_name

    assert_equal 'test_source_2', new_index_name
    assert_equal 'test_source_1', elastic.index_name_from(alias_name: alias_name)

    elastic.add_alias_to(index_name: new_index_name)

    assert_equal 'test_source_2', elastic.index_name_from(alias_name: alias_name)
  end
end
