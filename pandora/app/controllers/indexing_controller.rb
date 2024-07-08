class IndexingController < ApplicationController
  def self.initialize_me!
    control_access [:superadmin, :admin] => :ALL
  end

  def index
    render layout: false
  end

  def results
    data = {}

    Dir["#{ENV['PM_INDEX_RESULTS_DIR']}/*"].each do |path|
      file = File.basename(path)
      source, ts, ext = file.split('.')
      ts = Time.parse(ts)

      data[source] ||= []
      data[source] << JSON.parse(File.read(path))
    end

    render json: data
  end

  def counts
    data = Pandora::Elastic.new.counts
    render json: data
  end

  def image_urls
    pids = params[:pids] || []
    data = {}

    pids.each do |pid|
      data[pid] = Pandora::SuperImage.new(pid).image_url(:small)
    end

    render json: data
  end
end
