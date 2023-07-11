require 'test_helper'
Dir["./test/test_sources/*.rb"].each {|file| require file }

class SourceParentTest < ActionDispatch::IntegrationTest
  def test_sourceModel_indexTestSourceWithTwoDumpFiles_returnsTwoRecords
    records_count = TestSourceWithTwoDumpFiles.index

    assert_equal(2, records_count)
  end

  def test_sourceModel_indexTestSourceWithNilRecordIdCount_oneRecord
    records_count = TestSourceWithNilRecordId.index

    assert_equal(1, records_count)
  end

  def test_sourceModel_indexTestSourceWithEmptyRecordIdCount_oneRecord
    records_count = TestSourceWithEmptyRecordId.index

    assert_equal(1, records_count)
  end

  def test_sourceModel_indexTestSourceRecordsCount_threeRecords
    records_count = TestSource.index

    assert_equal(12, records_count)
  end

  def test_sourceModel_documentTestSourceRecordsCount_threeRecords
    records_count = TestSource.new.records.count

    assert_equal(12, records_count)
  end

  def test_sourceModel_indexTestSourceWithErrors_returnsZeroRecords
    records_count = TestSourceWithErrors.index

    assert_equal(0, records_count)
  end

  def test_sourceModel_indexTestFilterSource_containsKlapsch
    TestFilterSource.index

    assert_equal(3, TestFilterSource.filter_records(Indexing::Index.aliases, Indexing::SourceParent::KLAPSCH_FILTER).size)
  end

  def test_sourceModel_indexTestSourceArtigo_oneRecordAnd37Tags
    records_count = TestSourceArtigo.index

    assert_equal(1, records_count)

    get '/api/json/image/show', params: { id: 'test_source_artigo-356a192b7913b04c54574d18c28d46e6395428ab' }, headers: api_auth('jdoe')

    assert response.successful?
    assert_equal(37, json["keyword_artigo"].split(', ').size)
  end

  def test_sourceParent_artistFieldWithPkndArtistRafaello_returnsOneHit
    TestSourcePknd.index

    get '/api/json/search/advanced_search', params: {f: ['artist'], v: ['raphael'], s: ['test_source_pknd']}, headers: api_auth('jdoe')

    assert_equal(1, json.size)
  end

  def test_sourceParent_artistSearchWithPkndRaffaello_returnsThreeHits
    TestSourcePkndArtistAttributions.index

    result = TestSourcePkndArtistAttributions.search 'raffaello', 'artist'

    assert_equal(3, result['hits']['total']['value'])
  end

  def test_sourceParent_searchWithPkndRaffaello_returnsZeroHits
    TestSourcePkndArtistAttributions.index

    result = TestSourcePkndArtistAttributions.search 'raffaello'

    assert_equal(3, result['hits']['total']['value'])
  end

  def test_sourceParent_searchWithPkndRudolfBauer_returnsOneHit
    TestSourceVgbk.index

    result = TestSourceVgbk.search 'R. Bauer'

    assert_equal(1, result['hits']['total']['value'])
  end
end
