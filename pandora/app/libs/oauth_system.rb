module OauthSystem

  #############################################################################
  protected
  #############################################################################

  def current_token
    @current_token
  end

  def current_client_application
    @current_client_application
  end

  def oauthenticate
    verify_oauth_signature && current_token.is_a?(::AccessToken)
  end

  def oauth?
    current_token != nil
  end

  # use in a before filter:

  def oauth_required
    oauthenticate || invalid_oauth_response
  end

  def login_or_oauth_required
    oauthenticate || login_required
  end

  # verifies a request token request
  def verify_oauth_consumer_signature
    begin
      ClientApplication.verify_request(request) { |request_proxy|
        @current_client_application = ClientApplication.find_by_key(request_proxy.consumer_key)

        # Store this temporarily in client_application object for use in request token generation
        @current_client_application.token_callback_url = request_proxy.oauth_callback if request_proxy.oauth_callback

        # return the token secret and the consumer secret
        [nil, @current_client_application.secret]
      }
    rescue
    end || invalid_oauth_response
  end

  def verify_oauth_request_token
    verify_oauth_signature && current_token.is_a?(::RequestToken)
  end

  #############################################################################
  private
  #############################################################################

  def current_token=(token)
    if token.is_a?(OauthToken)
      @current_token, @current_client_application = token, token.client_application
      @current_oauth_user = token.user
    else
      @current_token, @current_client_application = nil, nil
      @current_oauth_user = nil
    end
  end

  def verify_oauth_signature
    valid = ClientApplication.verify_request(request) { |request_proxy|
      self.current_token = ClientApplication.find_token(request_proxy.token)

      if current_token.respond_to?(:provided_oauth_verifier=)
        current_token.provided_oauth_verifier = request_proxy.oauth_verifier
      end

      # return the token secret and the consumer secret
      [current_token && current_token.secret, current_client_application && current_client_application.secret]
    }

    self.current_token = nil unless valid

    valid
  rescue
    false
  end

  def invalid_oauth_response(code = :unauthorized, message = 'Invalid OAuth Request'.t)
    render plain: message, status: code
  end

end
