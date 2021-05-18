module Util

  module SQL

    extend self

    def sql_false_condition
      '0 = 1'
    end

    def sql_in(column, args)
      if column !~ /\./ && respond_to?(:quoted_table_name)
        column = "#{quoted_table_name}.#{column}"
      end

      # REWRITE: this has to be an array not to crash the iteration
      args = [args] unless args.is_a?(Array)

      "#{column} IN (#{args.map { |arg| sql_quote(arg) }.join(',')})"
    end

    def sql_for(column, *args)
      mangle_sql_args!(args) { |args, options|
        args.map { |arg|
          arg = yield(arg) if block_given?
          "#{column} #{arg.nil? ? 'IS' : '='} #{sql_quote(arg)}"
        }.join(" #{options[:op] || 'OR'} ")
      }
    end

    def sql_and(*args)
      mangle_sql_args!(args, :op => 'AND')
      sql_join(*args)
    end

    def sql_or(*args)
      mangle_sql_args!(args, :op => 'OR')
      sql_join(*args)
    end

    ###########################################################################
    private
    ###########################################################################

    def sql_quote(arg)
      # REWRITE: has been moved to the connection
      # ActiveRecord::Base.quote_value(arg)
      ActiveRecord::Base.connection.quote(arg)
    end

    def sql_join(*args)
      mangle_sql_args!(args) { |args, options|
        args.map { |arg|
          arg.parenthesize unless arg.blank?
        }.compact.join(" #{options[:op] || 'AND'} ")
      }
    end

    def mangle_sql_args!(args, override_options = {})
      options = args.extract_options!.merge(override_options)

      result = yield(args, options) if block_given?

      args << options

      result
    end

    def self.included(base)
      base.extend(self)
    end

  end

end
