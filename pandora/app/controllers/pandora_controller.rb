class PandoraController < ApplicationController

  include Util::Config
  include Util::ActionAPI::Controller

  skip_before_action :login_required, except: [:start]
  skip_before_action :store_location, except: [:about, :sitemap, :api]

  skip_before_action :verify_account_email
  skip_before_action :verify_account_active
  skip_before_action :verify_account_not_deactivated
  skip_before_action :verify_account_signup_complete
  skip_before_action :verify_account_terms_accepted


  def about
    respond_to do |format|
      format.html
      format.json do
        data = base_facts.merge(facts: Pandora::Facts.facts)
        render json: data
      end
      format.xml do
        data = base_facts.merge(facts: Pandora::Facts.facts)
        render xml: data.to_xml(root: 'pandora')
      end
    end
  end

  api_method :about, skip_controller: true, get: {
    doc: 'Get basic information about pandora.',
    returns: {
      xml: {
        root: 'pandora',
        hints: ['version', 'facts']
      },
      json: {}
    }
  }

  def facts
    data = base_facts.merge(Pandora::Facts.data)

    respond_to do |format|
      format.xml do
        render xml: data.to_xml(root: 'pandora')
      end
      format.json do
        render json: data, callback: params[:callback]
      end
    end
  end

  api_method :facts, skip_controller: true, get: {
    doc: 'Get basic facts about pandora.',
    returns: {
      xml: {
        root: 'pandora',
        hints: ['images', 'sources', 'licenses', 'accounts', 'version']
      },
      json: {}
    }
  }

  def start
    redirect_to default_location(:start)
  end

  def back
    redirect_back_or_default
  end

  def sitemap
    respond_to do |format|
      format.html
    end
  end

  def feedback_form
    create_brain_buster

    @feedback = Pandora::Feedback.new

    if current_user
      @feedback.assign_attributes(
        name: current_user.fullname,
        email: current_user.email
      )
    end
  end

  def feedback
    @feedback = Pandora::Feedback.new(feedback_params)

    unless validate_brain_buster
      create_brain_buster
      render action: 'feedback_form'
      return
    end

    if @feedback.valid?
      AccountMailer.feedback(@feedback).deliver_now
      unless @feedback.email.blank?
        AccountMailer.feedback_response(@feedback).deliver_now
      end

      flash[:notice] = 'Your feedback has been delivered. Thank you!'.t
      redirect_back fallback_location: locale_root_url
    else
      render action: 'feedback_form', status: 422
    end
  end

  def remote_ip
    @ip = request.remote_ip
    @institution = Institution.find_by_ip(@ip)
    @env = request.env
  end

  def toggle_frontend
    mapping = {'legacy' => 'ng', 'ng' => 'legacy'}

    session[:frontend] = mapping[session[:frontend] || 'legacy']

    render json: {message: "frontend changed to #{session[:frontend]}"}
  end

  def toggle_news
    session[:news_collapsed_time] = Time.new.utc
    session[:news_collapsed] = (params[:value] == ':true')

    head :ok
  end

  def toggle_box
    id, collapsed = params[:value].split(':')
    @box = Box.find(id)

    box.update_attribute(:expanded, collapsed != 'true')

    head :ok
  end

  def conference_signup_form
    create_brain_buster

    @signup = Pandora::ConferenceSignup.new
  end

  def conference_signup
    @signup = Pandora::ConferenceSignup.new(conference_signup_params)

    unless validate_brain_buster
      create_brain_buster
      render action: 'conference_signup_form'
      return
    end

    if @signup.valid?
      AccountMailer.conference_signup(@signup).deliver_now
      AccountMailer.conference_signup_response(@signup).deliver_now

      flash[:notice] = 'Your registration was sucessful. Thank you!'.t
      redirect_to action: "conference_signup_confirmation"
    else
      render action: 'conference_signup_form', status: 422
    end
  end

  def conference_signup_confirmation

  end

  def internal_server_error
    respond_to do |format|
      format.html do
        @no_submenu = true

        render(
          template: 'shared/misc/_internal_server_error',
          status: 500
        )
      end
      format.json{ render json: {message: 'internal server error'}, status: 500 }
      format.xml{ render xml: {message: 'internal_server_error'}, status: 500 }
    end
  end


  protected

    def base_facts
      {
        version: Pandora::Version.to_s,
        revision: Pandora.revision
      }
    end

    def conference_signup_params
      params.fetch(:signup, {}).permit(
        :person_title,
        :first_name, :last_name,
        :street, :postal_code, :city,
        :country,
        :institution,
        :email,
        :brauhaus, :akdk,
        :note
      )
    end

    def feedback_params
      params.fetch(:feedback, {}).permit(:name, :email, :text)
    end

end
