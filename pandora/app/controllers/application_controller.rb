class ApplicationController < ActionController::Base
  if Rails.env.production?
    rescue_from StandardError, with: :internal_server_error

    protect_from_forgery with: :null_session
  else
    protect_from_forgery with: :exception
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  include OauthSystem
  include Util::ActionAPI
  # REWRITE: we include this ourselves now, without calling the gem's init.rb
  include BrainBusterSystem

  layout :determine_layout

  # REWRITE: we add this only if there are recipients configured
  if ENV['PM_EXCEPTION_RECIPIENTS'].present?
    before_action :prepare_exception_notifier
  end

  # if Rails.env.development?
  #   around_action :profiler
  #   def profiler
  #     profiler = MethodProfiler.observe(Pandora::SuperImage)
  #     yield
  #     puts profiler.report.sort_by(:total_time)
  #   end
  # end

  before_action :set_frontend
  before_action :refresh_translation_cache
  before_action :log_user
  # before_action :set_api_version
  before_action :store_request
  before_action :set_locale
  before_action :set_url_options
  before_action :store_location,   :except => [:suggest_keywords, :delete]
  before_action :login_required
  before_action :verify_account_signup_complete
  before_action :verify_account_email
  before_action :verify_account_active
  before_action :verify_account_not_deactivated
  before_action :verify_account_terms_accepted
  before_action :limit_request_rate

  # REWRITE: refactor this, it can probably be done entirely in the routes file
  DEFAULT_LOCATION = {
    :start    => { :controller => 'searches' },
    :admin    => { :controller => 'administration' },
    :redirect => { :controller => 'sessions', :action => 'new' },

    # custom start pages
    'search'             => { :controller => 'searches' },
    'advanced_search'    => { :controller => 'searches', :action => 'advanced' },
    'collections'        => { :controller => 'collections' },
    'public_collections' => { :controller => 'collections', :action => 'public' },
    'administration'     => { :controller => 'administration' },
    'accounts'           => { :controller => 'accounts' }
  }.freeze

  UNSAFE_OPTIONS = ActionDispatch::Routing::RouteSet::RESERVED_OPTIONS - [:anchor]

  # Accept-Language: de, en-gb;q=0.8, en;q=0.7
  HAL_RE = %r{(?:\A|,)\s*(\w+)(?:[-;,]|\z)}

  helper_method :root_url, :home_url, :public_path_for, :default_location,
                :back_or_default, :safe_params, :count_for_section, :section_partial,
                :section_id, :restrict_to, :page, :per_page,
                :view, :sort_column, :sort_direction, :sort_inverse,
                :current_user, :search_column, :zoom, :pm_labelled_counter,
                :admin_or_superadmin?


  def self.initialize_me!  # :nodoc:
    unless name == 'ApplicationController'
      raise 'ILLEGALLY CALLED BY CHILD CLASS %s -- GO WRITE YOUR OWN!' / name
    end
  end

  def self.inherited(klass)
    super
    klass.send :include, ControllerMethods
  end

  def self.load_all_controllers
    unless name == 'ApplicationController'
      return superclass.load_all_controllers
    else
      return if @_loaded_all_controllers
      @_loaded_all_controllers = true
    end

    # REWRITE: this is done via the Rails module now
    # (Dir["#{RAILS_ROOT}/app/controllers/*.rb"].map { |controller|
    (Dir["#{Rails.root}/app/controllers/*.rb"].map { |controller|
      File.basename(controller, '.rb').classify
    } - subclasses - %w[ApplicationController]).each { |klass|
      begin
        klass.constantize
      rescue NameError, LoadError
      end
    }
  end

  def self.allow_open_access(open_actions, other_actions, &block)
    skip_before_action :login_required,    :only => open_actions + other_actions
    before_action      :allow_open_access, :only => open_actions

    define_method(:source_for_open_access, &block)
    private :source_for_open_access
  end

  def self.model_name
    @model_name ||= name.sub(/Controller\z/, '').underscore
  end

  attr_writer :model_name

  def self.model_class
    model_name.classify.constantize
  end


  protected

    def current_user
      @current_user ||= cookie_user || begin
        user = remembered_user || token_user || basic_user || oauth_user

        # so if a user was found by other means than the session cookie, we
        # need to log him in so that the session cookie is set. However, if the
        # user is an email subscriber, we don't log him in, because we don't
        # want any authrozation rules to kick in.
        if user && !user.subscriber?
          log_in(user)

          link = helpers.link_to(user.fullname.presence || user.login, profile_path)
          flash[:notice] = 'Welcome, %s!' / link
        end
        user
      end
    end

    def cookie_user
      return nil unless session[:account_id]

      @cookie_user ||= Account.find_by(id: session[:account_id])
    end

    def remembered_user
      token = cookies[:auth_token]
      return nil unless token

      @remembered_user ||= Account.find_by(remember_token: token)
    end

    def token_user
      return @token_user if @token_user_checked

      if params[:login] && params[:timestamp] && params[:token]
        @token_user = Account.authenticate_from_token(params[:login], params[:timestamp], params[:token]) do |user, link_expired, matching_token|
          authenticate_from_token_warnings(user, link_expired, matching_token)
        end
      end
      @token_user_checked = true

      @token_user
    end

    def basic_user
      @current_basic_user ||= try_basic_auth
    end

    def try_basic_auth
      user, pass = request.basic_auth

      if user
        account = Account.find_by_login_or_email(user)

        unless account
          render_basic_auth
          return
        end

        if account.banned?
          render_banned(account)
          return
        end

        unless account.password_matches?(pass)
          account.log_failed_login!
          render_basic_auth
          return
        end

        account
      end
    end

    def api_request?
      request.path.match?(/^\/(api|pandora\/api)\//)
    end

    # needs to be refactored to allow more uniform calls
    def oauth_user
      return nil unless api_request? # && request.api?

      @oauth_done ||= begin
        oauthenticate
        true
      end

      @current_oauth_user
    end

    def control_access
      permission_denied unless permit?(self.class.access_control(action_name))
    end

    def permission_denied(warning = nil)
      respond_to do |format|
        format.html do
          link = helpers.link_to(human_location, request.path)
          flash[:warning] = [
            "You don't have privileges to access this %s." / link,
            'Please log in with a qualified account.'.t
          ].join(' ').html_safe

          redirect_to login_path
        end
      end

      false
    end

    def login_required
      access_denied unless current_user
    end

    def access_denied
      respond_to do |format|
        format.json do
          response.headers['WWW-Authenticate'] = 'Basic realm="prometheus image archive"'
          render json: {message: 'Please log in first'.t}, status: 401
        end
        format.xml do
          response.headers['WWW-Authenticate'] = 'Basic realm="prometheus image archive"'
          render xml: {message: 'Please log in first'.t}, status: 401
        end
        format.blob do
          render body: nil, status: 401
        end
        format.js do
          url = url_for(controller: 'sessions', action: 'new')
          render(
            plain: "location.href = '#{url}'",
            content_type: 'text/javascript'
          )
        end
        format.any(:html, :zip) do
          # flash.keep

          link = helpers.link_to human_location, request.path
          flash[:prompt] = [
            'Please log in first.'.t,
            'You will then be redirected to the requested %s.' / link
          ].join(' ').html_safe

          # only pass return_to if the current url is at all different from
          # the root url
          rt = (request.url == locale_root_url ? nil : request.url)
          redirect_to controller: 'sessions', action: 'new', return_to: rt
        end
      end
    end

    def not_found
      respond_to do |format|
        format.html do
          @no_submenu = true

          render(
            template: 'shared/misc/_not_found',
            status: 404
          )
        end
        format.json{ render json: {message: 'not found'}, status: 404 }
        format.xml{ render xml: {message: 'not found'}, status: 404 }
      end
    end

    def internal_server_error(exception)
      if ENV['PM_EXCEPTION_RECIPIENTS'].present?
        ExceptionNotifier.notify_exception(
          exception,
          env: request.env, data: { message: 'was doing something wrong' }
        )
      end

      respond_to do |format|
        format.html do
          @no_submenu = true

          render(
            template: 'shared/misc/_internal_server_error',
            status: 500
          )
        end
        format.json{ render json: {message: 'internal server error'}, status: 500 }
        format.xml{ render xml: {message: 'internal_server_error'}, status: 500 }
      end
    end

    def log_user
      who = if current_user
        id = current_user.id
        iid = current_user.institution_id
        sid = session.id
        ipuser = (current_user.ipuser? ? 'yes' : 'no')
        "  User: #{id}, institution: #{iid}, session: #{session.id}, ipuser: #{ipuser}"
      else
        "  User: 0, institution: 0, session: #{session.id}"
      end
      Rails.logger.info who
    end

    # REWRITE: we add page and per_page to access pagination parameters in a
    # uniform manner (when needed)
    def page
      [(params[:page] || 1).to_i, 1].max
    end

    # REWRITE: see above
    def per_page
      max = ENV['PM_MAX_PER_PAGE'].to_i
      return max if params[:per_page] == 'max'

      [(params[:per_page] || per_page_default).to_i, max].min
    end

    def per_page_default
      10
    end

    def sort_column
      params[:order] || sort_column_default
    end

    def sort_column_default
    end

    def sort_direction
      v = (params[:direction] || sort_direction_default).downcase
      ['asc', 'desc'].include?(v) ? v : sort_direction_default
    end

    def sort_direction_default
      'asc'
    end

    def sort_inverse
      sort_direction == 'asc' ? 'desc' : 'asc'
    end

    def search_column
      @field ||= params[:field]
    end

    def search_value
      @value ||= params[:value]
    end

    def view
      params[:view] || view_default
    end

    def view_default
      'list'
    end

    def zoom
       case params[:zoom]
       when 'true' then true
       when 'false' then false
       else
         zoom_default
       end
    end

    def zoom_default
      false
    end

    # REWRITE: we use these to simplify rendering api errors
    def render_api(status, data)
      respond_to do |format|
        format.json {render json: data, status: status}
        format.xml {render xml: data, status: status}
      end
    end

    def render_api_401(message)
      render_api 401, 'message' => message
    end

    def render_api_403(message)
      render_api 403, 'message' => message
    end

    def render_api_404(message)
      render_api 404, 'message' => message
    end

    def render_api_422(message)
      render_api 422, 'message' => message
    end

    def render_api_200(message)
      render_api 200, 'message' => message
    end

    def set_url_options
      ApplicationMailer.default_url_options = default_url_options
      PaymentTransaction.root_url = locale_root_url
    end

    # REWRITE: configure default url options. route defaults don't work in
    # combination with this, see https://github.com/rails/rails/issues/27785
    def default_url_options
      {
        host: request.host,
        port: request.port,
        protocol: request.protocol,
        locale: params[:locale] || I18n.default_locale
      }
    end

    # logged-in users don't need to pass captcha
    def captcha_passed?
      current_user && !current_user.dbuser? || super
    end

    # builds a url to the home page specified in the env var PM_HOME_URL
    # @param path [String] the path on the web page
    def home_url(path = nil)
      "#{ENV['PM_HOME_URL']}/#{I18n.locale}/#{path}"
    end

    def public_path_for(relative_path, only_path = true)
      File.join(only_path ? root_path(locale: nil) : root_url(locale: nil), relative_path)
    end

    # call-seq:
    #   location(options = params) => aString
    #
    # Builds a URL for the specified +location+.
    def location(options = nil)
      if options == nil
        return request.path + (request.query_string.present? ? '?' + request.query_string : '')
      end

      if options.respond_to?(:reverse_merge)
        url_for(options.reverse_merge(:only_path => true))
      else
        url_for(options)
      end
    end

    def human_location
      "#{controller_name} page".t
    end

    # translates a string containing a link with a translated label
    # @param [String] key the string to be translated
    # @param [String, Hash, nil] url_options the url options for the link href,
    #   pass nil for the current url
    # @param [String, Array] interpolations other string format values
    # @return [String] the translated string
    # @example
    #   translate_with_link('See our %d %{goals}%', '/goals', 3)
    #   => "See our 3 <a href=\"/goals\">goals</a>"
    def translate_with_link(key, url_options = nil, interpolations = [])
      # translate, escape the link placeholder and format with interpolations
      # (the string format revers %% to %)
      translated = key.t.gsub('%{', '%%{').gsub('}%', '}%%') % interpolations

      link = helpers.link_to('\1', url_options || locale_root_path)
      translated.
        gsub(/\%\{([^\}]+)\}\%/, link).
        html_safe
    end

    def push_flash(level, message)
      flash[level] ||= []
      flash[level] << message
    end

    # call-seq:
    #   store_location
    #
    # Stores the URL of the current request in the session (as +return_to+).
    # We can return there by calling #redirect_back_or_default.
    def store_location
      if session_enabled? && request.get? && !request.xhr?
        return if format = params[:format] and format != 'html'

        session[:previous_return_to] = session[:return_to]
        session[:return_to]          = location || request.env['HTTP_REFERER']
      end
    end

    def default_location(key = :redirect)
      result = nil

      if key == :start && current_user && !(current_user_settings_start_page = DEFAULT_LOCATION[current_user.settings.start_page]).blank?
        result = current_user_settings_start_page
      else
        result = DEFAULT_LOCATION[key]
      end

      # This method is called by AuthenticatedSystem to redirect to the
      # login form. The locale isn't set yet at that point, so we need to grab it
      # from the url instead and we need to enforce it
      # result[:locale] ||= I18n.locale
      result[:locale] = params[:locale] || default_locale

      result
    end

    def back_or_default(*where)
      default = where.shift || :redirect

      if default == :previous
        default   = where.pop || :redirect
        return_to = :previous_return_to
      else
        return_to = :return_to
      end

      default   = default_location(default) if DEFAULT_LOCATION.has_key?(default)
      return_to = location(session[return_to] || default)

      force_default = return_to == location
      force_default ||= yield location(return_to).sub(/\?.*\z/, '') if block_given?

      force_default ? location(default) : return_to
    end

    # call-seq:
    #   redirect_back_or_default(default = :redirect)
    #
    # Redirects to the <tt>step</tt>th most recent URL stored in the session by
    # #store_location or to the passed default.
    def redirect_back_or_default(*where)
      redirect_to back_or_default(*where)
    end

    def safe_params(*unsafe)
      overrides = unsafe.extract_options!
      output_params = params.except(*UNSAFE_OPTIONS + unsafe).merge(overrides)

      # Dirty evil hack to substitude athene action names with their routes in generated links
      if output_params['controller'] == 'search'
        if output_params['action'] == 'athene_search'
          output_params['action'] = 'search'
        elsif output_params['action'] == 'advanced_search'
          output_params['action'] = 'advanced_search'
        end
      # REWRITE: doesn't seem to be reached
      elsif output_params['controller'] == 'images' && output_params['action'] == 'show_athene_search'
        output_params['action'] = 'show'
      end

      # REWRITE: needs permit! not to clash with .to_h later, check if it is
      # really safe
      output_params.permit!
    end

    def set_mandatory_fields(mandatory = default = true)
      mandatory = Set.new(default ? self.class.model_class::REQUIRED : mandatory)
      @mandatory = HashWithIndifferentAccess.new { |h, k| h[k] = mandatory.include?(k.to_s) }
    end

    def set_prompt_field(field)
      (@prompt ||= HashWithIndifferentAccess.new)[field] = true
    end

    def set_is_admin
      @is_admin = current_user && current_user.admin_or_superadmin?
      @is_admin &&= params[:public] != '1'
    end

    def admin_or_superadmin?
      current_user && current_user.admin_or_superadmin?
    end

    def set_list_search
      @page, @field, @value = params.values_at(:page, :field, :value)
      @page = [@page.to_i, 1].max
    end

    def store_neighbours_for(items)
      session[:neighbours] = if items
        items.map do |item|
          case item
          when Upload then item.image_id
          when Image then item.id
          when Pandora::SuperImage then item.pid
          else
            raise "unknown neighbor: #{item.inspect}"
          end
        end
      end

      set_neighbourhood
    end

    def set_neighbours(image_ids_array)
      session[:neighbours] = image_ids_array
    end

    def get_left_neighbour(image_id)
      unless (neighbours = session[:neighbours]).blank?
        if index = neighbours.index(image_id)
          if index > 0 && prev_id = neighbours[index - 1]
            left_neighbour = prev_id
          end
        end
      end
    end

    def get_right_neighbour(image_id)
      unless (neighbours = session[:neighbours]).blank?
        if index = neighbours.index(image_id)
          if next_id = neighbours[index + 1]
            right_neighbour = next_id
          end
        end
      end
    end

    def set_neighbourhood
      session[:neighbourhood] = [controller_name, location]
    end

    def get_neighbourhood
      session[:neighbourhood]
    end

    def neighbours_of(object, klass = object.class)
      unless (neighbours = session[:neighbours]).blank?
        if index = neighbours.index(object.id)
          if index > 0 && prev_id = neighbours[index - 1]
            left_neighbour = klass.find(prev_id)
          end

          if next_id = neighbours[index + 1]
            right_neighbour = klass.find(next_id)
          end
        end
      end

      [left_neighbour, right_neighbour, session[:neighbourhood]]
    end

    def get_suggestions(klass, options = {})
      @phrase, @matches = params[:q], []
      @phrases = @phrase.split

      return if @phrases.empty?

      clauses, args = [], []
      clause = options.delete(:clause)

      @phrases.each { |phrase|
        clauses << clause
        clause.count('?').times { args << "%#{phrase}%" }
      }

      conds = options.
        merge(:readonly => true).
        merge_conditions([clauses.join(' AND '), *args])
      scope = Upgrade.conds_to_scopes(klass, conds)
      @matches = scope.to_a

      yield @matches if block_given?
    end

    def restrict_to(*roles)
      yield if current_user && permit?(roles.join('|'))
    end

    def permit?(access)
      if access
        if user = current_user
          if access == 'true'
            true
          elsif access == 'false'
            false
          else
            !(access.split('|') & user.role_titles).empty?
          end
        else
          true
        end
      else
        false
      end
    end

    def allow_open_access(user = current_user)
      source = source_for_open_access if !user || user.dbuser?

      if source && source.open_access?
        log_in source.dbuser
        verify_account_terms_accepted
      else
        login_required
      end
    end

    def set_frontend
      current = view_paths.first.to_path

      if session[:frontend] == 'ng'
        if current.split('/').last != 'ng'
          prepend_view_path("#{Rails.root}/app/views/ng")
        end
      else
        if current.split('/').last == 'ng'
          view_path.shift
        end
      end
    end

    def set_locale(locale = nil)
      I18n.locale = params[:locale] || default_locale
    end

    def determine_layout
      'application' unless request.xhr?
    end

    def store_request
      Thread.current[:request] = request
    end

    def session_enabled?
      request.session_options
    end

    def format_for_api(status, message = nil, api_headers = {}, &block)
      respond_to do |format|
        api = lambda {
          api_headers.each { |k, v| response.set_header k, v }

          render_status(status, message)
        }

        format.html(&block)
        format.zip(&block)
        format.json do
          api_headers.each { |k, v| response.set_header k, v }
          render json: {message: message}, status: status
        end
        format.xml do
          api_headers.each { |k, v| response.set_header k, v }
          render xml: {message: message}, status: status
        end
        format.all do
          api_headers.each { |k, v| response.set_header k, v }
          render plain: message, status: status
        end
      end
    end

    def limit_request_rate
      # See #1205.
      if !api_request? || (current_user && current_user.id == 87416)
        return
      end

      rate_limit = RateLimit.get(request, current_user)
      rate_limit_headers = rate_limit.headers

      if rate_limit.exceeded?
        respond_to do |format|
          data = {
            'message' => 'Rate Limit Exceeded'.t,
            'info' => rate_limit.info
          }

          format.json{ render json: data, status: 503}
          format.xml{ render xml: data, status: 503}
          format.blob{ render nothing: true, layout: false, status: 503}

          Rails.logger.info "RATE LIMIT EXCEEDED"
        end
      else
        headers.update(rate_limit.headers)
      end
    end

    def refresh_translation_cache
      if Rails.env.development?
        I18n::Backend::Pandora.drop_cache!
      end
    end

    # def update_section(object, partial = false)
    #   return unless request.xhr?

    #   section = params[:section]
    #   update  = section_id(section)

    #   render partial: 'application/update.js', content_type: 'text/javascript', locals: {
    #     object: object,
    #     partial: partial,
    #     section: section,
    #     update: update,
    #     original_block_given: block_given?
    #   }

    #   true
    # end

    def count_for_section(object, section)
      count = instance_variable_get("@#{section}_count") and return count

      obj = instance_variable_get("@#{section}")
      obj = object.send(section) if (obj.nil? || obj.is_a?(String)) && object.respond_to?(section)

      %w[count size].find { |method| return obj.send(method) if obj.respond_to?(method) }
    end

    def section_partial(object, section, expanded = true, count = count_for_section(object, section), locals = {})
      {
        :partial => 'shared/misc/section',
        :locals  => { :object => object, :section => section, :expanded => expanded, :count => count, :locals => locals}
      }
    end

    def section_id(section)
      section =~ /header/ ? 'header-section' : "#{section}-section"
    end

    # returns a counter display, taking singular/plural into account
    # @param [Integer] count the amount of items
    # @param [String] label the singular label, use %d where the count should be
    #   inserted
    # @param [String] plural_label the plural label, see previous param
    # @return [String] the generated label
    def pm_labelled_counter(count, label, plural_label)
      if count == 1
        label / count
      else
        plural_label / count
      end
    end

    def prepare_exception_notifier
      request.env["exception_notifier.exception_data"] = {
        :current_user => current_user
      }
    end


    # ng locale

    def default_locale
      user_locale || agent_locale || 'en'
    end

    def user_locale
      if current_user && !current_user.ipuser?
        current_user.settings.locale
      end
    end

    def agent_locale
      raw = request.headers['accept-language']
      if raw
        preference = raw.split(',').map{|s| s.split(';').first.split('-').first}
        locale = preference.first
        ['en', 'de'].include?(locale) ? locale : nil
      end
    end


    # ng auth

    def log_in(account, options = {})
      session[:account_id] = account.id

      if options[:remember_me]
        account.remember_me!
      end

      if account.remember_token?
        account.extend_remember_me!

        cookies[:auth_token] = {
          :value   => account.remember_token,
          :expires => account.remember_token_expires_at
        }
      end
    end

    def log_out
      current_user.forget_me! if current_user
      @current_user = nil

      reset_session
      cookies.delete(:auth_token)
    end

    def render_basic_auth
      response.headers['WWW-Authenticate'] = 'Basic realm="prometheus image archive"'
      render layout: false, plain: '', status: 401
    end

    def render_invalid_login_or_password
      respond_to do |format|
        format.json { render json: {message: 'Invalid user name or password!'.t} }
        format.xml { render xml: {message: 'Invalid user name or password!'.t} }
        format.html do
          flash.now[:warning] = [
            'Invalid user name or password!'.t,
            translate_with_link(
              'Do you want to %{reset your password}%?',
              controller: 'signup', action: 'password_form', login: params[:login]
            )
          ].join(' ').html_safe

          render action: 'new'
        end
      end
    end

    def render_banned(account)
      message = [
        'Too many failed login attempts!'.t,
        'Please try again in %s.' / Util::Helpers::DateHelper.distance_of_time_in_words(account.ban_lifted_in)
      ]

      respond_to do |format|
        format.json { render json: {message: 'Invalid user name or password!'.t} }
        format.xml { render xml: {message: 'Invalid user name or password!'.t} }
        format.html do
          link = helpers.link_to(message[1], login_path(login: params[:login]))
          flash.now[:warning] = [message[0], link].join(' ').html_safe

          render action: 'new'
        end
      end
    end

    def verify_account_email
      return unless current_user

      if !current_user.anonymous? && !current_user.email_verified?
        formatted_redirect_with_warning('Please verify your e-mail address!'.t, 'signup', 'confirm_email_form')
      end
    end

    def verify_account_active
      return unless current_user

      if current_user.expired?
        formatted_redirect_with_warning(nil, 'signup', 'license_form') {
          [
            "Your #{'guest ' if current_user.mode == 'guest'}account has expired!".t,
            'Please obtain a new license in order to proceed.'.t
          ].join(' ')
        }
      end
    end

    def verify_account_not_deactivated
      return unless current_user

      if current_user.status == 'deactivated'
        formatted_redirect_with_warning(nil, 'signup', 'license_form') {
          [
            "Your #{'guest ' if current_user.mode == 'guest'}account has been deactivated!".t,
            'Please obtain a new license in order to proceed.'.t
          ].join(' ')
        }
      end
    end

    def verify_account_signup_complete
      return unless current_user

      # the following only concerns user accounts,
      # if the user signs up itself, mode should be set;
      # otherwise (creation by administrator) mode is not set
      # mode 'association' can't be set in signup process
      if current_user.user? && !current_user.mode.nil? && !['association', 'clickandbuy'].include?(current_user.mode)
        case current_user.mode
        when 'guest'
          if !current_user.anonymous? && !current_user.email_verified?
            formatted_redirect_with_warning('You haven\'t confirmed your email address yet!'.t, 'signup', 'email_confirmation_sent')
          else
            if current_user.status == 'pending'
              warning = [
                'Your research interest has to be approved before your account can',
                'be activated. Please be patient, we will take care of it as soon',
                'as possible.'
              ].join(' ').t + ' ' +
                'We will notify you via email once everything is done.'.t
              formatted_redirect_with_warning(warning, 'signup', 'signup_completed')
            end
          end
        when 'institution'
          if current_user.institution == nil
            formatted_redirect_with_warning("You haven't selected the licensed institution you belong to yet.".t, 'signup', 'license_form')
          else
            if !current_user.anonymous? && !current_user.email_verified?
              formatted_redirect_with_warning('You haven\'t confirmed your email address yet!'.t, 'signup', 'email_confirmation_sent')
            else
              if current_user.status == 'pending'
                formatted_redirect_with_warning('Your account has to be activated.'.t, 'signup', 'signup_completed')
              end
            end
          end
        when 'paid'
          if !current_user.anonymous? && !current_user.email_verified?
            formatted_redirect_with_warning('You haven\'t confirmed your email address yet!'.t, 'signup', 'email_confirmation_sent')
          else
            formatted_redirect_with_warning("You haven't selected your payment mode yet.".t, 'signup', 'license_form')
          end
        when 'paypal'
          if current_user.status == 'pending'
            formatted_redirect_with_warning('Your payment process is not finished yet.'.t + ' ' + 'Please finish the payment process with PayPal.'.t, 'signup', 'signup_completed')
          end
        when 'invoice'
          if current_user.status == 'pending'
            formatted_redirect_with_warning('Your account will be activated once your payment has been received.'.t, 'signup', 'signup_completed')
          end
        else
          raise Pandora::Exception, "account #{current_user.id} has unexpected mode: #{current_user.mode}"
        end
      end
    end

    def verify_account_terms_accepted
      return unless current_user

      accepted =
        current_user.accepted_terms_of_use? || # personal accounts
        session[:accepted_terms_of_use] # ipuser accounts
      unless accepted
        # TODO Remove German version of flash notice after the prometheus app has been updated for prometheus-ng.
        # The legacy app checks this sentence in German.
        flash[:prompt] = 'Bitte akzeptieren Sie unsere Nutzungsbedingungen bevor Sie das Bildarchiv betreten.'.t
        formatted_response_with_message(flash[:prompt]) {
          redirect_to controller: 'terms', action: 'edit', return_to: params[:return_to] || request.url
        }
      end
    end

    def formatted_response_with_message(m, status = :forbidden, &block)
      format_for_api(status, m.is_a?(Array) ? m.first.gsub(/%\{|\}%/, '') : m, &block)
    end

    def formatted_redirect_with_warning(warning, controller, action, status = :forbidden)
      formatted_response_with_message(warning ||= yield, status) {
        # we want to keep potential messages from this request and show them
        # after the redirect
        flash.keep

        flash[:warning] = warning
        redirect_to controller: controller, action: action, id: current_user.login
      }
    end

    # end ng

    # tries to find specified user settings value but instead of raising an
    # exception, returns nil if nothing could be retrieved
    # @param [String] type one of 'account', 'image', 'upload', 'collection' and
    #  'search'
    # @param [String] key the setting to retrieve
    # @return the setting when found and configured for the user or nil
    def try_setting(type, key)
      if current_user && current_user.settings(type)
        current_user.settings(type)[key]
      end
    end

    def authenticate_from_token_warnings(user, link_expired, matching_token)
      unless user
        no_user_warning = "User account does not exist. Without confirmation, accounts are deleted after #{DEFAULT_CLEANUP_DURATION}.".t + ' ' +
            'If this is the case, please create a new one.'.t
        if flash[:warning].blank?
          flash[:warning] = no_user_warning
        else
          flash[:warning] + ' ' + no_user_warning
        end
      else
        if link_expired
          link_expired_warning = 'Link expired!'.t + ' ' + 'Please generate a new one.'.t
          if flash[:warning].blank?
            flash[:warning] = link_expired_warning
          else
            flash[:warning] + ' ' + link_expired_warning
          end
        end
        unless matching_token
          no_matching_token_warning = I18n.t(:magic_link_invalid) + ' ' + I18n.t(:magic_link_invalid_instruction)
          if flash[:warning].blank?
            flash[:warning] = no_matching_token_warning
          else
            flash[:warning] + ' ' + no_matching_token_warning
          end
        end
      end
    end

    initialize_me!

end
