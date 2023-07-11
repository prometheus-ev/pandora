class RedirectController < ApplicationController
  skip_before_action :login_required
  skip_before_action :verify_account_email
  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_signup_complete
  skip_before_action :verify_account_terms_accepted

  # handles the complex locale defaults
  def locale_redirect
    old_path = request.path.gsub(/\/$/, '')
    redirect_to new_url(old_path)
  end


  protected

    def new_url(path)
      candidate = "#{root_url(locale: nil)}#{default_locale}#{path}"
      URI(candidate.to_s)

      candidate
    rescue URI::InvalidURIError
      locale_root_url
    end
end
