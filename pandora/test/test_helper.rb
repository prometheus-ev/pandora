ENV['RAILS_ENV'] ||= 'test'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start 'rails' do
    merge_timeout 3600
    coverage_dir 'tmp/coverage'
    track_files '{app,lib}/**/*.{rb,rake}'
    add_filter 'vendor/nuggets/spec'
    add_filter 'app/libs/indexing/sources'
    add_filter 'lib/tasks'
  end

  puts "performing coverage analysis"
end

# after the test run, we generate the report for unused translations
if ENV['COVERAGE'] == 'true'
  at_exit do
    ::I18n::Backend::Pandora.coverage_report
  end
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'vcr'
require 'minitest/mock'

# VCR.configure do |config|
#   config.cassette_library_dir = "#{Rails.root}/test/vcr"
#   config.hook_into :webmock
#   config.allow_http_connections_when_no_cassette = true

#   config.ignore_request do |request|
#     uri = request.parsed_uri
#     ports = [9515, 9516, 47001]
#     uri.host == 'localhost' && ports.include?(uri.port) ||
#     uri.host == '127.0.0.1' && ports.include?(uri.port)
#   end
# end

Dir["#{Rails.root}/test/test_sources/*.rb"].each{|f| require f}

class ActiveSupport::TestCase
  # we load the existing translations coverage data if available and not
  # outdated
  if ENV['COVERAGE']
    I18n::Backend::Pandora.coverage_setup
  end

  DatabaseCleaner.clean_with :truncation
  DatabaseCleaner.clean

  system "rm -rf #{ENV['PM_ROOT']}/pandora/tmp/test"
  Pandora::ImagesDir.new.run

  load "#{Rails.root}/db/seeds.rb"
  load "#{Rails.root}/test/test_data.rb"

  # snapshot images directory
  backup_dir = "#{ENV['PM_ROOT']}/pandora/tmp/test.backup"
  system "rm -rf #{backup_dir}"
  system "cp -a #{ENV['PM_ROOT']}/pandora/tmp/test #{backup_dir}"

  self.use_transactional_tests = true

  File.truncate "#{Rails.root}/log/test.log", 0

  setup do
    I18n.locale = :en

    # dropping non-default indices
    names = Pandora::Elastic.new.aliases - ['daumier', 'robertin']
    Indexing::IndexTasks.new.drop(names) unless names.empty?

    # TODO see https://github.com/rails/rails/issues/37270
    (ActiveJob::Base.descendants << ActiveJob::Base).each do |job_class|
      job_class.disable_test_adapter
    end

    Pandora::Elastic.new.destroy_all
  end

  # def around(&block)
  #   DatabaseCleaner.clean do
  #     yield
  #   end
  # end

  def reload_page
    page.evaluate_script("window.location.reload()")
  end

  def restore_images_dir
    system "rm -rf #{ENV['PM_ROOT']}/pandora/tmp/test"
    system "cp -a #{ENV['PM_ROOT']}/pandora/tmp/test.backup #{ENV['PM_ROOT']}/pandora/tmp/test"
  end

  def save_html
    File.open 'tmp/test.html', 'w' do |f|
      f.write page.body
    end
  end

  def login_as(user, password = nil, stay = false)
    password = password || (user.size >= 8 ? user : user * 2)

    if respond_to?(:visit)
      # capybara
      visit '/en/login'
      within '#login_wrap' do
        fill_in 'User name or e-mail address', with: user
        fill_in 'Password', with: password
        check 'Stay logged in' if stay
        submit
      end
    else
      # integration test
      post '/en/create', params: {login: user, password: password}
    end
  end

  def logout
    click_on 'Log out'
  end

  def api_auth(user, password = nil)
    password = password || (user.size >= 8 ? user : user * 2)
    data = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
    {'Authorization' => data}
  end

  def xml
    Hash.from_xml(response.body)
  end

  def json
    JSON.parse(response.body)
  end

  def change_locale(locale)
    target = current_url.gsub(/\/(de|en)(\/|$)/, "/#{locale}\\2")
    visit target
  end

  def links_from_email(email)
    body = !email.body.multipart? ? email.body : email.body.parts.find{ |p|
      p.content_type.match?(/^text\/plain/)
    }
    body.to_s.scan(/http[^\n> ]+/).map{|l| l.gsub(/=0D/, '')}
  end

  def link_from_email(email)
    links_from_email(email)[0].strip
  end

  def submit(text = nil)
    button = find('.submit_button', text: text, exact_text: true)
    scroll_to button
    button.click
  end

  def click_submenu(text)
    find('#submenu a', exact_text: text).click
  end

  def click_submenu_button(text)
    find('#submenu .button_wrap', text: text).click
  end

  def open_section(id)
    if has_css?("##{id}-section .expand")
      find("##{id}-section .expand").click
    end
  end

  def within_admin_section(label, &block)
    section = find('h3', text: label).find(:xpath, '..')
    within section, &block
  end

  def within_upper_list_controls(&block)
    controls = all('.list_controls', count: 2)[0]
    within controls, &block
  end

  def answer_brain_buster
    # sometimes the captcha has been passed in an earlier test and that gets
    # carried over in a cookie so that the captcha doesn't show anymore
    if page.has_css? '#captcha'
      question = find('#captcha label').text
      answer = BrainBuster.find_by!(question: question).answer
      fill_in question, with: answer
    end
  end

  # def with_vcr(cassette)
  #   # VCR.use_cassette cassette, record: :new_episodes do
  #   VCR.use_cassette cassette do
  #     yield
  #   end
  # end

  def with_locale(locale)
    old = I18n.locale
    I18n.locale = locale
    yield
    I18n.locale = old
  end

  def with_translations_raised
    with_env 'PM_RAISE_TRANSLATIONS' => 'true' do
      yield
    end
  end

  def with_real_images
    with_env 'PM_USE_TEST_IMAGE' => 'false' do
      yield
    end
  end

  def with_all_synonyms
    with_env 'PM_SYNONYMS_DIR' => '/vagrant/pandora/config/synonyms/' do
      yield
    end
  end

  def with_env(overrides = {})
    old = {}
    overrides.each do |key, value|
      old[key] = ENV[key]
      ENV[key] = value
    end
    yield
    overrides.each do |key, value|
      ENV[key] = old[key]
    end
  end

  def close_other_tabs
    window = page.driver.browser.window_handles
    if window.size > 1
      window[1..-1].each do |tab|
        page.driver.browser.switch_to.window(tab)
        page.driver.browser.close
      end
      switch_to_tab 0
    end
  end

  def switch_to_tab(i)
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window[i])
  end

  def close_tab(i = nil)
    switch_to_tab(i) if i != nil
    page.driver.browser.close
  end

  def back
    page.evaluate_script('window.history.back()')
  end

  def create_upload(file, options = {})
    if file.is_a?(Rack::Test::UploadedFile)
      options[:file] = file
    else
      options.reverse_merge!(
        title: file.humanize.capitalize,
        file: Rack::Test::UploadedFile.new(
          "#{Rails.root}/test/fixtures/files/#{file}.jpg",
          'image/jpeg'
        )
      )
    end

    options.reverse_merge!(
      database: Account.find_by!(login: 'jdoe').database,
      rights_reproduction: 'None, do not use!',
      rights_work: 'None, do not use!',
      add_to_index: true
    )

    Upload.create!(options)
  end

  def without_forgery_protection
    old = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = false
    yield
    ActionController::Base.allow_forgery_protection = old
  end


  # The following helpers only work for integration tests, not with capybara

  def assert_ok
    assert_equal 200, response.status
  end

  def assert_access_denied
    assert_equal 302, response.status

    assert Array.wrap(flash[:warning]).any? do |m|
      m.match(/You don't have privileges to access this/)
    end
  end

  def assert_login_prompt
    assert_equal 302, response.status

    assert Array.wrap(flash[:prompt]).any? do |m|
      m.match(/Please log in first/)
    end
  end

  def assert_same_elements expected, actual
    assert_equal expected.to_ary.sort, actual.to_ary.sort
  end

  def campus_login
    get '/en/campus', params: {'accepted' => 1}

    if response.redirect? # cookies enabled check
      follow_redirect!
      follow_redirect!
    end
  end

  def db_login(source)
    get "/en/sources/#source/open_access"
    patch '/en/terms', params: {accepted: 1}
  end

  def elastic
    @elastic ||= Pandora::Elastic.new
  end

  def require_test_sources
    Dir["#{Rails.root}/test/test_sources/*.rb"].each{ |file| require file }
  end

  def pid_for(id, source_id = 'test_source')
    Pandora::SuperImage.pid_for(source_id, id)
  end

  def elastic
    Pandora::Elastic.new
  end

  def stats_data
    # parse log files
    cache = Pandora::LogCache.new
    file = "#{ENV['PM_ROOT']}/pandora/test/fixtures/files/production.log.gz"
    requests = Pandora::LogParser.parse(file, progress: false)
    cache.add requests
    cache.finalize

    # generate sum stats records
    sum_stats = Pandora::SumStats.new(
      Date.new(2018,12,1),
      Date.new(2019,2,28)
    )
    sum_stats.aggregate

    # generate top terms cache
    sum_stats.cache_top_terms
  end

  def stub_const(name, value, &block)
    begin
      old = Object.const_get(name)
      without_warnings do
        Object.const_set(name, value)
      end
      yield
    ensure
      without_warnings do
        Object.const_set(name, old)
      end
    end
  end

  def without_warnings(&block)
    old = $VERBOSE
    $VERBOSE = nil
    yield
    $VERBOSE = old
  end

  def dimensions_for(data)
    file = "#{Rails.root}/tmp/test/buffer.image"
    File.open file, 'w' do |f|
      f.write data
    end
    stdout = Pandora.run 'identify', '-format', '%wx%h', file
    File.unlink file
    w, h = stdout.split('x').map{|e| e.to_i}
    {width: w, height: h}
  end

  def mime_type_for(file)
    stdout = Pandora.run('file', '--mime-type', '-b', file)
    stdout.strip
  end

  # Announcement helper methods

  def valid_announcement
    announcement = Announcement.new(
      title_de: 'Deutscher Titel',
      title_en: 'English title',
      body_de: 'Deutscher Nachrichtentext.',
      body_en: 'English message body',
      starts_at: Time.now - 3.days,
      ends_at: Time.now + 3.days,
      role: 'users'
    )
  end

  def populate_announcements
    6.times.map { |i|
      n = valid_announcement

      if i == 0 || i == 1
        n.starts_at = Time.now - 9.days
        n.ends_at = Time.now - 3.days
      elsif i == 2 || i == 3
        n.starts_at = Time.now - 3.days
        n.ends_at = Time.now + 3.days
      else
        n.starts_at = Time.now + 3.days
        n.ends_at = Time.now + 3.days
      end
      n.title_de = n.title_de + " #{i}"
      n.title_en = n.title_en + " #{i}"
      n.save
    }
  end

  # institutional uploads helpers

  def institutional_upload_source(admins, institution = nil)
    institution ||= Institution.find_by!(name: "prometheus")

    Source.create!(
      name: institution.name,
      title: institution.name.titleize,
      kind: "Institutional database",
      type: "upload",
      institution: institution,
      owner: institution,
      keywords: [Keyword.find_by!(title: 'Institutional Upload')],
      quota: Institution::DEFAULT_DATABASE_QUOTA,
      source_admins: admins
    )
  end

  def institutional_upload(source, filename, options = {})
    options.reverse_merge!(
      database: source,
      title: filename.humanize.capitalize,
      rights_reproduction: 'None, do not use!',
      rights_work: 'None, do not use!',
      keywords: [Keyword.new(title: 'One'), Keyword.new(title: 'Two')],
      file: Rack::Test::UploadedFile.new(
        "#{Rails.root}/test/fixtures/files/#{filename}.jpg",
        'image/jpeg'
      ),
      add_to_index: true
    )

    upload = Upload.create!(options)
    upload.index_doc
    upload
  end
end
