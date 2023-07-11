require 'dotenv'

# this is just for rack-images because it is not environment aware yet
current_env = if defined?(Rails)
  Rails.env
else
  ENV['RAILS_ENV'] || 'development'
end

# we set the root and pass it on to the .env files so that we can use PM_ROOT
# there
dotenv_root = File.expand_path(__dir__)
ENV['PM_ROOT'] = dotenv_root

Dotenv.load(
  "#{dotenv_root}/.env.#{current_env}",
  "#{dotenv_root}/.env",
  "#{dotenv_root}/.env.defaults"
)

required = [
  'PM_ASD_SECRET',
  'PM_ASD_LIFETIME',
  'PM_BASE_URL',
  'PM_BRAIN_BUSTER_SALT',
  'PM_DEV_ADDRESS',
  'PM_DUMPS_DIR',
  'PM_ELASTIC_URI',
  'PM_HOME_URL',
  'PM_IMAGES_DIR',
  'PM_INDEX_PACK_DIR',
  'PM_VECTORS_DIR',
  'PM_INFO_ADDRESS',
  'PM_INVOICE_NOTIFICATION_RECIPIENTS',
  'PM_LOG_ARCHIVE_DIR',
  'PM_LOGOUT_URL',
  'PM_MAX_PER_PAGE',
  'PM_NEWSLETTER_SENDER',
  'PM_OAUTH_SECRET',
  'PM_ORIGINALS_DIR',
  'PM_ORIGINALS_YML_DIR',
  'PM_PANDORA_COOKIE_SECRET',
  'PM_PAYPAL_SANDBOX',
  'PM_PAYPAL_SELLER_ID',
  'PM_PRESENTATIONS_DIR',
  'PM_RACK_IMAGES_BASE_URL',
  'PM_STATS_DIR',
  'PM_SYNONYMS_DIR'
]

required.each do |k|
  unless ENV.has_key?(k)
    raise StandardError, "configuration #{k} needs to be set"
  end
end

if current_env == 'test'
  required_testing = [
    'PM_PAYPAL_BUYER_ID',
    'PM_PAYPAL_BUYER_PASSWORD'
  ]

  required.each do |k|
    unless ENV.has_key?(k)
      raise StandardError, "configuration #{k} needs to be set (only required for testing)"
    end
  end
end
