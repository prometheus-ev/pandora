require 'i18n/backend/base'

I18n.available_locales = ['en', 'de']

# this pattern enables default patterns like "%{something}" but prevents
# matches for patterns we are using for
# ApplicationController#translate_with_link like "%{something}%"
I18n.config.interpolation_patterns = Regexp.union(
  /\%\{([^\}]+)\}(?!%)/
)

module I18n
  class PandoraExceptionHandler < ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
        msg = "translation not found for locale '#{locale}' and key '#{key}'"
        msg << " see #{caller[2]}"
        if ENV['PM_RAISE_TRANSLATIONS'] == 'true'
          raise Pandora::Exception, msg
        else
          if Rails.env.test?
            puts "WARNING: #{msg}"
          else
            Rails.logger.info "WARNING: #{msg}"
          end
        end

        key
      else
        super
      end
    end
  end
  
  module Backend
    class Pandora
      def self.cache
        @cache ||= JSON.parse(File.read "#{Rails.root}/config/locales/legacy.de.json")
      end
      
      def self.drop_cache!
        @cache = nil
      end

      def self.coverage=(old)
        @coverage = old
      end

      def self.coverage
        @coverage ||= {}
      end

      def self.coverage_setup
        file = "#{ENV['PM_ROOT']}/pandora/tmp/coverage/.translations.json"
        if File.exist?(file) && File.stat(file).mtime > 3600.seconds.ago
          puts "using existing translation coverage file"
          self.coverage = JSON.parse(File.read file)
        end
      end

      def self.coverage_report
        file = "#{ENV['PM_ROOT']}/pandora/tmp/coverage/.translations.json"
        system "mkdir -p #{File.dirname file}"
        File.open(file, 'w'){|f| f.write coverage.to_json}
        not_covered = cache.keys - coverage.keys

        report_file = "#{ENV['PM_ROOT']}/pandora/tmp/coverage/translations.txt"
        File.open report_file, 'w' do |f|
          f.write not_covered.sort.join("\n")
        end
        puts "%d/%d unused translations, find full list at %s" % [
          not_covered.size,
          cache.keys.size,
          report_file
        ]
      end

      include Base

      def lookup(locale, key, scope = [], options = {})
        if options[:globalize]
          if ENV['COVERAGE']
            self.class.coverage[key] ||= 0
            self.class.coverage[key] += 1
          end

          result = case locale
          when :de then self.class.cache[key]
          when :en
            if self.class.cache[key]
              key
            end
          else
            raise "unknown locale: #{locale}"
          end
          
          result
        end
      end
    end
  end
end

I18n.backend = I18n::Backend::Chain.new(
  I18n::Backend::Pandora.new,
  I18n.backend
)

I18n.exception_handler = I18n::PandoraExceptionHandler.new
