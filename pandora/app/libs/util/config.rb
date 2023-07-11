module Util
  module Config

    ###########################################################################
    protected
    ###########################################################################

    # Global config
    CONFIG = HashWithIndifferentAccess.new

    def self.init(base, *extensions)
      base_re = Regexp.escape(base)

      extensions.each { |ext|
        load_config = case ext.to_s
          when /(?:\A|\.)ya?ml\z/ then lambda { |config| YAML.load(config) }
          else raise ArgumentError, "extension '#{ext}' not supported"
        end

        ext_re = Regexp.escape(ext)

        Dir["#{base}/**/*#{ext}"].each { |file|
          CONFIG[file[%r{\A#{base_re}/(.*)#{ext_re}\z}, 1]] ||=
            load_config[ERB.new(File.read(file)).result(binding)]
        }
      }
    end

    module ClassMethods

      # REWRITE: renaming to avoid conflicts with rails config methods
      def pconfig
        klass = self

        begin
          if config = CONFIG[klass.name.underscore]
            return config
          end
        end while klass = klass.superclass

        raise ArgumentError, "no config for #{name}"
      end

    end

    # REWRITE: renaming to avoid conflicts with rails config methods
    def pconfig
      self.class.pconfig
    end

    ###########################################################################
    private
    ###########################################################################

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end
