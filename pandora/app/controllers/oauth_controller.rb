class OauthController < ApplicationController

  skip_before_action :login_required, :except => [:authorize, :revoke]
  # skip_before_action :store_location, :except => [:authorize, :revoke]
  skip_before_action :verify_authenticity_token
  
  # before_action :oauth_required,                  :only => [:invalidate, :capabilities]
  before_action :verify_oauth_consumer_signature, :only => [:request_token]
  before_action :verify_oauth_request_token,      :only => [:access_token]

  def self.initialize_me!
    control_access [:user, :useradmin, :dbadmin, :admin, :superadmin] => :ALL
  end

  def request_token
    if @token = current_client_application.create_request_token
      render :plain => @token.to_query
    else
      message = 'Request token could not be created'.t
      render plain: message, status: :unauthorized
    end
  end

  def access_token
    if @token = current_token && current_token.exchange!
      render plain: @token.to_query
    else
      message = 'Request token could not be exchanged'.t
      render plain: message, status: :unauthorized
    end
  end

  def authorize
    if @token = RequestToken.find_by_token(params[:oauth_token]) and !@token.invalidated?
      return unless request.post?

      # TODO: why the check for '1'?
      params[:authorize] = '1'
      if params[:authorize] == '1' && @token.authorize!(current_user)
        if redirect_url = @token.redirect_url
          redirect_to redirect_url
          return
        else
          respond_to do |format|
            format.json {render json: { 'oauth_verifier' => @token.verifier }.to_json}
            format.html {render action: 'authorize_success'}
          end

          return
        end
      else
        @token.invalidate!
      end
    end

    respond_to do |format|
      format.json {render json: { 'oauth_verifier' => 'authorize failure' }.to_json}
      format.html {render action: 'authorize_failure'}
    end
  end

  def revoke
    if @token = current_user.tokens.find_by_token(params[:token])
      @token.invalidate!

      if client = @token.client_application
        flash[:notice] = "You've revoked the token for %s" / client
      end
    end

    redirect_to client_applications_url
  end

  # TODO: we have no routes for this, is this still needed, perhaps for logout?
  # def invalidate
  #   current_token.invalidate!
  #   render_status(:gone, 'Token has been invalidated'.t)
  # end

  # TODO: we have no routes for this, is this still needed
  # def capabilities
  #   @capabilities = if current_token.respond_to?(:capabilities)
  #     current_token.capabilities
  #   else
  #     { :invalidate => url_for(:action => :invalidate) }
  #   end

  #   respond_to { |format|
  #     format.json { render :json => @capabilities }
  #     format.xml  { render :xml  => @capabilities }
  #   }
  # end

  initialize_me!

end
