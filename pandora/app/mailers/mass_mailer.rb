# REWRITE: the ar_mailer gem is simple to replace, so we do it once we have a
# clear idea how the process should work. We therefore write a new
# delivery_method that (for now) just behaves like :test
# class ARMailer < ActionMailer::ARMailer
class MassMailer < ApplicationMailer

  include Util::ActiveMailer

  # REWRITE: see above
  # self.delivery_method = :activerecord
  # self.delivery_method = Pandora::MassDelivery

  ### Generic e-mail (and newsletter)

  def email(email, to = email.recipients, user = nil, by = nil)
    locale = user.locale if user
    prefix = email.tag.blank? ? '' : "[prometheus-#{email.tag}] "

    unsubscribe_options = {
      controller: 'subscriptions',
      action: 'unsubscribe_form'
    }
    signup_options      = { controller: 'signup', action: 'signup_form' }
    # REWRITE: see below
    # root_options        = { :controller => '' }

    # REWRITE: this helper is provided by rails
    # root_url = url_for(root_options)

    if newsletter = email.newsletter? and email.individual? and user
      address = case to
        when String then to
        when Array  then to.first if to.size == 1
      end

      if address
        user_options = { :user => { :email => address } }

        unsubscribe_url = short_url_for(unsubscribe_options.merge(user_options))
        signup_url      = short_url_for(signup_options.merge(user_options))
      end
    end

    # REWRITE: mails are composed differently now
    # from    email.from
    # subject prefix + email.combined_subject(localized_or_combined(locale) { email.subject })
    # body    :email           => email,
    #         :user            => user,
    #         :locale          => locale,
    #         :newsletter      => newsletter,
    #         :unsubscribe_url => unsubscribe_url || url_for(unsubscribe_options),
    #         :signup_url      => signup_url      || url_for(signup_options),
    #         :newsletter_url  => newsletter_url,
    #         :root_url        => root_url
    @email = email
    @user = user
    @locale = locale
    @newsletter = newsletter
    @unsubscribe_url = unsubscribe_url || url_for(unsubscribe_options)
    @signup_url = signup_url || url_for(signup_options)
    @newsletter_url = webview_newsletter_url(email)

    @root_url = root_url
    @root_url_without_locale = root_url(:locale=>nil)

    # REWRITE: see above
    unless to.is_a?(Hash)
      # recipients to if to
      to = {to: to}
    else
      # recipients to[:to]  unless to[:to].blank?
      # cc         to[:cc]  unless to[:cc].blank?
      # bcc        to[:bcc] unless to[:bcc].blank?
      to.delete :to if to[:to].blank?
      to.delete :cc if to[:cc].blank?
      to.delete :bcc if to[:bcc].blank?
    end

    headers['Reply-To'] = email.reply_to unless email.reply_to.blank?
    headers['X-Sender'] = by if by && !newsletter

    # REWRITE: see above
    # unless email.body_html.blank?
    #   part :content_type => "text/html", :body => render_message("email-html", body)
    # end

    # REWRITE: see above
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

# REWRITE: probably not needed anymore
# ArMailer = ARMailer
