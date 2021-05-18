class JsController < ApplicationController
  layout false
  skip_before_action :login_required
  skip_before_action :store_location
  skip_before_action :verify_account_signup_complete
  skip_before_action :verify_account_email
  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_terms_accepted
  before_action :js_content_type

  protect_from_forgery except: :pandora

  def pandora
    @facts = Pandora::Facts.data
  end

  protected

    def js_content_type
      response.headers['Content-type'] = 'text/javascript; charset=utf-8'
    end
end
