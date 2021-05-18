module ActionDispatch

  class Request

    ### api/bot

    def api?
      defined?(@_api) ? @_api : @_api = path_parameters.has_key?(:api_version) || oauth?
    end

    def bot?
      defined?(@_bot) ? @_bot : @_bot = Util::Bot.bot?(user_agent)
    end

    ### auth

    # TODO: use Rails' mechanism for this
    AUTH_HEADERS = %w[X-HTTP_AUTHORIZATION Authorization HTTP_AUTHORIZATION]

    def auth_header
      return @auth_header if defined?(@auth_header)

      auth_header = AUTH_HEADERS.find { |header| env.include?(header) }
      @auth_header = auth_header && env[auth_header]
    end

    def auth_header?
      !!auth_header
    end

    def auth_data
      @auth_data ||= auth_header ? auth_header.split(nil, 2) : []
    end

    def auth_data?
      !auth_data.empty?
    end

    def auth_scheme
      auth_data.first.downcase if auth_data?
    end

    def auth_credentials
      auth_data.last if auth_data?
    end

    def basic_auth?
      auth_scheme == 'basic'
    end

    def basic_auth
      Base64.decode64(auth_credentials).split(':', 2) if basic_auth?
    end

    def oauth?
      auth_scheme == 'oauth'
    end

    def oauth_params
      return {} unless oauth?

      # parse the header into a Hash
      oauth_params = OAuth::Helper.parse_header(auth_header)

      # remove non-OAuth parameters
      oauth_params.reject! { |k, _| k !~ /\Aoauth_/ }

      oauth_params
    end

  end

end
