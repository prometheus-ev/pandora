class Pandora::LogCache
  def initialize
    @requests = {}
  end

  def add(requests)
    requests.each do |r|
      next unless r['ts']

      ts = r['ts'].strftime('%Y%m%d')
      @requests[ts] ||= []
      @requests[ts] << r
    end

    write all: false
  end

  def finalize
    write all: true
  end

  def write(options = {})
    options.reverse_merge! all: false

    dates = (options[:all] ? @requests.keys : @requests.keys.sort[1..-3] || [])

    dates.each do |date|
      month = date.gsub(/\d\d$/, '')
      day = date.gsub(/^\d\d\d\d\d\d/, '')
      FileUtils.mkdir_p("#{ENV['PM_STATS_DIR']}/packs/#{month}")
      filename = "#{ENV['PM_STATS_DIR']}/packs/#{month}/#{day}.json"
      gzip = "#{filename}.gz"

      out = Pandora::Stats.new(@requests[date])
      if File.exist?(gzip)
        out = (out + Pandora::Stats.load(filename)).uniq
        File.delete gzip
      end

      File.open filename, 'w' do |f|
        f.write out.to_json
      end

      # drop the data we just wrote to the pack file, so the memory is
      # freed
      @requests.delete date

      system "gzip -f #{filename}"
    end
  end
end
