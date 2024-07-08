require 'csv'

namespace :pandora do
  desc 'parse log files and cache them in json packs'
  task parse_logs: :environment do
    cache = Pandora::LogCache.new

    # in production, logrotate moves old log files to the log archive in .gz
    # format
    dir = (
      Rails.env.production? ?
      ENV['PM_LOG_ARCHIVE_DIR'] :
      "#{ENV['PM_ROOT']}/pandora/log"
    )

    Dir["#{dir}/*"].each do |f|
      # in production, limit the parsing to the last 7 days because the older
      # files have likely already been parsed
      next if Rails.env.production? && File.stat(f).mtime < 1.week.ago

      requests = Pandora::LogParser.parse(f, progress: ENV['PM_SILENT'] != 'true')
      cache.add requests
    end
    cache.finalize
  end

  desc 'test the log parser on the most recent log files (they need to be downloaded before)'
  task log_parser_test: :environment do
    raise "run this in development only" unless Rails.env.development?

    dir = ENV['PM_LOG_ARCHIVE_DIR']

    # parse logs
    files = Dir["#{dir}/production.log-202208*"]
    count = 0
    files.each do |f|
      parser = Pandora::LogParser.new(f, progress: true, test_mode: true)
      requests = parser.parse
      count += requests.size
    end
    puts "parsed #{count} requests"

    # generate log packs
    cache = Pandora::LogCache.new
    files = [
      "#{dir}/production.log-20220729.gz", # log files's dates don't necessarily match their contents
      "#{dir}/production.log-20220730.gz",
      "#{dir}/production.log-20220731.gz",
      *Dir["#{dir}/production.log-202208*"],
      "#{dir}/production.log-20220901.gz",
      "#{dir}/production.log-20220902.gz",
      "#{dir}/production.log-20220903.gz"
    ]
    files.each do |f|
      requests = Pandora::LogParser.parse(f, progress: ENV['PM_SILENT'] != 'true')
      cache.add requests
    end
    cache.finalize

    # build sum stats
    from = '2022-08-01'.to_date
    to = '2022-08-31'.to_date
    sum_stats = Pandora::SumStats.new(from, to)
    sum_stats.aggregate

    # aggregate
    sd = ENV['PM_STATS_DIR']
    stats = Pandora::Stats.empty
    Dir["#{sd}/packs/202208/*"].each do |pack|
      puts "loading #{pack} ..."
      stats += Pandora::Stats.load(pack)
    end
  end

  desc 'inspect log pack content'
  task inspect_packs: :environment do
    to = (ENV['TO'] || Date.today.at_beginning_of_month - 1).to_date
    from = (ENV['FROM'] || to.at_beginning_of_month).to_date

    sd = ENV['PM_STATS_DIR']
    stats = Pandora::Stats.new([])

    (from..to).each do |day|
      file = "#{sd}/packs/#{day.year}#{'%02d' % day.month}/#{'%02d' % day.day}.json.gz"
      binding.pry unless File.exist?(file)

      puts "Loading #{file}"

      stats = stats + Pandora::Stats.load(file)
    end

    # then, for example:
    # searches = stats.searches.select do |r|
    #   next false if r['status'] != 200
    #   next false unless r['action'] == 'advanced'
    #   next false unless r['params']['boolean_fields_selected']

    #   r['params']['boolean_fields_selected'].values.uniq != ['must']
    # end
    # binding.pry
  end

  desc 'generate sum_stats records from json packs'
  task sum_stats: :environment do
    to = (ENV['TO'] || Date.today.at_beginning_of_month - 1).to_date
    from = (ENV['FROM'] || to.at_beginning_of_month).to_date
    sum_stats = Pandora::SumStats.new(from, to)
    sum_stats.aggregate
  end

  desc 'cache terms of the month files from json packs'
  task top_terms: :environment do
    to = (ENV['TO'] || Date.today.at_beginning_of_month - 1).to_date
    from = (ENV['FROM'] || to.at_beginning_of_month).to_date
    sum_stats = Pandora::SumStats.new(from, to)
    sum_stats.cache_top_terms
  end

  desc 'stats per institution and month'
  task stats: :environment do
    to = (ENV['TO'] || Date.today.at_beginning_of_month - 1).to_date
    from = (ENV['FROM'] || to.at_beginning_of_month).to_date
    stats = Stats.get_console_csv(from, to)
    puts Pandora.to_csv(stats)
  end

  desc 'print top terms for a period (default is year)'
  task print_top_terms_for_period: :environment do
    # date environment variables must be of format: YYYY-MM-DD
    to = (ENV['TO'] || Date.today.end_of_year).to_date
    from = (ENV['FROM'] || Date.today.beginning_of_year).to_date
    only = 100
    if ENV['ONLY']
      only = ENV['ONLY'].to_i
    end
    sum_stats = Pandora::SumStats.new(from, to)
    puts sum_stats.top_terms(:only => only)
  end
end
