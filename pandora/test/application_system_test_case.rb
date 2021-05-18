require "test_helper"

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
  path = Rails.root.join('tmp', 'test_downloads')
  system "mkdir -p '#{path}'"
  options.add_preference 'download.default_directory', path

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.server_port = 47001
Selenium::WebDriver.logger.level = :error

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV['HEADLESS']
    driven_by :headless_chrome, screen_size: [1400, 1400]
  else
    driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  end

  def setup
    ActionController::Base.allow_forgery_protection = true
    close_other_tabs
  end

  def teardown
    ActionController::Base.allow_forgery_protection = false
  end
end
