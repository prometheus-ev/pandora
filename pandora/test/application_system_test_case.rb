require "test_helper"

if ENV['PM_RETRY_TESTS']
  require 'minitest/retry'
  Minitest::Retry.use!
end

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument 'window-size=1280x960'

# set download path
path = Rails.root.join('tmp', 'test_downloads').to_s
system "mkdir -p '#{path}'"
options.add_preference(:download, {
  prompt_for_download: false,
  default_directory: path
})

Capybara.register_driver :headless_chrome do |app|
  options.add_argument 'headless'

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :chrome do |app|
  path = '/usr/bin/chromium'
  if File.exist?(path)
    options.binary = path
  end

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
    driven_by :headless_chrome
  else
    driven_by :chrome
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
