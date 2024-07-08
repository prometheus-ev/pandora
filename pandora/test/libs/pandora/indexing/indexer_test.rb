require 'test_helper'

class IndexerTest < ActiveSupport::TestCase
  test 'sends a notification email when a source is indexed' do
    Pandora::Indexing::Indexer.index(['xml_test_source'])
    assert_equal 0, ActionMailer::Base.deliveries.size

    with_env 'PM_INDEX_NOTIFY' => 'user@example.com' do
      Pandora::Indexing::Indexer.index(['xml_test_source'])
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end
