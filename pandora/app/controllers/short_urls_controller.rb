class ShortUrlsController < ApplicationController
  # skip_before_action :store_location
  skip_before_action :login_required
  skip_before_action :verify_account_email
  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_signup_complete
  skip_before_action :verify_account_terms_accepted

  def redirect
    @token = params[:token]
    @short_url = ShortUrl.get(@token)

    if @short_url
      redirect_to @short_url.url, status: :moved_permanently
    else
      flash[:error] = (@token.nil? ?
        "No token was given".t :
        "The link with token '%s' couldn't be found" / @token
      )
      redirect_to locale_root_path
    end
  end
end
