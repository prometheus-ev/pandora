class AccountMailer < ApplicationMailer
  include Util::ActiveMailer

  skip_around_action :apply_user_locale, only: [:publication_response]

  def welcome
    user = params[:user]

    welcome = !user.status?
    @welcome = welcome

    @expires = ""
    if user.expires_at && !user.exempt_from_expiration?
      if [Date, DateTime, Time].any?{|c| user.expires_at.is_a? c}
        @expires = localize(user.expires_at, :format => :long)
      else
        @expires = user.expires_at.to_s
      end
    else
      @expires = "Saint Glinglin's Day".t
    end

    @name = user.fullname
    @login = user.login
    @institution = (user.mode == 'institution' && user.institution.fulltitle)
    @admins = user.active_admins
    @password_url = url_for(:controller => 'signup', :action => 'password')
    @license_url = url_for(:controller => 'signup', :action => 'license')
    @account_url = url_for(:controller => 'profile', :action => 'edit')
    @sitemap_url = url_for(:controller => 'pandora', :action => 'sitemap')
    @help_url = url_for(:controller => 'help', action: 'show')
    @record_count = Pandora::Elastic.new.counts['total']['records'].localize
    @source_count = Source.count_active
    @home_url = ENV['PM_HOME_URL']
    @rights_url = "#{ENV['PM_HOME_URL']}/copyright"

    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + (welcome ? 'Welcome to prometheus!' : 'Your account has been activated').t
    )
  end

  ### Usermail

  def usermail
    user = params[:user]
    recipient = params[:recipient]
    text = params[:text]

    @user = user
    @locale = recipient.locale
    @text = text
    @profile_url = url_for(:controller => 'accounts', :action => 'show', :id => user.login)

    opts = {
      to: recipient.email,
      subject: '[prometheus-Message] ' + localized_or_combined(locale){'Message from user %s' / user},
    }
    opts[:reply_to] = user.email unless user.email.blank?

    mail opts
  end

  ### Invoice notice

  INVOICE_NOTICE_RECIPIENTS = [ENV['PM_INVOICE_NOTIFICATION_RECIPIENTS']]

  def invoice_notice
    user = params[:user]
    address = params[:address]
    discount_code = params[:discount_code]

    @name = address.fullname
    @addressline = address.addressline
    @postalcode = address.postalcode
    @city = address.city
    @country = address.country
    @user = user
    @user_url = url_for(:controller => 'accounts', :action => 'show', :id => user.login)
    @amount = 45
    @discount_code = discount_code && discount_code.code
    @research_interest = user.research_interest

    mail(
      to: INVOICE_NOTICE_RECIPIENTS,
      subject: "[pandora-Invoice] #{user.login} (##{user.id})",
      reply_to: user.email
    )
  end

  ### PayPal confirmation

  def paypal_confirmation
    user = params[:user]
    success = params[:success]

    @name = user.fullname
    @expires = user.expires_at
    @success = success

    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + 'Your payment via PayPal'.t,
    )
  end

  ### Collection/Presentation collaborators

  def collaborator_changed
    user = params[:user]
    object = params[:object]
    action = params[:action] || :added
    what = params[:what] || :collaborator

    klass, locale = object.class, user.locale

    @owner = object.owner.fullname
    @profile_url = url_for(:controller => 'accounts', :action => 'show', :id => object.owner)
    @type = type = klass.controller_name
    @object = object.title
    @object_url = url_for(controller: type, id: object)
    @locale =  locale
    @action =  action
    @what = what

    opts = {
      to: user.email,
      subject: "[prometheus-#{klass}] " + localized_or_combined(locale){"#{action.to_s.capitalize} as #{what}".t},
    }

    unless user.email.blank?
      opts[:reply_to] = user.email
    end

    mail(opts)
  end

  ### Notifications

  def password_link
    user = params[:user]
    timestamp = params[:timestamp]
    token = params[:token]

    @name = user.fullname
    @link, @short_link = url_with_short_for(
      controller: 'profile',
      action: 'edit',
      login: user.login,
      timestamp: timestamp,
      token: token,
      reset_password: true
    )
    @expires = Time.at(timestamp.to_i)

    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + 'Forgotten prometheus password'.t
    )
  end

  def password_changed
    user = params[:user]
    originator = params[:originator]

    @name = user.fullname
    @home_url = ENV['PM_HOME_URL']
    @originator = originator.fullname_with_email
    @is_self = user == originator
    @ip = remote_ip
    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + 'Changed prometheus password'.t
    )
  end

  def email_confirmation
    user = params[:user]
    timestamp = params[:timestamp]
    token = params[:token]

    @name = user.fullname
    @link = url_for(
      controller: 'signup',
      action: 'confirm_email_linkback',
      login: user.login,
      timestamp: timestamp.to_fs,
      token: token
    )
    short_url = ShortUrl.find_or_create_by(url: @link)
    @short_link = url_for(
      controller: 'short_urls',
      action: 'redirect',
      token: short_url.token
    )
    @expires = Time.at(timestamp)

    # @name = data[:name]
    # @link = data[:link]
    # @short_link = data[:short_link]
    # @expires = data[:expires]
    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + 'Confirmation link'.t
    )
  end

  def activation_request
    user = params[:user]

    @name = user.fullname
    @login = user.login
    @email = user.email
    @account_url = url_for(controller: 'accounts', action: 'show', id: user.login)
    @research_interest = user.research_interest
    @mode = user.mode
    mail(
      to: ENV['PM_INFO_ADDRESS'],
      subject: "[pandora-Activation] #{user.login} (##{user.id})",
      reply_to: user.email.presence
    )
  end

  def research_interest_check
    user = params[:user]

    @name = user.fullname
    @research_interest = user.research_interest
    @login = user.login
    @email = user.email
    @account_url = url_for(:controller => 'accounts', :action => 'show', :id => user.login)

    mail(
      to: ENV['PM_INFO_ADDRESS'],
      subject: "[pandora-ResearchInterestCheck] #{user.login} (##{user.id})"
    )
  end

  def newsletter_subscription
    user = params[:user]
    timestamp = params[:timestamp]
    token = params[:token]

    @link = url_for(
      controller: 'subscriptions',
      action: 'confirm_subscribe',
      login: user.login,
      timestamp: timestamp,
      token: token
    )
    short_url = ShortUrl.find_or_create_by(url: @link)
    @short_link = url_for(
      controller: 'short_urls',
      action: 'redirect',
      token: short_url.token
    )
    @expires = Time.at(timestamp)

    mail(
      to: user.email,
      subject: '[prometheus-Newsletter] ' + 'Confirm subscription'.t
    )
  end

  def newsletter_unsubscription
    user = params[:user]
    timestamp = params[:timestamp]
    token = params[:token]

    @link = url_for(
      controller: 'subscriptions',
      action: 'confirm_unsubscribe',
      login: user.login,
      timestamp: timestamp,
      token: token
    )
    short_url = ShortUrl.find_or_create_by(url: @link)
    @short_link = url_for(
      controller: 'short_urls',
      action: 'redirect',
      token: short_url.token
    )
    @expires = Time.at(timestamp)

    mail(
      to: user.email,
      subject: '[prometheus-Newsletter] ' + 'Confirm unsubscription'.t
    )
  end

  def expiration_notification
    user = params[:user]

    @user = user
    @expires = user.expires_at
    @name = user.fullname
    @institution = user.mode == 'institution' && user.institution.fulltitle
    @public_info = user.institution.public_info
    @guest = user.mode == 'guest'
    @admins = user.active_admins
    @locale = user.locale
    @url = url_for(locale: user.locale, controller: 'signup', action: 'license_form')

    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + localized_or_combined(user.locale){'Your account expires!'.t}
    )
  end

  def feedback
    feedback = params[:feedback]

    @feedback = feedback

    opts = {
      to: ENV['PM_INFO_ADDRESS'],
      subject: '[pandora-Feedback]'
    }
    opts[:reply_to] = @feedback.email unless @feedback.email.blank?

    mail opts
  end

  def feedback_response
    feedback = params[:feedback]

    @feedback = feedback

    mail(
      to: @feedback.email,
      subject: '[prometheus-Feedback] ' + 'Your feedback'.t
    )
  end

  def usermail_response
    user = params[:user]
    recipients = params[:recipients]
    text = params[:text]

    @text = text
    @recipients = recipients.map do |recipient|
      [recipient, url_for(controller: 'accounts', action: 'show', id: recipient.login)]
    end

    mail(
      to: user.email,
      subject: '[prometheus-Message] ' + 'Your message'.t
    )
  end

  ### Publication

  def publication_inquiry
    type = params[:type]
    status = params[:status]
    mode = params[:mode]
    data = params[:data]
    image_info = params[:image_info]
    institution = params[:institution]
    email = params[:email]

    @type = type
    @status = status
    @mode = mode
    @data = data
    @image_info = image_info
    @institution = institution

    mail(
      to: email,
      subject: '[prometheus-Publication] ' + 'Publikationsanfrage'
    )
  end

  def publication_response
    type = params[:type]
    status = params[:status]
    mode = params[:mode]
    data = params[:data]
    image_info = params[:image_info]
    institution = params[:institution]
    email = params[:email]
    user = params[:user]

    @type = type
    @status = status
    @mode = mode
    @data = data
    @image_info = image_info
    @institution = institution
    @user = user

    mail(
      to: email,
      subject: '[prometheus-Publication] ' + 'Your publication inquiry'.t
    )
  end

  def conference_signup
    signup = params[:signup]

    @signup = signup

    opts = {
      to: 'tagung@prometheus-bildarchiv.de',
      subject: "Anmeldung zur Tagung - #{@signup.first_name} #{@signup.last_name}"
    }
    opts[:reply_to] = @signup.email unless @signup.email.blank?

    mail(opts)
  end

  def conference_signup_response
    signup = params[:signup]

    @signup = signup

    mail(
      to: @signup.email,
      subject: "Anmeldung zur Tagung: #{Pandora::ConferenceSignup::TITLE} (#{Pandora::ConferenceSignup::DATE})."
    )
  end

  def klapsch_match
    super_image = params[:super_image]
    owner = super_image.upload.database.owner
    @owner_name = (owner.is_a?(Account) ? owner.login : owner.name)
    @url = url_for(controller: 'images', action: 'show', id: super_image.pid)

    mail(
      to: ENV['PM_INFO_ADDRESS'],
      subject: 'User upload matches KLAPSCH filter'
    )
  end

  def indexing_finished
    to = params[:to]
    file = params[:file]

    @name = params[:name]

    # The mail is likely sent from outside a request cycle, so no base url
    # options are available
    base = Addressable::URI.parse(ENV['PM_BASE_URL'])
    @overview_url = url_for(
      host: base.host,
      port: base.port,
      protocol: base.scheme,
      locale: I18n.locale,
      controller: 'indexing'
    )

    if file
      file_content = File.read(file)
      attachments['result.json'] = file_content
      json = JSON.parse(file_content)
      @log = json["log"].join("\n")
    end

    mail(
      to: ENV['PM_INFO_ADDRESS'],
      subject: "indexing '#{@name}' has finished"
    )
  end
end
