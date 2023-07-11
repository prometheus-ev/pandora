require 'test_helper'

class StatsGeneralTest < ActiveSupport::TestCase
  test 'parse search the test log file' do
    file = Rails.root.join('test/fixtures/files/production.log.gz')
    requests = Pandora::LogParser.parse(file, progress: false)
    assert_equal 946, requests.count

    stats = Pandora::Stats.new(requests)
    assert_equal 1, stats.downloads.count
    assert_equal 89, stats.logins.count
    assert_equal 20, stats.detail_views.count
    assert_equal 96, stats.sessions.count
    assert_equal 11, stats.top_terms['baum']
  end

  test 'cache the test log file to json files and use them' do
    file = Rails.root.join('test/fixtures/files/production.log.gz')
    requests = Pandora::LogParser.parse(file, progress: false)

    cache = Pandora::LogCache.new
    cache.add requests
    cache.finalize
    assert File.exist?("#{ENV['PM_STATS_DIR']}/packs/201902/06.json.gz")

    Pandora::SumStats.new(Date.new(2018,1,1), Date.new(2019,12,31)).cache_top_terms

    sum_stats = Pandora::SumStats.new(Date.new(2018,11,14), Date.new(2019,2,5))
    assert_equal 84, sum_stats.send(:dates).count
    assert_empty sum_stats.top_terms

    sum_stats = Pandora::SumStats.new(Date.new(2019,1,10), Date.new(2019,2,10))
    assert_equal 32, sum_stats.send(:dates).count
    assert_equal 'baum', sum_stats.top_terms[0]['term']
    assert_equal 11, sum_stats.top_terms[0]['count']

    institution = Institution.find_by! name: 'nowhere'
    stats = sum_stats.for_institutions(institution)
    assert_equal 1, stats.size
    assert_equal 7, stats[0]['sessions']
    assert_equal 4, stats[0]['searches']
    assert_equal 0, stats[0]['downloads']
    assert_equal 40, stats[0]['hits']

    institution = Institution.find_by! name: 'prometheus'
    stats = sum_stats.for_institutions([institution])
    assert_equal 1, stats.size
    assert_equal 75, stats[0]['sessions']
    assert_equal 66, stats[0]['searches']
    assert_equal 19, stats[0]['downloads']
    assert_equal 626, stats[0]['hits']

    stats = sum_stats.for_institutions(Institution.all)
    assert_equal 2, stats.size
    assert_equal 1, stats[0]['institution_id']
    assert_equal 75, stats[0]['sessions']

    csv = Pandora.to_csv(stats)
    assert_equal 3, csv.split("\n").size
  end
end
