require 'bundler'
Bundler.setup

require 'rack_images'
require 'rack/cors'

use Rack::CommonLogger, RackImages::Server.logger

# Use Rack::Cors to allow cross-origin requests from the prometheus app
# https://rubygems.org/gems/rack-cors
if ENV['PM_ALLOW_CORS'] == "true"
  use Rack::Cors do
    allow do
      origins ENV['PM_ALLOW_CORS_ORIGIN']
      resource '*', headers: :any, methods: [:get]
    end
  end
end

run RackImages::Server
