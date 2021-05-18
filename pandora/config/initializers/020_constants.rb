# Be sure to restart your server when you modify this file.

###############################################################################
unless Object.const_defined?(:HOME_URL)
###############################################################################

AUTHORS = [
  ['Lisa Dieckmann',    'lisa.dieckmann@uni-koeln.de',         nil,                 [nil, nil]],
  ['Jörg Koch',         'joerg.koch@uni-koeln.de',             nil,                 [Date.new(2013, 1), Date.new(2017,  2)], [Date.new(2019, 1), nil]],
  ['Sven Peter',        'sven.peter@uni-koeln.de',             nil,                 [Date.new(2017, 9), nil]],
  ['Moritz Schepp',     'schepp@wendig.io',                    'https://wendig.io', [Date.new(2018, 3), nil]]
].freeze

FORMER_AUTHORS = [
  ['Mihail Atanassov',  '', nil, [Date.new(2013, 1), Date.new(2017,  2)]],
  ['Lars Baehren',      '', nil, [Date.new(2012, 4), Date.new(2013,  1)]],
  ['Sebastian Beßler',  '', nil, [Date.new(2009, 7), Date.new(2010,  8)]],
  ['Thomas Bodo Block', '', nil, [Date.new(2007, 2), Date.new(2009,  3)]],
  ['Arne Eilermann',    '', nil, [Date.new(2008, 12), Date.new(2012,  1)], [Date.new(2013,  6), Date.new(2018, 2)]],
  ['Jens Wille',        '', nil, [nil, Date.new(2013,  1)]]
].freeze

# NOTE: The file 'config/secrets.yml' *must not* be
# version-controlled, nor be accessible on the web!
SECRETS = if File.readable?(sec = File.join(Rails.root, 'config', 'secrets.yml'))
  # the file now comes with rails and defines several environments. Therefore,
  # we load the specific environment instead of the file's root
  # YAML.load_file(sec). Also, we make it indifferent access. We also load
  # the now shared section, we also pass the file through ERB.
  data = YAML.load(ERB.new(File.read sec).result)
  if data['shared']
    data['shared'].merge(data[Rails.env.to_s] || {}).with_indifferent_access
  else
    data[Rails.env.to_s].with_indifferent_access
  end
else
  warn "config file for secrets not found: #{sec}"
  Hash.new('')  # default to empty string!?
end.freeze

# REWRITE: pull this from dotenv instead
# HOME_URL = 'http://prometheus-bildarchiv.de'.freeze
HOME_URL = ENV['PM_HOME_URL'].dup.freeze

INFO_ADDRESS   = ENV['PM_INFO_ADDRESS'].dup.freeze
DEVEL_ADDRESS  = ENV['PM_DEV_ADDRESS'].dup.freeze
SENDER_ADDRESS = INFO_ADDRESS.dup.freeze
SENDER_ADDRESS_NEWSLETTER = ENV['PM_NEWSLETTER_SENDER'].dup.freeze

HTTP_S_SCHEME = Rails.env.production? ?
  'https'.freeze :
  'https'.freeze

LOCALES = { 'en' => 'en-US', 'de' => 'de-DE' }.freeze

DEFAULT_LANGUAGE     = 'en'.freeze
DEFAULT_LOCALE       = LOCALES[DEFAULT_LANGUAGE]
ORDERED_LOCALES      = LOCALES.keys.sort
ALTERNATE_LOCALES    = Hash.new { |h, k| h[k] = ORDERED_LOCALES - [k] }
TRANSLATES_LANGUAGES = ALTERNATE_LOCALES[DEFAULT_LANGUAGE].freeze
ORDERED_LANGUAGES    = [DEFAULT_LANGUAGE, *TRANSLATES_LANGUAGES].freeze
TRANSLATIONS_KEY     = '_translations'.freeze

NAVIGATION_DEFAULT = Hash.new('administration').update(
  'image'                     => [:top, 'searches'],
  'syntax'                    => 'searches',
  'results'                   => 'searches',
  'copyright_and_publication' => 'searches',
  'button_legend'             => nil,
  'pandora'                   => nil,
  'js'                        => nil
).freeze

GEOMETRY_FOR = Hash.new do |h, k|
  filename = File.join(Rails.root, 'public', 'images', k)
  out = `convert '#{filename}' -ping -format '%wx%h' info:`.split('x')
  h[k] = out.map(&:to_i)
end

CREATE_ACTIONS = [
  :create, :new
].freeze

# REWRITE: this is only used in the routes file, so moving it there
# PANDORA_ACTIONS = [
#   :start, :about, :facts, :back, :sitemap, :feedback,
#   :remote_ip, :api, :conference_sign_up, :conference_sign_up_confirmation
# ]

# REWRITE: refactor this
# "administrative" AccountController actions
ADMINISTRATIVE_ACTIONS = [
  :login, :campus, :terms_of_use,
  :signup, :confirm_email, :password, :logout,
  :subscribe, :confirm_subscription,
  :unsubscribe, :confirm_unsubscription
].freeze

# FLASH_MESSAGES = [
#   # REWRITE: this is only used once and the values have to be strings now since
#   # the flash keys are also strings as far as FLASH_MESSAGES & flash.keys are
#   # concerned
#   # :warning, :prompt, :notice, :info
#   'warning', 'prompt', 'notice', 'info', 'error'
# ].freeze

# This is how lines are separated in textareas
# (Across all browsers and platforms?)
TEXTAREA_SEPARATOR    = "\r\n".freeze
TEXTAREA_SEPARATOR_RE = /\r?\n/.freeze

TERM_SEPARATOR = ' | '.freeze

SORT_DIRECTIONS   = %w[ASC DESC].freeze
DEFAULT_DIRECTION = 'ASC'.freeze

MIN_RATING = 1
MAX_RATING = 5

# Includes Latin1 letters (UTF-8)
# TODO: does this work?
# LETTER_RE = %r{(?:[A-Za-z]|\xc3[\x80-\xb6\xb8-\xbf])}
LETTER_RE = %r{(?:[A-Za-z]|[\u00C0-\u00F6\u00F8-\u00FF])}

# Will be listed separately above the (long) country list
PRIORITY_COUNTRIES = %w[Germany Austria Switzerland France Italy Spain United\ States].freeze

# REWRITE: we don't use this anymore, there is a rails configuration option
# for this now
# TRUSTED_PROXIES = File.readable?(tpr = File.join(Rails.root, 'config', 'trusted_proxies.yml')) ?
#   YAML.load_file(tpr) : []

VENDOR_FONTS = Dir[File.join(Rails.root, %w[vendor fonts *])]

# NOTE: don't modify; keep on *one* line!
TERMS_OF_USE_REVISION = 5
# TERMS_OF_USE_DATE = Time.utc(0, 0, 0, 24, 5, 2018, 2, 91, false, "UTC")  # Thu May 24 00:00:00 UTC 2018

DEFAULT_API_VERSION = 'v1'.freeze

DEFAULT_CLEANUP_DURATION = '1 week'.freeze

###############################################################################
end
###############################################################################
