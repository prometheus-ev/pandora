require 'csv'

require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require File.expand_path(__dir__ + '/../../dotenv')

bb_root = File.expand_path(__dir__ + '/../vendor/brain_buster/lib')
autoload :BrainBuster, bb_root + "/brain_buster.rb"
autoload :BrainBusterSystem, bb_root + "/brain_buster_system.rb"

# so oauth works with rails 5
require 'oauth/request_proxy/action_controller_request'
OAUTH_10_SUPPORT = true

if u = ENV['PM_UMASK']
  File.umask u.to_i(8)
end

# shortcut for rails console
module Kernel
  def si(pid, options = {})
    Pandora::SuperImage.new(pid, options)
  end
end

module Pandora
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ['assets', 'tasks', 'core_ext'])

    config.add_autoload_paths_to_load_path = true

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_controller.forgery_protection_origin_check = false

    config.to_prepare do
      # TODO: find a better solution for this
      Util::Config.init(Rails.root.join('config', 'app').to_s, '.yml')
    end

    config.before_initialize do
      # REWRITE: load this first so it can be use everywhere, even in
      # initializers
      require File.expand_path(__dir__ + '/../lib/core_ext/upgrade')

      # load nuggets
      require 'nuggets/hash/nest'
      require 'nuggets/i18n'
      require 'nuggets/string/word_wrap'
    end

    config.after_initialize do
      # load core extensions
      Dir[File.expand_path(__dir__ + '/../lib/core_ext/**/*.rb')].each{|f| require f}

      # make source constants available as globals
      unless Rails.configuration.eager_load
        # without eager loading, we need to load the constants before we can
        # include them
        Dir["#{Rails.root}/app/libs/indexing/sources/**/*.rb"].each{|f| require f}
      end
      m = TOPLEVEL_BINDING.receiver # get a hold of main
      m.send :include, ::Indexing::Sources
    end

    # REWRITE: this was the default in early rails versions so let's set it
    # back since there were already problems like with
    # 'object_name_for_controller'
    config.action_controller.include_all_helpers = false

    # REWRITE: there are still forms submitted by other means than javascript,
    # but they are still generated as remote forms
    config.action_view.embed_authenticity_token_in_remote_forms = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    ENV['TZ'] = 'CET'
    config.time_zone = 'CET'

    if ENV['PM_EXCEPTION_RECIPIENTS'].present?
      host = `hostname`
      recipients = ENV['PM_EXCEPTION_RECIPIENTS'].split

      config.middleware.use ExceptionNotification::Rack, {
        email: {
          email_prefix: "[#{host}, pandora] ",
          sender_address: "errors <info@prometheus-bildarchiv.de>",
          exception_recipients: recipients
        },
        error_grouping: true,
        error_grouping_period: 5.minutes,
        # default is
        # [
        #   "ActiveRecord::RecordNotFound",
        #   "Mongoid::Errors::DocumentNotFound",
        #   "AbstractController::ActionNotFound",
        #   "ActionController::RoutingError",
        #   "ActionController::UnknownFormat"
        # ]
        ignore_exceptions: [
          # ActionController::BadRequest,
          # ActionController::UnknownFormat,
          # ActionDispatch::Http::MimeNegotiation::InvalidType
        ],
        ignore_if: lambda do |env, exception|
          case exception
          when ActionController::BadRequest
            result = (
              exception.message.match(/Invalid encoding for parameter/) ||
              exception.message.match(/Invalid query parameters: expected Hash/) ||
              exception.message.match(/Invalid query parameters: invalid %-encoding/)
            )

            !!result
          when ActionDispatch::Http::MimeNegotiation::InvalidType then true
          else
            false
          end
        end
        # ignore_cascade_pass: false
      }
    end

    # Use Rack::Cors to allow cross-origin requests from the prometheus app
    # https://rubygems.org/gems/rack-cors
    if ENV['PM_ALLOW_CORS'] == "true"
      config.middleware.insert_before 0, Rack::Cors do
        allow do
          origins ENV['PM_ALLOW_CORS_ORIGIN']
          resource '*', headers: :any, methods: [:get, :post, :put, :delete], credentials: true
        end
      end
    end

    config.x.indexing_warburg_and_miro_record_ids = Rails.application.config_for(:indexing_warburg_and_miro_record_ids)

    config.x.indexing_vgbk_artists =        Rails.application.config_for('indexing-vgbk-artists')
    config.x.indexing_non_vgbk_artists =    Rails.application.config_for('indexing-non-vgbk-artists')
    config.x.indexing_artist_attributions = Rails.application.config_for(:indexing_artist_attributions)
    config.x.indexing_custom_date_formats = Rails.application.config_for(:indexing_custom_date_formats)

    config.x.dumps_path = ENV['PM_DUMPS_DIR']
  end

  # REWRITE: we use this to add a meta tag to the default layout
  def self.revision
    @revision ||= begin
      if Rails.env.production?
        file = Rails.root.join '..', 'REVISION'
        unless File.exist?(file)
          raise Pandora::Exception, [
            "revision could not be determined,",
            "please make sure that #{file} exists"
          ].join(' ')
        end
        File.read(file).strip
      else
        run('git', 'rev-parse', 'HEAD').strip
      end
    end
  end

  def self.branch
    @branch ||= begin
      if Rails.env.production?
        file = Rails.root.join '..', 'BRANCH'
        unless File.exist?(file)
          raise Pandora::Exception, [
            "deployed branch could not be determined,",
            "please make sure that #{file} exists"
          ].join(' ')
        end
        File.read(file).strip
      else
        run('git', 'rev-parse', '--abbrev-ref', 'HEAD').strip
      end
    end
  end

  def self.progress(options = {})
    require 'ruby-progressbar'
    options.reverse_merge! format: "%t |%B| %c/%C (+%R/s) | %a | %f", output: STDERR
    ProgressBar.create options
  end

  def self.to_csv(data, headers = nil)
    CSV.generate do |csv|
      if data.first.is_a?(Hash)
        headers ||= data.first.keys
        csv << headers
        data.each do |r|
          csv << r.values_at(*headers)
        end
      else
        headers ||= data.first
        data.each do |r|
          csv << r
        end
      end
    end
  end

  def self.gzip(data)
    string_io = StringIO.new
    gz = Zlib::GzipWriter.new(string_io)
    gz.write(data)
    gz.close

    string_io.string
  end

  def self.deprecation(msg)
    msg = "PANDORA DEPRECATION: #{msg} (see #{caller[1]})"
    if Rails.env.production?
      Rails.logger.warn(msg)
    else
      STDERR.puts msg
    end
  end

  def self.run(*args)
    ro, wo = IO.pipe
    re, we = IO.pipe
    result = system(*args, out: wo, err: we)
    we.close
    wo.close

    status = $?
    stdout = ro.read
    stderr = re.read

    unless result
      msg = "command '#{args}' failed with status code #{status.exitstatus}: #{stderr}"
      Rails.logger.error msg
    end

    stdout
  end

  def self.puts(*)
    Kernel.puts(*) unless ENV['PM_SILENT'] == 'true'
  end

  def self.printf(*)
    Kernel.printf(*) unless ENV['PM_SILENT'] == 'true'
  end

  def self.profile(&block)
    if block_given?
      RubyProf.start
      yield
    else
      if @profiling
        result = RubyProf.stop
        printer = RubyProf::FlatPrinter.new(result)
        printer.print(STDOUT)
      else
        @profiling = true
        RubyProf.start
      end
    end
  end
end
