Locale.set_base_language(DEFAULT_LOCALE)

Date::DATE_FORMATS.update(
  :default => lambda { |d| d.loc('%c').lstrip },
  :coarse  => lambda { |d| d.loc('%B %Y') }
)

Time::DATE_FORMATS.update(
  :default => lambda { |t| t.localtime.strftime('%c, %H:%M %Z').lstrip },
  :coarse  => lambda { |t| t.localtime.strftime('%B %Y') },
  :time    => lambda { |t| t.localtime.strftime('%H:%M %Z') }
)

if Rails.env.production?
  Pandora::REVISION = File.read(File.join(ENV['PM_ROOT'], 'REVISION'))
else
  Pandora::REVISION = `cd #{ENV['PM_ROOT']} && git rev-parse HEAD`.chomp
end

Dir["#{Rails.root}/lib/core_ext/**/*.rb"].sort.each { |ext| require ext }
