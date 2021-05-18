class ApplicationMailer < ActionMailer::Base
  default from: "prometheus <#{SENDER_ADDRESS}>"
  layout 'mailer'

  after_action :global_redirect

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
end
