module Util
  module ActionApi
    module Controller
      def wadl
        self.class.load_all_controllers
        @api_formats = self.class.api_formats

        respond_to do |format|
          format.xml
        end
      end

      def api
        self.class.load_all_controllers
        @api_methods = self.class.api_methods
        @api_options = {api_version: DEFAULT_API_VERSION, locale: nil}
        @api_options = {locale: nil}
        @request_root = request.protocol + request.host_with_port
      end
    end

    module ClassMethods
      def api_method(action, methods = {})
        action, controller = action.to_sym, controller_name.underscore.to_sym

        if api_method?(action, controller)
          logger.warn "[ERROR] API method '#{controller}.#{action}' already defined!"
        end

        mhash = api_methods[controller][action]
        mhash[:skip_controller] = skip_controller = methods.delete(:skip_controller)

        methods.each do |method, mopts|
          mdoc = mopts[:doc]

          mparams = mopts[:expects] || {}
          mparams.each_value {|popts|
            popts.reverse_merge!(
              :style => 'query',
              :type => 'string'
            )
          }

          mhash[method] = fopts = {:doc => mdoc, :params => mparams}

          fopts[:formats] = mopts[:returns].each do |format, opts|
            opts ||= {}

            opts[:type] ||= "application/#{format}"
            opts[:type] << '/*' unless opts[:type].include?('/')

            api_formats[format][controller][action].update(
              method => opts.merge(fopts),
              :skip_controller => skip_controller
            )
          end
        end
      end

      def api_method?(action, controller = controller_name.underscore)
        api_methods.has_key?(controller = controller.to_sym) &&
          api_methods[controller].has_key?(action.to_sym)
      end

      def api_methods
        @api_methods ||= superclass.api_methods
      end

      def api_formats
        @api_formats ||= superclass.api_formats
      end
    end

    class << self
      protected

        def included(base)
          base.extend(ClassMethods)

          base.instance_variable_set('@api_methods', Hash.nest(2){{}})
          base.instance_variable_set('@api_formats', Hash.nest(3){{}})
        end
    end
  end
end
