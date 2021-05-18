class SignupController < ApplicationController
  skip_before_action :login_required, :except => [:license_form, :license, :signup_completed, :confirm_email_form, :change_email]
  skip_before_action :verify_account_email
  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_signup_complete
  skip_before_action :verify_account_terms_accepted

  before_action :create_brain_buster, :only => [:signup_form, :signup, :password_form, :password]

  def signup_form
    params[:type] ||= 'guest'
    @user = Account.new(user_params)

    set_mandatory_fields
  end

  def signup
    set_mandatory_fields

    unless validate_brain_buster
      @user = Account.new(user_params)
      render action: 'signup_form'
      return
    end

    unless params[:accepted]
      @user = Account.new(user_params)
      flash.now[:warning] =
        'You have to accept our terms of use to be able to use the prometheus image archive.'.t
      render action: 'signup_form'
      return
    end

    types = ['institution', 'paid', 'guest']
    params[:type] = nil unless types.include?(params[:type])

    if user = Account.non_subscribers.where(
      'email LIKE :email',
      email: user_params[:email]
      ).first
      @user = user
      flash.now[:info] = 'An account with this email address already exists.'.t
    elsif user = Account.non_subscribers.where(
      'login LIKE :login',
      login: user_params[:login]
      ).first
      @user = user
      flash.now[:info] = 'An account with this login already exists.'.t
    end

    if @user
      @user = Account.new(user_params)
      render action: 'signup_form'
      return
    end

    @user = Account.non_subscribers.where(
      'login LIKE :login OR email LIKE :email',
      login: user_params[:login],
      email: user_params[:email]
    ).first

    if @user
      flash.now[:info] = 'Your account already exists.'.t
      @user = Account.new(user_params)
      render action: 'signup_form'
      return
    end

    @user =
      Account.subscribers.find_by(email: user_params[:email]) ||
      Account.new(user_params)

    if params[:type] == 'institution'
      attribs = user_params.merge(
        roles: [Role.find_by(title: 'user')],
        institution: nil,
        mode: 'institution',
        needs_research_interest: false, # no research interest is needed when licensed by institution
        expires_in: 1.week
      )
    elsif params[:type] == 'guest'
      attribs = user_params.merge(
        roles: [Role.find_by(title: 'user')],
        institution: Institution.find_by(name: 'prometheus'),
        mode: 'guest',
        needs_research_interest: true,
        expires_in: 1.week
      )
    elsif params[:type] == 'paid'
      attribs = user_params.merge(
        roles: [Role.find_by(title: 'user')],
        institution: Institution.find_by(name: 'prometheus'),
        mode: 'paid',
        needs_research_interest: true,
        expires_in: 1.week
      )
    elsif params[:type].nil?
      flash.now[:warning] = "You have to choose an account type in order to sign up".t
      return
    end

    if @user.subscriber?
      attribs.merge!(
        firstname: nil,
        lastname: nil
      )
    end

    @user.settings.locale = locale

    if @user.update(attribs)

      @user.accepted_terms_of_use!

      log_in @user

      notice = 'Thank you for your registration!'.t

      case params[:type]
      when 'institution'
        @type = params[:type]

        flash[:notice] = notice
        redirect_to action: 'license_form'
        return
      when 'paid'
        @type = params[:type]
        @user.deliver_token(:email_confirmation)

        flash[:notice] = notice
        render action: 'email_confirmation_sent'
        return
      when 'guest'
        @type = params[:type]
        @user.deliver_token(:email_confirmation)

        flash.now[:notice] = notice
        render action: 'email_confirmation_sent'
        return
      end
    end

    render action: 'signup_form'
  end

  def confirm_email_form
    @user = current_user
  end

  def change_email
    @user = current_user

    return if @user.dbuser? || @user.ipuser?

    if @user.update_attributes(user_email_params)
      @user.deliver_token(:email_confirmation)
      render action: 'email_confirmation_sent'
    else
      flash[:warning] = 'The new e-mail address is invalid'.t
      render action: 'confirm_email_form', status: 422
    end
  end

  def email_confirmation_sent

  end

  def confirm_email_linkback
    @user = Account.authenticate_from_token(params[:login], params[:timestamp], params[:token]) do |user, link_expired, matching_token|
      authenticate_from_token_warnings(user, link_expired, matching_token)
    end

    if @user
      if @user.email_verified?
        flash[:notice] = 'You already confirmed your e-mail address!'.t
        unless current_user
          flash[:notice] += ' ' + 'Just proceed with the login...'.t
        end
      else
        # also sets user status to pending
        @user.email_verified!
        if @user.mode == 'guest'
          @user.deliver(:activation_request)
        end
        push_flash(:notice,
          'Your e-mail address has been confirmed. Thank you!'.t
        )
      end

      redirect_to root_url
    else
      if current_user
        render action: 'email_confirmation_sent'
      else
        redirect_to root_url
      end
    end
  end

  def license_form
    initialize_licence_variables
  end

  def license
    initialize_licence_variables

    institution = nil

    case license_user_params[:mode]
    when 'institution'
      institution = @institutions.include?(@institution) ? @institution : nil
      if institution == nil
        flash[:prompt] = 'You need to chose an institution.'.t

        redirect_to action: "license_form", type: @type
        return
      end

      @user.mode = 'institution'
      @user.status = 'pending'
    when 'paypal'
      institution = Institution.find_by!(name: 'prometheus')
      @user.needs_research_interest!
      @user.mode = 'paypal'
      @user.research_interest = license_user_params[:research_interest]
    when 'invoice'
      institution = Institution.find_by!(name: 'prometheus')
      @user.needs_research_interest!
      @user.mode = 'invoice'
      @user.research_interest = license_user_params[:research_interest]

      address_incomplete = false
      @address_fields.each { |field|
        if @address_hash[field].blank?
          set_prompt_field(field)
          address_incomplete ||= true
        end
      }
      if address_incomplete
        flash[:prompt] = 'We need your full address to create a valid invoice for you.'.t

        redirect_to action: "license_form", type: @type, invoice_address: @address_hash
        return
      end
    else
      flash[:warning] = 'Please select a means by which to gain access to the image archive.'.t
      redirect_to action: "license_form", type: @type
      return
    end

    @user.institution = @institution = institution

    if @user.save
      @user.accepted_terms_of_use
      @user.notified!  # pretend they have been notified
                       # to avoid disturbing reminders

      current_user.reload

      if @user.mode == 'institution'
        unless @user.email_verified?
          @user.deliver_token(:email_confirmation)
          render action: 'email_confirmation_sent'
          return
        end
        if @user.mode == 'institution' && @user.institution == institution
          if @user.status == 'pending'
            render :action => 'signup_completed'
          else
            redirect_to default_location(:start)
          end
          return
        end
      elsif @user.mode == 'paypal'
        redirect_to PaymentTransaction.transaction_for(@user).url
        return
      elsif @user.mode == 'invoice'
          @user.deliver(:invoice_notice, @invoice_address, nil)
        render action: 'signup_completed'
        return
      end

      render action: 'license_form'
    else
      render action: 'license_form'
    end
  end

  def signup_completed
    initialize_licence_variables
  end

  def password_form
    if current_user && !(current_user.dbuser? || current_user.ipuser?)
      flash[:prompt] = 'Please enter a new password.'.t
      redirect_to edit_profile_path
    end
  end

  def password
    unless x = validate_brain_buster
      render action: 'password_form'
      return
    end

    user = Account.find_by_login_or_email(params[:login])
    if user
      if !user.email.blank? && user.email_verified?
        user.deliver_token(:password_link, true)
        flash.now[:notice] = 'An email with a link to create a new password has been sent to your email address.'.t
      else
        flash.now[:warning] = I18n.t(:confirm_email_before_password_reset)
      end
    else
      flash.now[:warning] = 'User name or e-mail address could not be found.'.t
    end

    render action: 'password_form'
  end

  def payment_status
    @user = current_user || Account.find(params[:client_id])
    @transaction = @user.payment_transactions.find(params[:payment_id])
    # @user = ensure_find(Account, params[:client_id] || current_user.id) or return
    # return permission_denied unless is_self?
  end


  protected

    def user_params
      params.fetch(:user, {}).permit(
        :login, :email, :password, :password_confirmation,
        :firstname, :lastname, :title,
        :research_interest,
        :newsletter
      )
    end

    def user_email_params
      params.fetch(:user, {}).permit(:email)
    end

    def license_user_params
      params.fetch(:user, {}).permit(:mode, :research_interest, :institution)
    end

    def invoice_address_params
      params.fetch(:invoice_address, {}).permit(
        :fullname, :addressline, :postalcode, :city, :country
      )
    end

    def set_mandatory_fields
      required  = Account::REQUIRED
      required += Account::REQUIRED_UNLESS_ANONYMOUS unless @user && @user.anonymous?
      required += Account::REQUIRED_UNLESS_VIA_INSTITUTION if @user && @user.needs_research_interest?
      required += %w[password]

      super required
    end

    def initialize_licence_variables
      @user = current_user

      @institutions = Institution.campuses_and_departments - [Institution.find_by!(name: 'prometheus')]

      @institution = if params[:user] && params[:user][:institution].present?
        Institution.find(params[:user][:institution])
      else
        @user.institution
      end

      types = ['paid', 'institution', 'guest']
      @type = params[:type] || @user.mode_type
      @type = 'paid' unless types.include?(@type)

      @address_hash = invoice_address_params
      @address_fields = %w[fullname addressline postalcode city country]
      @address_fields.each { |field| @address_hash[field] ||= @user.send(field) }

      @invoice_address = OpenStruct.new(@address_hash)

      # if @current_mode = @user.mode
      #   %w[guest institution paid paypal invoice].each { |mode|
      #     instance_variable_set("@current_mode_#{mode}", @user.mode.send("#{mode}?"))
      #   }
      # end

      set_mandatory_fields
    end

end
