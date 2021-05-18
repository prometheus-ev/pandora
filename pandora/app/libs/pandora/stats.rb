class Pandora::Stats
  extend Forwardable

  def_delegators(:@requests,
    :[], :each, :select, :map, :first, :last, :count, :size, :reject, :to_a
  )

  def initialize(requests)
    @requests = requests
  end

  def self.load(filename)
    new JSON.load(io_for filename)
  end

  def to_json
    JSON.dump @requests
  end

  def +(other)
    self.class.new(@requests + other.to_a)
  end

  def sort
    @requests.sort_by!{|e| e['ts']}
    self
  end


  # filters

  def uniq
    requests = @requests.uniq{|e| e['id']}
    self.class.new(requests)
  end

  def app(app)
    results = @requests.select do |r|
      r['app'] == app
    end
    self.class.new(results)
  end

  def month(month)
    results = @requests.select do |r|
      r['ts'].strftime('%Y-%m') == month
    end
    self.class.new(results)
  end

  def personalized
    results = @requests.select do |r|
      r['personalized']
    end
    self.class.new(results)
  end

  def logins(options = {})
    results = @requests.select do |r|
      (r['action'] == 'login' && r['method'] == 'POST') &&
      (
        (options[:successful] == true && r['status'] != 422) ||
        (options[:successful] == false && r['status'] == 422) ||
        options[:successful] == nil
      )
    end
    self.class.new(results)
  end

  def searches
    # TODO: can be removed in early 2020
    legacy_simple = @requests.select do |r|
      r['controller'] == 'SearchController' && r['action'] == 'search'
    end

    # TODO: can be removed in early 2020
    legacy_advanced = @requests.select do |r|
      r['controller'] == 'SearchController' && r['action'] == 'advanced_search'
    end

    simple = @requests.select do |r|
      r['controller'] == 'SearchesController' && r['action'] == 'index'
    end

    advanced = @requests.select do |r|
      r['controller'] == 'SearchesController' && r['action'] == 'advanced'
    end

    self.class.new(simple + advanced + legacy_simple + legacy_advanced)
  end

  def detail_views
    results = @requests.select do |r|
      r['controller'] == 'ImagesController' && r['action'] == 'show'
    end

    # TODO: can be removed in early 2020
    legacy_results = @requests.select do |r|
      r['controller'] == 'ImageController' && r['action'] == 'show'
    end

    self.class.new(results + legacy_results)
  end

  def downloads
    results = @requests.select do |r|
      r['controller'] == 'ImagesController' && r['action'] == 'download'
    end

    # TODO: can be removed in early 2020
    legacy_results = @requests.select do |r|
      r['controller'] == 'ImageController' && r['action'] == 'download'
    end

    self.class.new(results + legacy_results)
  end

  # we add this method to count 'download' clicks as they were counted in legacy
  def legacy_downloads
    results =  @requests.select do |r|
      ['ImagesController', 'ImageController'].include?(r['controller']) &&
      ['show', 'small', 'medium', 'large', 'download'].include?(r['action'])
    end

    self.class.new(results)
  end

  def institution(id)
    results = @requests.select do |r|
      r['institution_id'] == id
    end
    self.class.new(results)
  end

  def user(id)
    results = @requests.select do |r|
      r['user_id'] == id
    end
    self.class.new(results)
  end

  def source(source)
    results = @requests.select do |r|
      r['path'].match(/^\/#{source}\//)
    end
    self.class.new(results)
  end

  def writing
    results = @requests.select do |r|
      ['POST', 'PATCH', 'PUT'].include?(r['method'])
    end
    self.class.new(results)
  end

  def reading
    results = @requests.select do |r|
      !['POST', 'PATCH', 'PUT', nil].include?(r['method'])
    end
    self.class.new(results)
  end

  # metrics

  def top_terms
    results = {}
    searches.each do |s|
      begin
        if (sv = s['params']['search_value']) && !sv.empty?
          term = sv['0']
          results[term] ||= 0
          results[term] += 1
        end
      rescue TypeError
      end
    end
    results
  end

  def by_time(format = '%Y-%m-%d')
    @requests.group_by do |r|
      r['ts'].strftime(format)
    end
  end

  def by_institution_id
    results = @requests.group_by do |r|
      r['institution_id']
    end
    results.transform_values{|requests| self.class.new(requests)}
  end

  def by_source_id
    @requests.group_by do |r|
      r['path'].split('/')[1]
    end
  end

  def sessions
    @requests.map{|r| r['session_id']}.reject{|i| i.nil?}.uniq
  end


  protected

    def self.io_for(filename)
      r, w = IO.pipe
      cmd = "zcat -f '#{filename}'"
      pid = Process.spawn cmd, out: w
      Thread.new do
        Process.wait pid
        w.close
      end
      r
    end
end
