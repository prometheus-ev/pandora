require 'test_helper'

class KeywordTest < ActiveSupport::TestCase
  test 'strips white space and quotes' do
    assert_equal 'church', Keyword.create(title: '  church ').title
    assert_equal 'landscape', Keyword.create(title: "\"landscape\n\"").title
  end

  test 'keyword removed from objects when deleted' do
    KeywordsSources = Class.new(ApplicationRecord)
    KeywordsUploads = Class.new(ApplicationRecord)

    assert_not_equal 0, CollectionKeyword.count
    assert_not_equal 0, KeywordSource.count
    assert_not_equal 0, KeywordUpload.count

    Keyword.destroy_all

    assert_equal 0, CollectionKeyword.count
    assert_equal 0, KeywordSource.count
    assert_equal 0, KeywordUpload.count
  end

  test 'keyword re-associated to objects when merged' do
    italy = Keyword.create! title: 'italy'
    italy_1988 = Keyword.find_by! title: 'Italy 1988'

    italy.merge [italy_1988.id]

    assert_equal 1, italy.collections.count
  end

  test 'search by keyword only uses current locale' do
    assert_equal 0, Collection.search('keywords', 'Italien').count
    assert_equal 1, Collection.search('keywords', 'Italy').count

    assert_equal 0, Source.search('keywords', 'Archäologie').count
    assert_equal 1, Source.search('keywords', 'art history').count

    assert_equal 0, Upload.search('keywords', 'Gemälde').count
    assert_equal 1, Upload.search('keywords', 'painting').count

    with_locale :de do
      assert_equal 1, Collection.search('keywords', 'Italien').count
      assert_equal 0, Collection.search('keywords', 'Italy').count

      assert_equal 1, Source.search('keywords', 'Archäologie').count
      assert_equal 0, Source.search('keywords', 'art history').count

      assert_equal 1, Upload.search('keywords', 'Gemälde').count
      assert_equal 0, Upload.search('keywords', 'painting').count
    end
  end
end
