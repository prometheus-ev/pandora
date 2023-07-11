require "test_helper"

if ENV['PM_RETRY_TESTS']
  require 'minitest/retry'
  Minitest::Retry.use!
end

require 'webdrivers/chromedriver'

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  [
    'headless',
    'window-size=1280x960',
    'remote-debugging-address=0.0.0.0',
    'remote-debugging-port=9222'
  ].each{|a| options.add_argument(a)}

  # set download path
  path = Rails.root.join('tmp', 'test_downloads').to_s
  system "mkdir -p '#{path}'"
  options.add_preference(:download, {
    prompt_for_download: false, 
    default_directory: path
  })

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Selenium::WebDriver.logger.level = :error

Capybara.configure do |c|
  c.server_port = 47001

  # see https://github.com/teamcapybara/capybara/issues/2419
  c.default_set_options = {clear: :backspace}
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV['HEADLESS']
    driven_by :headless_chrome, screen_size: [1400, 1400]
  else
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end

  setup do
    ActionMailer::Base.deliveries.clear
    ActionController::Base.allow_forgery_protection = true
    close_other_tabs
  end

  teardown do
    ActionController::Base.allow_forgery_protection = false
  end
end
