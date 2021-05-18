Gem::Specification.new do |s|
  s.name        = 'rack-images'
  s.version     = '1.0.0'
  s.licenses    = ['GPL-3.0-or-later']
  s.summary     = "Image delivery for the Prometheus Image Archive"
  s.authors     = ["Moritz Schepp <moritz.schepp@google.com>"]
  s.files       = Dir['lib/**/*.rb'] +
                  Dir['apache_secure_download/lib/**/*.rb']

  s.add_runtime_dependency 'rack', '~> 2.2.2'
  s.add_runtime_dependency 'rack-cors', '~> 1.1.1'
  s.add_runtime_dependency 'dotenv', '~> 2.7.5'
  s.add_runtime_dependency 'puma'

  s.add_development_dependency 'pry'
end