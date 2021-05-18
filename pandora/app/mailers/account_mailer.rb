class AccountMailer < ApplicationMailer
  include Util::ActiveMailer

  # REWRITE: there is an interface for this now and we do this in
  # ApplicationMailer
  # def initialize(*args)
  #   from "prometheus <#{SENDER_ADDRESS}>"
  #   super
  # end

  ### Welcome

  def welcome(user)
    welcome = !user.status?
    @welcome = welcome

    @expires = ""
    if user.expires_at && !user.exempt_from_expiration?
      if [Date, DateTime, Time].any? { |c| user.expires_at.is_a? c }
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
    @record_count = Pandora::Elastic.new.counts['total']['value'].localize
    @source_count = Source.count_active
    @home_url = ENV['PM_HOME_URL']
    @rights_url = "#{ENV['PM_HOME_URL']}/copyright"

    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + (welcome ? 'Welcome to prometheus!' : 'Your account has been activated').t
    )
  end

  ### Usermail

  def usermail(user, recipient, text)
    @user = user
    @locale = recipient.locale
    @text = text
    @profile_url = url_for(:controller => 'accounts', :action => 'show', :id => user.login)

    opts = {
      to: recipient.email,
      subject: '[prometheus-Message] ' + localized_or_combined(locale) { 'Message from user %s' / user },
    }
    opts[:reply_to] = user.email unless user.email.blank?

    mail opts
  end

  ### Invoice notice

  INVOICE_NOTICE_RECIPIENTS = [ENV['PM_INVOICE_NOTIFICATION_RECIPIENTS']]

  def invoice_notice(user, address, discount_code = nil)
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

  def paypal_confirmation(user, success)
    @name = user.fullname
    @expires = user.expires_at
    @success = success

    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + 'Your payment via PayPal'.t,
    )
  end

  ### Collection/Presentation collaborators

  def collaborator_changed(user, object, action = :added, what = :collaborator)
    klass, locale = object.class, user.locale

    # recipients user.email
    # subject    "[prometheus-#{klass}] " + localized_or_combined(locale) { "#{action.to_s.capitalize} as #{what}".t }
    # body       :owner       => object.owner.fullname,
    #            :profile_url => url_for(:controller => 'accounts', :action => 'show', :id => object.owner),
    #            :type        => type = klass.controller_name,
    #            :object      => object.title,
    #            :object_url  => url_for(:controller => type, :action => 'edit', :id => object),
    #            :locale      => locale,
    #            :action      => action,
    #            :what        => what
    # headers    'Reply-To' => user.email unless user.email.blank?
    
    @owner =  object.owner.fullname
    @profile_url =  url_for(:controller => 'accounts', :action => 'show', :id => object.owner)
    @type =  type = klass.controller_name
    @object =  object.title
    @object_url =  url_for(:controller => type, :action => 'edit', :id => object)
    @locale =  locale
    @action =  action
    @what =  what
    
    opts = {
      to: user.email,
      subject: "[prometheus-#{klass}] " + localized_or_combined(locale) { "#{action.to_s.capitalize} as #{what}".t },
    }
    
    unless user.email.blank?
      opts[:reply_to] = user.email
    end
    
    mail(opts)
  end

  ### Notifications

  def password_link(user, timestamp, token)
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

  def password_changed(user, originator)
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

  def email_confirmation(user, timestamp, token)
    @name = user.fullname
    @link = url_for(
      controller: 'signup',
      action: 'confirm_email_linkback',
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

    # @name = data[:name]
    # @link = data[:link]
    # @short_link = data[:short_link]
    # @expires = data[:expires]
    mail(
      to: user.email,
      subject: '[prometheus-Account] ' + 'Confirmation link'.t
    )
  end

  def activation_request(user)
    @name = user.fullname
    @login = user.login
    @email = user.email
    @account_url = url_for(controller: 'accounts', action: 'show', id: user.login)
    @research_interest = user.research_interest
    @mode = user.mode
    mail(
      to: INFO_ADDRESS,
      subject: "[pandora-Activation] #{user.login} (##{user.id})",
      reply_to: user.email.presence
    )
  end

  def research_interest_check(user)
    @name = user.fullname
    @research_interest = user.research_interest
    @login = user.login
    @email = user.email
    @account_url = url_for(:controller => 'accounts', :action => 'show', :id => user.login)

    mail(
      to: INFO_ADDRESS,
      subject: "[pandora-ResearchInterestCheck] #{user.login} (##{user.id})"
    )
  end

  def newsletter_subscription(user, timestamp, token)
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

  def newsletter_unsubscription(user, timestamp, token)
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

  def expiration_notification(user)
    locale = user.locale

    recipients user.email
    subject    '[prometheus-Account] ' + localized_or_combined(locale) { 'Your account expires!'.t }
    body       :expires     => user.expires_at,
               :name        => user.fullname,
               :institution => user.mode == 'institution' && user.institution.fulltitle,
               :public_info => user.institution.public_info,
               :guest       => user.mode == 'guest',
               :admins      => user.active_admins,
               :locale      => locale,
               :url         => url_for(:controller => 'accounts', :action => 'license')
  end

  def feedback(feedback)
    @feedback = feedback

    opts = {
      to: INFO_ADDRESS,
      subject: '[pandora-Feedback]'
    }
    opts[:reply_to] = @feedback.email unless @feedback.email.blank?

    mail opts
  end

  def feedback_response(feedback)
    @feedback = feedback

    mail(
      to: @feedback.email,
      subject: '[prometheus-Feedback] ' + 'Your feedback'.t
    )
  end

  def usermail_response(user, recipients, text)
    @text = text
    @recipients = recipients.map { |recipient|
      [recipient, url_for(controller: 'accounts', action: 'show', id: recipient.login)]
    }

    mail(
      to: user.email,
      subject: '[prometheus-Message] ' + 'Your message'.t
    )
  end

  ### Publication

  def publication_inquiry(type, status, mode, data, image_info, institution, email)
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

  def publication_response(type, status, mode, data, image_info, institution, email, user)
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

  def conference_signup(signup)
    @signup = signup

    opts = {
      to: 'tagung@prometheus-bildarchiv.de',
      subject: "Anmeldung zur Tagung - #{@signup.first_name} #{@signup.last_name}"
    }
    opts[:reply_to] = @signup.email unless @signup.email.blank?

    mail(opts)
  end

  def conference_signup_response(signup)
    @signup = signup

    mail(
      to: @signup.email,
      subject: 'Anmeldung zur Tagung: Daten^7 – Digitales BilderLeben (1./2. Oktober 2019)'
    )
  end
end
