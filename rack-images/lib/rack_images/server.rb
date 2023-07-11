class RackImages::Server
  def self.call(env)
    new.call(env)
  end

  def call(env)
    @env = env
    logging

    verify_access
    render_image
  rescue RackImages::Exception => e
    self.class.logger.error e.message
    self.class.logger.error e.backtrace.join("\n")
    render_not_available
  end

  def request
    @request ||= Rack::Request.new(@env)
  end

  def verify_access
    unless valid_token?
      raise RackImages::Exception, "access denied"
    end
  end

  def render_image
    resizer = RackImages::Resizer.new
    file = resizer.run(full_path_info)
    content_type = resizer.content_type

    [200, {'content-type' => content_type}, file]
  end

  def valid_token?
    token = request.params['_asd']
    RackImages::Secret.valid?(token, full_path_info)
  end
  
  # returns the full path info including the query string but without _asd=...
  def full_path_info
    request.url.
      gsub(ENV['PM_RACK_IMAGES_BASE_URL'], '').
      gsub(/[\?\&]_asd=[a-z0-9]+$/, '')
  end

  def render_not_available
    [502, {'content-type' => 'text/plain'}, ['']]
  end

  def logging
    @env['rack.errors'] = self.class.log_file
  end

  def self.log_file
    @log_file ||= begin
      filename = "#{ENV['PM_ROOT']}/rack-images/log/#{RACK_ENV}.log"
      dir = File.dirname(filename)
      system "mkdir -p #{dir}"
      file = File.open(filename, File::CREAT | File::WRONLY | File::APPEND)
      file.sync = true
      file
    end
  end

  def self.logger
    @logger ||= Logger.new(log_file)
  end
end
