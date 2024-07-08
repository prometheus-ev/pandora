# TODO, this is data, it could be moved to a JSON file

AUTHORS = [
  ['Lisa Dieckmann',    'lisa.dieckmann@uni-koeln.de',         nil,                 [nil, nil]],
  ['Jörg Koch',         'joerg.koch@uni-koeln.de',             nil,                 [Date.new(2013, 1), Date.new(2017, 2)], [Date.new(2019, 1), nil]],
  ['Sven Peter',        'sven.peter@uni-koeln.de',             nil,                 [Date.new(2017, 9), nil]],
  ['Moritz Schepp',     'schepp@wendig.io',                    'https://wendig.io', [Date.new(2018, 3), nil]]
].freeze

FORMER_AUTHORS = [
  ['Mihail Atanassov',  '', nil, [Date.new(2013, 1), Date.new(2017,  2)]],
  ['Lars Baehren',      '', nil, [Date.new(2012, 4), Date.new(2013,  1)]],
  ['Sebastian Beßler',  '', nil, [Date.new(2009, 7), Date.new(2010,  8)]],
  ['Thomas Bodo Block', '', nil, [Date.new(2007, 2), Date.new(2009,  3)]],
  ['Arne Eilermann',    '', nil, [Date.new(2008, 12), Date.new(2012, 1)], [Date.new(2013, 6), Date.new(2018, 2)]],
  ['Jens Wille',        '', nil, [nil, Date.new(2013,  1)]]
].freeze

LOCALES = {'en' => 'en-US', 'de' => 'de-DE'}.freeze


# Legacy settings, these just apply some cosmetic changes to some of the env
# vars. Do not change them here, instead use .env.defaults.

DEFAULT_LANGUAGE     = ENV['PM_DEFAULT_LOCALE']
DEFAULT_LOCALE       = LOCALES[DEFAULT_LANGUAGE]
ORDERED_LOCALES      = LOCALES.keys.sort
ALTERNATE_LOCALES    = Hash.new{|h, k| h[k] = ORDERED_LOCALES - [k]}
TRANSLATES_LANGUAGES = ALTERNATE_LOCALES[DEFAULT_LANGUAGE].freeze
ORDERED_LANGUAGES    = [DEFAULT_LANGUAGE, *TRANSLATES_LANGUAGES].freeze

TEXTAREA_SEPARATOR    = ENV['PM_TEXTAREA_CONNECTOR']
TEXTAREA_SEPARATOR_RE = Regexp.new(ENV['PM_TEXTAREA_SEPARATOR'])

MIN_RATING = ENV['PM_MIN_RATING'].to_i
MAX_RATING = ENV['PM_MAX_RATING'].to_i

TERMS_OF_USE_REVISION = ENV['PM_TERMS_OF_USE_REVISION'].to_i

LETTER_RE = Regexp.new(ENV['PM_LETTER_ONLY_REGEX'])
PRIORITY_COUNTRIES = ENV['PM_PRIORITY_COUNTRIES'].split('|')
DEFAULT_API_VERSION = ENV['PM_DEFAULT_API_VERSION']


# legacy functionality, should become obsolete with new frontend

GEOMETRY_FOR = Hash.new do |h, k|
  filename = File.join(Rails.root, 'public', 'images', k)
  out = `convert '#{filename}' -ping -format '%wx%h' info:`.split('x')
  h[k] = out.map(&:to_i)
end
