module Util

  module ActiveCrypter

    module ClassMethods

      def encrypts(*fields)
        options = fields.extract_options!

        key, iv = options[:with]

        if key
          raise TypeError, "key: Symbol expected, got #{key.class}" unless key.is_a?(Symbol)
          raise ArgumentError, "undefined constant: #{key}" unless const_defined?(key)
        else
          raise ArgumentError, 'key required'
        end

        if iv
          raise TypeError, "iv: Symbol expected, got #{iv.class}" unless iv.is_a?(Symbol)
          raise ArgumentError, "no such method: #{iv}" unless has_column?(iv) || instance_methods.include?(iv.to_s)
        else
          iv = :salt
        end

        fields.each { |field|
          class_eval <<-EOS, __FILE__, __LINE__ + 1
            def #{field}                                       # def secret
              decrypt(self[:#{field}], #{iv}, #{key})          #   decrypt(self[:secret], key, OAUTH_SECRET)
            end                                                # end
                                                               #
            def #{field}=(value)                               # def secret=(value)
              self[:#{field}] = encrypt(value, #{iv}, #{key})  #   self[:secret] = encrypt(value, key, OAUTH_SECRET)
            end                                                # end
          EOS
        }
      end

    end

    ###########################################################################
    private
    ###########################################################################

    def self.included(base)
      base.extend(ClassMethods)
      base.send :include, Util::Crypter
    end

  end

end
