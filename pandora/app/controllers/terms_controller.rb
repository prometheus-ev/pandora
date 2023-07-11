class TermsController < ApplicationController
  skip_before_action :login_required, only: ['show']
  skip_before_action :verify_account_terms_accepted, only: ['edit', 'update']

  def show
    send_file "public/docs/terms_of_use#{Locale.ext(true)}.pdf"
  end

  def edit

  end

  def update
    if !params[:accepted]
      message = 'You have to accept our terms of use to be able to use the prometheus image archive.'.t

      respond_to do |format|
        format.html do
          flash.now[:warning] = message
          render action: 'edit'
        end
        format.json{ render json: {message: message}, status: 422 }
        format.xml{ render xml: {message: message}, status: 422 }
      end
    else
      if current_user.ipuser? || current_user.dbuser?
        session[:accepted_terms_of_use] = true
      else
        current_user.accepted_terms_of_use!
      end

      respond_to do |format|
        format.html do
          url = params[:return_to].presence || root_url
          redirect_to(url, allow_other_host: true)
        end
        format.json do
          render json: current_user.to_json(only: [:id, :firstname, :lastname, :email, :accepted_terms_of_use_revision])
        end
        format.xml do
          render xml: current_user.to_xml(only: [:id, :firstname, :lastname, :email, :accepted_terms_of_use_revision])
        end
      end
    end
  end


  # API docs

  api_method :terms_of_use, :get => {
    :doc => "Get current terms of use.",
    :returns => { :xml => {}, :json => {} }
  }

  api_method :terms_of_use, :post => {
    :doc => "Accept current terms of use.",
    :expects => {
      :accepted => { :type => 'string', :required => true, :doc => 'True if accepted, false otherwise.' }
    },
    :returns => { :xml => {}, :json => {} }
  }
  
end
