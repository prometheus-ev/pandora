module Util
  module Config
    # Global config
    CONFIG = HashWithIndifferentAccess.new

    def self.init(base, *extensions)
      base_re = Regexp.escape(base)

      extensions.each do |ext|
        load_config = case ext.to_s
        when /(?:\A|\.)ya?ml\z/
          lambda{|config| YAML.load(config)}
        else
          raise ArgumentError, "extension '#{ext}' not supported"
        end

        ext_re = Regexp.escape(ext)

        Dir["#{base}/**/*#{ext}"].each do |file|
          CONFIG[file[%r{\A#{base_re}/(.*)#{ext_re}\z}, 1]] ||=
            load_config[ERB.new(File.read(file)).result(binding)]
        end
      end
    end

    module ClassMethods
      # REWRITE: renaming to avoid conflicts with rails config methods
      def pconfig
        klass = self

        loop do
          if config = CONFIG[klass.name.underscore]
            return config
          end

          break unless klass = klass.superclass
        end

        raise ArgumentError, "no config for #{name}"
      end
    end

    # REWRITE: renaming to avoid conflicts with rails config methods
    def pconfig
      self.class.pconfig
    end


    class << self
      private

        def included(base)
          base.extend(ClassMethods)
        end
    end
  end
end
