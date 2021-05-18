require 'csv'

namespace :pandora do
  desc 'parse log files and cache them in json packs'
  task parse_logs: :environment do
    cache = Pandora::LogCache.new

    # in production, logrotate moves old log files to the log archive in .gz
    # format
    dir = (Rails.env.production? ?
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
