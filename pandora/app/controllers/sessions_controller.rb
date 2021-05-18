class SessionsController < ApplicationController
  skip_before_action :login_required
  skip_before_action :verify_account_email
  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_signup_complete
  skip_before_action :verify_account_terms_accepted

  skip_before_action :verify_authenticity_token, only: ['create']

  before_action :cookies_required, only: ['new', 'campus']

  def self.initialize_me!
    control_access DEFAULT: :ALL
  end

  def campus
    ip = request.remote_ip
    institution = Institution.find_by_ip(ip)

    unless institution
      flash[:warning] = [
        "Sorry, your IP address %s doesn't match a licensed institution." / ip,
        translate_with_link(
          "Please see our %{help page}% for further information.",
          help_path(section: 'login', anchor: 'problems_campus')
        )
      ].join(' ').html_safe

      # flash_with_link(:warning,
      #   "Sorry, your IP address %s doesn't match a licensed institution." / ip +
      #   " " +
      #   "Please see our %_ for further information.",
      #   'help page',
      #   controller: 'help', action: 'show', section: 'login', anchor: 'problems_campus'
      # )

      redirect_to action: 'new'
      return
    end

    if institution.licensed?
      log_out
      log_in institution.ipuser

      if params[:accepted]
        session[:accepted_terms_of_use] = true
      end

      redirect_to(params[:return_to].presence || locale_root_url)
    else
      flash[:warning] = [
        'Your institution %s does no longer hold a license.' / institution.title,
        translate_with_link(
          'Please contact your local administrator or %{sign up}% for a personal account.',
          signup_url
        )
      ].join(' ').html_safe

      # flash_with_embedded_link(:warning, [
      #   'Your institution %s does no longer hold a license.' / institution.title,
      #   'Please contact your local administrator or %{sign up}% for a personal account.'.t
      # ], signup_url)

      redirect_to action: 'new'
    end
  end

  def new

  end

  def create
    @account = Account.find_by_login_or_email(params[:login])

    unless @account
      render_invalid_login_or_password
      return
    end

    if @account.banned?
      render_banned(@account)
      return
    end

    unless @account.password_matches?(params[:password])
      @account.log_failed_login!
      render_invalid_login_or_password
      return
    end

    if @account
      log_in(@account, remember_me: params[:remember_me] == '1')

      link = helpers.link_to(@account.fullname || @account.login, profile_path)
      flash[:notice] = 'Welcome, %s!' / link

      notify_upcoming_expiry(@account)

      redirect_to(params[:return_to] || default_location(:start))
    end
  end

  def destroy
    log_out

    redirect_to(ENV['PM_LOGOUT_URL'] || login_path)
  end


  protected

  def notify_upcoming_expiry(account)
    if account.expires? && account.status == 'activated'
      flash[:info] = [
        "Your #{'guest ' if account.mode == 'guest'}account is about to expire on %s." / helpers.localize_expiry_date(account),
        translate_with_link(
          'You can %{obtain a new license}% or contact your local administrator!',
          controller: 'signup', action: 'license'
        )
      ].join(' ').html_safe

      # flash_with_embedded_link(:info, [
      #   "Your #{'guest ' if account.mode.guest?}account is about to expire on %s." / helpers.localize_expiry_date(account),
      #   'You can %{obtain a new license}% or contact your local administrator!'.t
      # ], :controller => 'signup', :action => 'license')
    end
  end

  def cookies_required
    return unless session_enabled?

    tc = '_test_cookies'
    tv = params.delete(tc)

    session_key = params.delete('test_key')
    return if cookies['test_key'] ||= session_key

    if tv.blank?
      # set some cookie...
      cookies['test_key'] = tc

      # ...and try again
      redirect_to safe_params(tc => 1)
    else
      # no, really no cookies enabled!
      @current_page, @domain = safe_params, request.host
      render :template => 'pandora/no_cookies'
    end

    false
  end
end
