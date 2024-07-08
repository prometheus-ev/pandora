class PandoraController < ApplicationController
  include Util::Config
  include Util::ActionApi::Controller

  skip_before_action :login_required, except: [:start]

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

        if Rails.env.test?
          data['PM_TEST_VARIABLE'] = ENV['PM_TEST_VARIABLE']
        end

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

  def translations
    simple = I18n::Backend::Simple.new
    simple.load_translations
    pandora = I18n::Backend::Pandora.cache
    @translations = {
      'rails' => simple.translations,
      'legacy' => pandora
    }
    render json: @translations
  end

  def start
    redirect_to default_location(:start)
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

    if @feedback.valid? && @feedback.code.empty? && @feedback.send_by_email == '0'
      AccountMailer.with(feedback: @feedback).feedback.deliver_now
      unless @feedback.email.blank?
        AccountMailer.with(feedback: @feedback).feedback_response.deliver_now
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
    session[:news_collapsed] = (params[:value] == 'true')

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
      AccountMailer.with(signup: @signup).conference_signup.deliver_now
      AccountMailer.with(signup: @signup).conference_signup_response.deliver_now

      flash[:notice] = 'Your registration was sucessful. Thank you!'.t
      redirect_to action: "conference_signup_confirmation"
    else
      render action: 'conference_signup_form', status: 422
    end
  end

  def conference_signup_confirmation
  end

  # test environment only: trigger arbitrary exceptions handling
  def raise_exception
    klass = params[:exception].constantize
    test = params[:text]
    raise klass, params[:text] || "raised as requested"
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
        :first_name,
        :last_name,
        :street,
        :postal_code,
        :city,
        :country,
        :institution,
        :email,
        :presence,
        :empfang, :feier, :abendessen,
        :note
      )
    end

    def feedback_params
      params.fetch(:feedback, {}).permit(:name, :code, :send_by_email, :email, :message)
    end
end
