class InstitutionsController < ApplicationController
  # skip_before_action :store_location, :only => [:renew_license]
  skip_before_action :login_required, :only => [:licensed]

  DEFAULT_ORDER = 'name'.freeze

  def self.initialize_me! # :nodoc:
    control_access [:superadmin, :admin] => :ALL,
                   [:user, :ipuser, :dbuser] => [:index, :mine, :show],
                   :DEFAULT => [:licensed]
  end

  def index
    unless admin_or_superadmin?
      redirect_to action: 'show', id: current_user.institution.name
      return
    end

    institutions = Institution.
      search(search_column, search_value).
      sorted(sort_column, sort_direction)

    # view compatibility
    @page = page
    @per_page = per_page
    @institutions = Pandora::Collection.new(
      institutions.pageit(page, per_page),
      institutions.count,
      page,
      per_page
    )
  end

  def licensed
    institutions = Institution.
      licensed_real.
      search(search_column, search_value).
      sorted(sort_column, sort_direction)

    # view compatibility
    @page = page
    @per_page = per_page
    @institutions = Pandora::Collection.new(
      institutions.pageit(page, per_page),
      institutions.count,
      page,
      per_page
    )

    render template: 'institutions/index'
  end

  def mine
    @institution = current_user.institution

    redirect_to institution_path(@institution)
  end

  def show
    @institution = Institution.find_by!(name: params[:id])
    @sources_counts = Pandora::Elastic.new.counts

    # view compatibility
    @user_administrators = @institution.active_admins.distinct.sort_by(&:lastname)
    @databases           = @institution.active_sources.sort_by(&:title)
    @departments         = @institution.departments.sort_by(&:title)
  end

  def new
    @institution = Institution.new

    # view compatibility
    @issuers       = Institution::ISSUERS
    @campuses      = Institution.includes(:licenses)
    @license_types = LicenseType.all
    @accounts = Account.not_anonymous
    set_mandatory_fields
  end

  def create
    @institution = Institution.new(institution_params)

    if @institution.save && @institution.update_ipuser
      flash[:notice] = "Institution '%s' successfully created!" / @institution.fulltitle

      redirect_to institution_path(@institution)
    else
      # view compatibility
      @license = @institution.license if @institution.license
      @issuers       = Institution::ISSUERS
      @campuses      = Institution.includes(:licenses)
      @license_types = LicenseType.all
      @accounts = Account.not_anonymous
      set_mandatory_fields

      render action: 'new', status: 422
    end
  end

  def edit
    @institution = Institution.find_by!(name: params[:id])

    # view compatibility
    @contact      = @institution.contact
    @campus       = @institution.campus
    @issuers       = Institution::ISSUERS
    @campuses      = Institution.includes(:licenses).where('institutions.id <> ?', @institution)
    @license_types = LicenseType.all
    @accounts = @institution.top_campus.all_accounts.not_anonymous.to_a | [@contact]
    @accounts.compact!
    @license      = @institution.license || @institution.next_license || License.new
    @license_type = @institution.license_type
    set_mandatory_fields
  end

  def update
    @institution = Institution.find_by!(name: params[:id])

    if @institution.update(institution_params)
      flash[:notice] = "Institution '%s' successfully updated!" / @institution.fulltitle
      redirect_to institution_path(@institution)
    else
      # view compatibility
      @contact      = @institution.contact
      @campus       = @institution.campus
      @issuers       = Institution::ISSUERS
      @campuses      = Institution.includes(:licenses).where('institutions.id <> ?', @institution)
      @license_types = LicenseType.all
      @accounts = @institution.top_campus.all_accounts.not_anonymous.to_a | [@contact]
      @accounts.compact!
      @license      = @institution.license || @institution.next_license || License.new
      @license_type = @institution.license_type
      set_mandatory_fields

      render action: 'edit'
    end
  end

  def renew_license
    if params[:id].blank?
      flash[:warning] = 'You have to select at least one institution'.t
      redirect_back fallback_location: institutions_path
      return
    end

    at = Time.now.next_year
    succeeded, failed = [], []

    [params[:id]].flatten.each {|id|
      institution = Institution.find(id)
      next unless institution

      if institution.renew_license(at)
        succeeded << institution
      else
        failed << institution
      end
    }

    flash[:warning] = 'License renewal failed for: %s' / failed.map {|i|
      "'#{i.fulltitle}'"
    }.join(', ') unless failed.empty?

    flash[:notice] = '%d licenses successfully renewed' / succeeded.size unless succeeded.empty?

    if params[:id].is_a?(Array)
      redirect_back fallback_location: institutions_path
    else
      institution = Institution.find(params[:id])
      redirect_to action: 'show', id: institution.name
    end
  end


  protected

    def institution_params
      institution = params[:institution] || {}
      Upgrade.extract_multi_param_date(institution, 'member_since')

      license = institution[:license_attributes] || {}
      Upgrade.extract_multi_param_date(license, 'valid_from')

      result = params.fetch(:institution, {}).permit(
        :name, :title, :short, :description, :public_info, :contact_id,
        :campus_id, :issuer, :addressline, :postalcode, :city, :country, :email,
        :homepage, :ipranges, :hostnames, :notes, :member_since,
        license_attributes: [:license_type, :paid_from_quarter, :valid_from]
      )

      result
    end

    def sort_column_default
      if action_name == 'licensed'
        'city'
      else
        'name'
      end
    end

    def per_page_default
      20
    end

    def sort_direction_default
      'asc'
    end

    initialize_me!
end
