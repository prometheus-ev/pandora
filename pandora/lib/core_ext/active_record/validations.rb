module ActiveRecord

  class Errors
    DEFAULT_ILLEGAL = '__ILLEGAL__'
  end

  module Validations

    module ClassMethods

      def validates_legality_of(*attr_names)
        configuration = {
          # REWRITE: its on: nil now but this has aparently not been used in pandora
          # :on      => :save,
          :illegal => ActiveRecord::Errors::DEFAULT_ILLEGAL,
          :message => :invalid
        }.merge(attr_names.extract_options!)

        illegal, as, scrub = configuration.values_at(:illegal, :as, :scrub)

        validates_each(attr_names, configuration) { |record, attr_name, value|
          value = as.respond_to?(:call) ? as.call(value) : value.send(as) if as

          if illegal.is_a?(Array) ? illegal.include?(value) : illegal === value
            record.errors.add(attr_name, configuration[:message])

            if configuration.has_key?(:scrub)
              if scrub.respond_to?(:call)
                scrub.call(record, attr_name, value)
              else
                record[attr_name] = scrub
              end
            end
          end
        }
      end

      def validates_as_email(*attr_names)
        # REWRITE: its on: nil now but this has aparently not been used in pandora
        # configuration = { :on => :save }
        configuration = {}
        configuration.update(attr_names.extract_options!)

        raise ArgumentError, 'custom error messages are not supported, sorry' if configuration[:message]

        validates_each(attr_names, configuration) { |record, attr_name, value|
          # Util::Email does a DNS lookup for the domain which raises an
          # exeception when umlauts are present in the domain name
          idna = Pandora.run('idn', '--no-tld', value.to_s).strip
          if idna != value.to_s
            record.errors.add(attr_name, 'should not contain special characters'.t)
          else
            begin
              Util::Email.valid!(value.to_s)
            rescue Util::Email::EmailError => err
              record.errors.add(attr_name, err.msg)
            end
          end
        }
      end

      def validates_as_emails(*attr_names)
        # REWRITE: its on: nil now but this has aparently not been used in pandora
        # configuration = { :on => :save }
        configuration = {}
        configuration.update(attr_names.extract_options!)

        raise ArgumentError, 'custom error messages are not supported, sorry' if configuration[:message]

        exceptions   = configuration.delete(:except) || []
        exception_re = configuration.delete(:except_re)

        validates_each(attr_names, configuration) { |record, attr_name, values|
          (values - exceptions).each { |value|
            value = value.to_s

            unless exception_re && value =~ exception_re
              begin
                Util::Email.valid!(value)
              rescue Util::Email::EmailError => err
                record.errors.add(attr_name, err.msg)
              end
            end
          }
        }
      end

    end

  end

end
