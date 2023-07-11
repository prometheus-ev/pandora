class ProfileController < ApplicationController
  skip_before_action :verify_account_email
  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_signup_complete
  skip_before_action :verify_account_terms_accepted

  def self.initialize_me!
    control_access(
      [:user, :admin, :useradmin, :dbadmin, :superadmin] => :ALL
    )
  end

  def show
    @user = current_user

    # view compatibility
    @public_collections  = @shared_collections   = false
    if @user.active?
      @public_collections = @user.collections.public
      @shared_collections = @user.collections.shared(current_user)
    end
  end

  def edit
    @user = current_user

    if params[:reset_password]
      flash[:prompt] = 'Please enter a new password.'.t
    end
  end

  def update
    @user = current_user
    @user.assign_attributes(account_params)

    if @user.email_changed?
      @user.email_verified_at = nil
    end

    if @user.save
      if @user.saved_change_to_email?
        @user.deliver_token(:email_confirmation)
      end

      if @user.saved_change_to_research_interest?
        @user.deliver(:research_interest_check)
      end

      flash[:notice] = 'Your account has been successfully updated'.t
      redirect_to action: 'show'
    else
      flash[:warning] = 'There were some errors saving your account'.t

      if params[:settings_only]
        render action: 'show'
      else
        render action: 'edit'
      end
    end
  end

  def disable
    @user = current_user
    @user.disable!
    log_out

    flash[:notice] = 'Your account has been disabled'.t
    redirect_to login_path
  end

  def download_legacy_presentation
    if current_user.id == params[:id].to_i
      respond_to { |format|
        format.pdf { send_file File.join(ENV['PM_PRESENTATIONS_DIR'], params[:id], params[:presentation_id],
          "#{params[:presentation_filename]}.pdf"), type: "application/pdf",
          filename: "#{params[:presentation_filename]}.pdf"}
        format.zip { send_file File.join(ENV['PM_PRESENTATIONS_DIR'], params[:id], params[:presentation_id],
          "#{params[:presentation_filename]}.zip"), type: "application/zip",
          filename: "#{params[:presentation_filename]}.zip"}
      }
    else
      flash[:warning] = 'You are not allowed to access this resource.'.t
      redirect_to login_path
    end
  end


  protected

    def account_params
      result = params.fetch(:user, {}).permit(
        :firstname, :lastname, :title,
        :login, :email, :password, :password_confirmation, :addressline,
        :postalcode, :city, :country, :locale, :newsletter, :research_interest,
        translations: {
          en: [:about],
          de: [:about]
        },
        account_settings_attributes: {},
        search_settings_attributes: {},
        collection_settings_attributes: {},
        upload_settings_attributes: {},
        _translations: {en: {}, de: {}}
      )

      result
    end


    initialize_me!

end
