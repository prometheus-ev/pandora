require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  test 'should destroy when underlying source data changes' do
    TestSource.index
    pid = pid_for(1)
    jdoe = Account.find_by(login: 'jdoe')

    um = UserMetadata.create!(
      pid: pid,
      field: 'title',
      value: 'Something',
      account: jdoe
    )
    um.to_elastic

    assert_equal 'Katze auf Stuhl', um.updates.last['original']
    um.updates.last['original'] = 'Keine Katze'
    um.save

    TestSource.index
    assert_equal 0, UserMetadata.count
  end

  test 'should be added when indexing (new indexing pipeline)' do
    Pandora::Indexing::Indexer.index(['json_test_source'])

    jdoe = Account.find_by(login: 'jdoe')
    pid = pid_for(74539, 'json_test_source')

    um = UserMetadata.create!(
      pid: pid,
      field: 'title',
      value: 'Something',
      account: jdoe
    )

    Pandora::Indexing::Indexer.index(['json_test_source'])
    super_image = Pandora::SuperImage.new(pid)

    assert_equal 'Something', super_image.elastic_record['_source']['title'][0]
  end

  test "updating elastic shouldn't fail when the record is missing" do
    Pandora::Indexing::Indexer.index(['json_test_source'])

    jdoe = Account.find_by(login: 'jdoe')
    pid = 'json_test_source-noexist'

    um = UserMetadata.create!(
      pid: pid,
      field: 'title',
      value: 'Something',
      account: jdoe
    )
    um.to_elastic

    # no exception -> we're happy
  end
end
