class OauthClientsController < ApplicationController

  def self.model_name
    'client_application'
  end

  def self.initialize_me!  # :nodoc:
    control_access [:admin, :superadmin] => :ALL,
                   [:user, :useradmin, :dbadmin] => :index
  end

  def index
    if admin_or_superadmin?
      @client_applications = ClientApplication.order('name')
      # TODO: pagination
      @tokens = OauthToken.authorized.includes(:client_application, user: :roles)
    else
      @tokens = current_user.tokens.authorized
    end
  end

  def show
    @client_application = ClientApplication.find(params[:id])
  end

  def new
    @client_application = ClientApplication.new

    # view compatibility
    set_mandatory_fields ['name', 'homepage']
  end

  def create
    @client_application = ClientApplication.create(client_application_params)

    if @client_application.save
      flash[:notice] = "Client application '%s' successfully created!" / @client_application
      redirect_to :action => 'show', :id => @client_application
    else
      set_mandatory_fields

      render :action => 'edit'
    end

    # view compatibility
    set_mandatory_fields ['name', 'homepage']
  end


  def edit
    @client_application = ClientApplication.find(params[:id])

    # view compatibility
    set_mandatory_fields ['name', 'homepage']
  end

  def update
    @client_application = ClientApplication.find(params[:id])

    if @client_application.update_attributes(client_application_params)
      flash[:notice] = "Client application '%s' successfully updated!" / @client_application

      redirect_to action: 'show', id: @client_application
    else
      render action: 'edit', status: 422
    end

    # view compatibility
    set_mandatory_fields ['name', 'homepage']
  end

  def destroy
    @client_application = ClientApplication.find(params[:id])

    @client_application.destroy
    flash[:notice] = "Client application '%s' successfully deleted!" / @client_application

    redirect_to action: 'index'
  end


  protected

    def client_application_params
      params.fetch(:client_application, {}).permit!
    end

    initialize_me!
end
