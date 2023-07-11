class Pandora::SumStats
  def initialize(from, to)
    @from = from
    @to = to
  end

  def top_terms(options = {})
    results = {}
    with_dates do |date, stats, top_terms|
      (top_terms || {}).each do |term, count|
        results[term.strip.downcase] ||= 0
        results[term.strip.downcase] += count
      end
    end

    results = results.
      map{|k, v| {'term' => k, 'count' => v}}.
      sort_by{|v| v['count']}.
      reverse

    options[:only].is_a?(Integer) ? results[0..(options[:only] - 1)] : results
  end

  def cache_top_terms
    with_dates do |date, stats|
      filename = date.strftime("#{ENV['PM_STATS_DIR']}/top_terms/%Y%m/%d.json")

      if stats && !File.exist?(filename)
        FileUtils.mkdir_p(File.dirname filename)
        File.open filename, 'w' do |f|
          f.write JSON.dump(stats.top_terms)
        end
      end
    end
  end

  def active_institutions
    ids = {}
    with_dates do |date, stats|
      if stats
        stats.select{|s| s['personalized'] == false}.each do |s|
          ids[s['institution_id']] ||= true
        end
      end
    end
    ids
  end

  def for_institutions(institutions)
    institutions = [institutions] unless institutions.respond_to?(:map)

    result = {}
    with_dates do |date, stats|
      if stats
        stats = stats.by_institution_id

        institutions.map(&:id).each do |iid|
          if s = stats[iid]
            result[iid] ||= self.class.result
            result[iid]['sessions'] += s.sessions.count
            result[iid]['searches'] += s.searches.count
            result[iid]['downloads'] += s.detail_views.count
            result[iid]['hits'] += s.count
          end
        end
      end
    end

    result.map do |iid, data|
      data.merge 'institution_id' => iid
    end
  end

  def aggregate
    with_dates do |date, stats|
      if stats
        by_iid = stats.by_institution_id

        by_iid.each do |iid, stats|
          criteria = {
            institution_id: iid,
            year: date.year,
            month: date.month,
            day: date.day
          }

          ss = ::SumStats.find_or_create_by! criteria
          ss.update(
            sessions_campus: stats.sessions.count - stats.personalized.sessions.count,
            sessions_personalized: stats.personalized.sessions.count,
            downloads_campus: stats.legacy_downloads.count - stats.personalized.legacy_downloads.count,
            downloads_personalized: stats.personalized.legacy_downloads.count,
            searches_campus: stats.searches.count - stats.personalized.searches.count,
            searches_personalized: stats.personalized.searches.count,
            hits_campus: stats.count - stats.personalized.count,
            hits_personalized: stats.personalized.count
          )
        end
      end
    end
  end


  protected

    def with_dates
      dates.each do |date|
        args = [date]

        filename = date.strftime("#{ENV['PM_STATS_DIR']}/packs/%Y%m/%d.json.gz")
        if File.exist?(filename)
          args << Pandora::Stats.load(filename)
        else
          args << nil
        end

        filename = date.strftime("#{ENV['PM_STATS_DIR']}/top_terms/%Y%m/%d.json")
        if File.exist?(filename)
          args << JSON.parse(File.read(filename))
        else
          args << nil
        end

        yield *args
      end
    end

    def dates
      (@to - @from + 1).to_i.times.map do |i|
        @to - i
      end.sort
    end

    def self.result
      return {
        'sessions' => 0,
        'searches' => 0,
        'downloads' => 0,
        'hits' => 0
      }
    end
end
