class AccountMailerPreview < ActionMailer::Preview

  def welcome
    configure
    PandoraMailer.welcome(Account.first)
  end

  def activation_request
    configure
    PandoraMailer.activation_request(Account.first)
  end

  protected

    def configure
      PandoraMailer.default_url_options = {
        host: 'localhost',
        port: 3000
      }
    end

end