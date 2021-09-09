class AccountsController < ApplicationController

  skip_before_action :store_location, :only => ADMINISTRATIVE_ACTIONS + [:suggest_names]

  # the partial remote forms are using POST requests to the show action
  # when the cancel button is clicked ... obviously without the token
  skip_before_action :verify_authenticity_token, only: ['show', 'login']
  skip_before_action :verify_account_signup_complete, only: ['show']

  def self.initialize_me!
    control_access [:superadmin, :admin, :useradmin] => :ALL,
                   # api compatibility
                   [:user] => [:show, :email, :suggest_names]

    linkable_actions :create, :list, *Account::FILTERS
  end
  
  api_method :show, :get => {
    :doc => "Get a user record.",
    :expects => { :id => { :type => 'string', :required => true, :doc => 'The id of the user record.' } },
    :returns => { :xml => { :root => 'user' }, :json => {} }
  }

  def index
    list
  end

  def active
    list(:active)
  end

  def pending
    list(:pending)
  end

  def expired
    list(:expired)
  end

  def guest
    list(:guest)
  end

  def show
    respond_to do |format|
      format.html do
        @user = Account.find_by!(login: params[:id])

        # view compatibility
        @is_self = false
        set_collections_and_presentations
      end
      format.xml do
        if params[:id]
          @user = Account.find(params[:id])
        else
          @user = current_user
        end

        render xml: @user.to_xml(only: [:id, :firstname, :lastname, :email, :accepted_terms_of_use_revision])
      end
      format.json do
         if params[:id]
          @user = Account.find(params[:id])
        else
          @user = current_user
        end

        render json: @user.to_json(only: [:id, :firstname, :lastname, :email, :accepted_terms_of_use_revision])
      end
    end
  end

  def new
    @user = Account.new(account_params)

    # view compatibility
    set_mandatory_fields
    set_expires_in_options(:create)
    @institutions = Institution.order(:name)
    @roles = current_user.allowed_roles
  end

  def create
    set_expires_in_options(:create)

    ap = account_params
    @user = Account.new(ap)

    roles = (ap[:role_ids] ? Role.find(ap[:role_ids]) : Role.where(title: 'user'))
    return permission_denied unless roles.empty? || current_user.roles_allowed?(roles)
    return redirect_back_or_default if anonymous?(roles)

    @user.roles = roles

    # with this action, an admin creates an account, so we can assume he knows
    # what he is doing
    @user.email_verified_at = Time.now
    @user.status = 'activated'

    if @user.save
      check_admin_institutions

      flash[:notice] = "Account '#{@user.login}' successfully created!"
      redirect_to action: 'show', id: @user.login
    else
      # view compatibility
      set_mandatory_fields
      @institutions = Institution.order(:name)
      @institution = @user.institution
      @roles = current_user.allowed_roles

      render action: 'new', status: 422
    end
  end

  def email
    @text = params[:text]
    @to   = params[:to] || ''

    if request.post?
      if @text.blank?
        flash.now[:warning] = 'Your message was empty...'.t
        return
      end

      recipients, invalid_or_not_found = [], []

      Account.from_textarea(@to, true) { |user, to|
        if user and user.email_verified? and user.active? and current_user.allowed?(user, :read)
          recipients << user
        else
          invalid_or_not_found << to
        end
      }

      unless invalid_or_not_found.empty?
        flash[:warning] = 'Some users were invalid or could not be found: %s' / invalid_or_not_found.join(', ')
        return
      end

      if recipients.empty?
        flash[:warning] = 'No recipients provided!'.t
        return
      end

      recipients.each { |recipient|
        current_user.deliver(:usermail, recipient, @text)
      }

      current_user.deliver(:usermail_response, recipients, @text)

      flash[:notice] = 'Your message has been delivered.'.t
      redirect_back_or_default(:previous, :start)
    end
  end

  def suggest_names
    @accounts = current_user.
      allowed_accounts(:read).
      exclude(current_user).
      email_verified.
      non_subscribers.
      where('login NOT IN (?)', ['campus', 'source']). # TODO: do we still need that?
      search('label', params[:q]).
      sorted(sort_column, sort_direction).
      limit(20).
      to_a

    # filter by the action allowed
    if only = params[:only]
      c, a = only.split('/', 2)
      @accounts.select{|e| e.action_allowed?(c, a)}
    end
    @accounts = @accounts.first(10)

    render :partial => 'suggest_names'
  end

  def edit
    @user = Account.find_by!(login: params[:id])
    @institution = @user.institution

    # view compatibility
    @institutions = Institution.order(:name)
    set_mandatory_fields
    set_expires_in_options(:edit)
    @roles = current_user.allowed_roles

    if current_user.useradmin?
      if @user.expires? || @user._expired?
        part = (@user.expired? ? 'expired' : 'about to expire')
        flash[:prompt] = [
          "This user is #{part}. Please fill in the field 'Expiration' below",
          "after you have checked the user's entitlement."
        ].join(' ').t
        set_prompt_field(:expires_in)
      end
    end
  end

  def update
    @user = Account.allowed(current_user, :write).find_by!(login: params[:id])

    # view compatibility
    @institutions = Institution.order(:name)
    set_mandatory_fields
    set_expires_in_options(:edit)
    @roles = current_user.allowed_roles

    @user.assign_attributes(account_params(@user))

    if @user.save
      welcome_user = (
        @user.status == 'activated' &&
        @user.attribute_before_last_save(:status) == 'pending'
      )
      @user.deliver(:welcome) if welcome_user

      link = helpers.link_to(@user.login, account_path(@user))
      flash[:notice] = "Account '%s' successfully updated!" / link

      # sets flash if useradmin without admin institutions
      check_admin_institutions

      redirect_to action: 'show', id: @user.login
    else
      set_mandatory_fields
      
      render action: 'edit', status: 422
    end
  end

  def disable
    @user = current_user.allowed_accounts(:write).find_by!(login: params[:id])
    @user.disable!

    log_out if @user.id == current_user.id

    flash[:notice] = "Account '%s' successfully disabled!" / @user.login
    redirect_to action: 'index'
  end

  def destroy
    @account = current_user.allowed_accounts(:write).find_by!(login: params[:id])
    @account.destroy

    flash[:notice] = "Account '%s' successfully deleted!" / @account.login
    redirect_to action: 'index'
  end

  initialize_me!

  protected

    def set_mandatory_fields
      required  = Account::REQUIRED
      required += Account::REQUIRED_UNLESS_ANONYMOUS unless @user.anonymous?
      required += Account::REQUIRED_UNLESS_VIA_INSTITUTION if @user.needs_research_interest?
      required += %w[password] if @user.send(:password_required?)

      super required
    end

    def set_expires_in_options(action)
      @expires_in_options = if create = action == :create
        [
          ["#{'%d week'  / 1} (#{'guest'.t})", 1.week],
          ["#{'%d month' / 1} (#{'guest'.t})", 1.month]
        ]
      elsif @user.status == 'activated'
        [['Deactivate'.t, 0]]
      elsif @user.status == 'pending'
        [['Deactivate'.t, 0],
         ['Activate'.t, 1]]
      else
        [['Activate'.t, 1]]
      end

      @expires_in_options << ['%d week' / 1, 1.week]
      @expires_in_options << ['%d months' / 3, 3.months]
      @expires_in_options << ['%d months' / 6, 6.months]

      [1, 2, 3].each { |count|
        @expires_in_options << [pm_labelled_counter(count, '%d year', '%d years'), count.years]
      }

      @set_expires_in       = create || !@is_self
      @expires_in_selected  = create && !current_user.admin_or_superadmin? ? 1.year : nil
    end

    def sanitize_expires_in!(user_params)
      # REWRITE: the value can either be set via a duration (e.g. "3 months" via
      # :expires_in) or a specific date (e.g. "2022-03-15" via :expires_at). The
      # multiparameter assignment isn't in rails anymore so we do the simplest
      # thing possible to reconstruct :expires_at
      expires_at = "#{user_params['expires_at(1i)']}-#{user_params['expires_at(2i)']}-#{user_params['expires_at(3i)']}"
      user_params.delete 'expires_at(1i)'
      user_params.delete 'expires_at(2i)'
      user_params.delete 'expires_at(3i)'
      user_expires_at = nil
      if expires_at.match(/^[0-9]{1,4}-[0-9]{1,2}-[0-9]{1,2}$/)
        expires_at      = Time.parse(expires_at).at_end_of_day
        user_expires_at = if @user && @user.expires_at
          @user.expires_at.at_end_of_day.to_time
        end
        user_params[:expires_at] = expires_at unless expires_at == user_expires_at
      else
        user_params.delete :expires_at
      end
      # if expires_at = @user.type_cast_multiparameter_attribute!(:expires_at, user)
      #   expires_at      = expires_at.at_end_of_day
      #   user_expires_at = @user.expires_at.at_end_of_day if @user.expires_at

      #   user[:expires_at] = expires_at unless expires_at == user_expires_at
      # end

      # REWRITE: make this less confusing
      # unless user[:expires_in].blank?
      #   unless user[:expires_at].blank?
      if user_params[:expires_in].present?
        if user_params[:expires_at].present?
          # REWRITE: we will prefer expires_in because the field can be left blank
          # in the form
          # @user.errors.add :base, 'Please choose either a period or a new expiration date.'

          # # mark fields as invalid
          # @user.errors.add(:expires_in)
          # @user.errors.add(:expires_at)

          # return
          user_params.delete :expires_at
        end

        if current_user.useradmin_only?
          i = user_params[:expires_in].to_s

          unless i =~ /\A\d+(?:\.\d+)?\z/ && @expires_in_options.rassoc(i.to_i)
            user_params[:expires_in] = '0'
          end
        end

        if user_params[:expires_in] == '0'
          user_params[:deactivate] = true
          # existing.status.deactivated
          user_params.delete(:expires_in)
        end
      else
        # REWRITE: make this less confusing
        # unless user[:expires_at].blank?
        if user_params[:expires_at].present?
          user_params[:expiration] = {
            at: expires_at,
            enable: !user_expires_at || expires_at > user_expires_at
          }
          # existing.set_expiration(expires_at, !user_expires_at || expires_at > user_expires_at)
          user_params.delete(:expires_at)
        end
      end

      true
    end

    def check_admin_institutions
      is_useradmin, has_admin_institutions = @user.useradmin?, @user.admin_institutions.any?
      role = Role.find_by!(title: 'useradmin').to_s.humanize.t if is_useradmin || has_admin_institutions

      if is_useradmin && !has_admin_institutions
        flash[:info] = 'User has role %s, but no institutions to administer.' / role
      elsif has_admin_institutions && !is_useradmin
        flash[:info] = 'User has institutions to administer, but not role %s.' / role
      end
    end

    def set_collections_and_presentations
      @public_collections   = @shared_collections   = false
      # REWRITE: functionality removed
      # @public_presentations = @shared_presentations = false

      unless @user.inactive?
        # REWRITE: use new query interface
        # @public_collections   = @user.public_collections
        @public_collections = @user.collections.public
        # REWRITE: functionality removed
        # @public_presentations = @user.public_presentations

        unless @is_self
          # REWRITE: use new ar interface
          # @shared_collections   = @current_user.shared_collections(@user)
          @shared_collections = @user.collections.shared(current_user)
          # REWRITE: functionality removed
          # @shared_presentations = current_user.shared_presentations(@user)
        end
      end
    end

    def anonymous?(roles)
      ipuser = Role.find_by!(title: 'ipuser')
      dbuser = Role.find_by!(title: 'dbuser')
      if roles.include?(ipuser) || roles.include?(dbuser)
        flash[:warning] = "Anonymous users can't be created that way".t
        true
      end
    end

    def account_params(existing = nil)
      sanitize_expires_in!(params[:user] || {})

      result = params.fetch(:user, {}).permit(
        :login, :email, :password, :password_confirmation, :institution,
        :firstname, :lastname, :title, :addressline, :postalcode, :city,
        :country,
        :newsletter, :about, :research_interest, :local_identifier, :notes,
        :expires_in, :expires_at, :deactivate, :locale,
        admin_institution_ids: [],
        role_ids: [],
        expiration: {},
        _translations: {en: {}, de: {}}
      )

      result[:creator_id] = current_user.id
      result[:locale] ||= I18n.locale

      # ensure roles can only be customized by admins and superadmins
      role_ids = (result[:role_ids] || []).select{|e| e.present?}.map{|e| e.to_i}
      if current_user.superadmin?
        result[:role_ids] = role_ids
      elsif current_user.admin?
        result[:role_ids] = role_ids
        if existing
          sa_id = Role.find_by!(title: 'superadmin').id
          if existing.superadmin?
            result[:role_ids] |= [sa_id]
          else
            result[:role_ids] -= [sa_id]

            # we remove the entire attribute if no more roles are left to be set
            result.delete :role_ids if result[:role_ids].empty?
          end
        end
      end

      # ensure institutions can only be set according to permissions
      id = result.delete(:institution)
      if id.present?
        institution = Institution.find(id)
        allowed = 
          current_user.admin_or_superadmin? ||
          (
            current_user.useradmin? &&
            current_user.admin_institutions.include?(institution)
          )

        if allowed
          result[:institution_id] = id
        else
          result[:institution_id] = Institution.prometheus.id
        end
      end

      # ensure admin institutions are not assigned without permissions
      if ids = result.delete(:admin_institution_ids)
        if ids = ids.select{|e| e.present?}
          if current_user.admin_or_superadmin?
            result[:admin_institution_ids] = ids
          end
        end
      end

      # set user mode
      if [1.month, 1.week].include?(result[:expires_in].to_i)
        result[:mode] = 'guest'
      end
      
      id = result[:institution_id]
      if id && id != Institution.prometheus.id.to_s
        result[:mode] = 'institution'
      end

      # research should only be overwritten by admin, if there is no research interest specified
      role = 'super admin'
      role = 'user admin' if current_user.useradmin?
      role = 'admin' if current_user.admin?
      if result[:research_interest].blank?
        result[:research_interest] = [
          'n.a.'.t, '-', role.t, "\"#{current_user}\"."
        ].join(' ')
      end

      result
    end

    def list(what = nil)
      @accounts = current_user.
        allowed_accounts(:write).
        personal.
        search(search_column, search_value).
        sorted(sort_column, sort_direction)

      @accounts = case what
      when :active then @accounts.active
      when :pending then @accounts.pending
      when :expired then @accounts.expired
      when :guest then @accounts.guests
      else @accounts
      end

      # view compatibility
      @page = page
      @per_page = per_page
      @users = Pandora::Collection.new(
        @accounts.pageit(page, per_page),
        @accounts.count,
        page,
        per_page
      )

      render action: 'list'
    end

    def sort_column_default
      account_settings[:order] || 'login'
    end

    def sort_direction_default
      account_settings[:direction] || (
        sort_column == 'relevance' ? 'desc' : 'asc'
      )
    end

    def per_page_default
      account_settings[:per_page] || super
    end

    def view_default
      account_settings[:view] || super
    end

    def account_settings
      current_user.try(:account_settings) || {}
    end

end
