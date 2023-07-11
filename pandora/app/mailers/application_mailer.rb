class ApplicationMailer < ActionMailer::Base
  default from: "prometheus <#{ENV['PM_INFO_ADDRESS']}>"
  layout 'mailer'

  after_action :global_redirect
  around_action :apply_user_locale

  def global_redirect
    if address = ENV['PM_GLOBAL_MAIL_REDIRECT']
      [:to, :cc, :bcc].each do |k|
        if headers[k]
          headers[k] = nil
          headers[k] = address
        end
      end
    end
  end

  def apply_user_locale
    @user = params[:user]

    locale = @user ? @user.locale : I18n.locale
    I18n.with_locale locale do
      yield
    end
  end

  def params
    super || {}
  end
end
