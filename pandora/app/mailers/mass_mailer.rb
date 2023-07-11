class MassMailer < ApplicationMailer
  include Util::ActiveMailer

  def email
    email = params[:email]
    to = params[:to] || email.recipients
    user = params[:user]
    by = params[:by]

    locale = user.locale if user
    prefix = email.tag.blank? ? '' : "[prometheus-#{email.tag}] "

    unsubscribe_options = {
      controller: 'subscriptions',
      action: 'unsubscribe_form'
    }
    signup_options = {
      controller: 'signup',
      action: 'signup_form'
    }

    if newsletter = email.newsletter? and email.individual? and user
      address = case to
        when String then to
        when Array  then to.first if to.size == 1
        when Hash then to.values[0]
      end

      if address
        @unsubscribe_url = short_url_for(unsubscribe_url(
          only_path: true,
          email: address,
          token: RackImages::Secret.token_for(address, 1.week.from_now)
        ))
        @signup_url = short_url_for(signup_url(
          only_path: true,
          email: address
        ))
      end
    end

    @email = email
    @user = user
    @locale = locale
    @newsletter = newsletter
    @unsubscribe_url ||= unsubscribe_url
    @signup_url ||= signup_url
    @newsletter_url = webview_newsletter_url(email)

    @root_url = root_url
    @root_url_without_locale = root_url(:locale=>nil)

    unless to.is_a?(Hash)
      to = {to: to}
    else
      to.delete :to if to[:to].blank?
      to.delete :cc if to[:cc].blank?
      to.delete :bcc if to[:bcc].blank?
    end

    headers['Reply-To'] = email.reply_to unless email.reply_to.blank?
    headers['X-Sender'] = by if by && !newsletter

    opts = {
      to: to[:to],
      cc: to[:cc],
      bcc: to[:bcc],
      from: email.from,
      subject: prefix + email.combined_subject(localized_or_combined(locale) { email.subject }),
    }

    mail opts do |format|
      format.text
      if email.body_html.present?
        format.html
      end
    end
  end

end
