module Pandora
  class EmailObserver
    def self.delivered_email(message)
      Rails.logger.info message.to_s
    end
  end
end

if ENV['PM_FULL_EMAIL_LOGGING'] == 'true'
  Rails.application.configure do
    config.action_mailer.observers = ['Pandora::EmailObserver']
  end
end
