class SourcesController < ApplicationController
  include Util::Config

  skip_before_action :login_required, :only => [:index, :open_access, :open_access_login, :show]

  def self.initialize_me! # :nodoc:
    control_access [:superadmin, :admin] => :ALL,
                   :dbadmin => [:edit, :update, :ratings],
                   :DEFAULT => [:index, :open_access, :open_access_login, :show]

    linkable_actions :index, :open_access, :new
  end

  def index
    scope = records

    @sources = Pandora::SourceCollection.new(
      scope.pageit(page, per_page),
      scope.count,
      page,
      per_page
    )
    @sources_counts = Pandora::Elastic.new.counts

    respond_to do |format|
      format.html
      format.json do
        render json: @sources.to_json
      end
    end
  end

  api_method :list, get: {
    doc: 'Get a list of sources.',
    expects: {
      page: {
        doc: 'The page of results to return',
        default: 1,
        type: 'positiveInteger'
      },
      per_page: {
        doc: 'The amount of results per page to return',
        default: 10,
        type: 'positiveInteger'
      }
    },
    returns: {json: {}}
  }

  def open_access
    if Source.any_open_access?
      scope = records.open_access

      @sources = Pandora::SourceCollection.new(
        scope.pageit(page, per_page),
        scope.count,
        page,
        per_page
      )
      @sources_counts = Pandora::Elastic.new.counts

      respond_to do |format|
        format.html do
          render :index
        end
        format.json do
          render :json => @sources
        end
      end
    else
      flash[:warning] = 'Sorry, there are currently no databases available for Open Access.'.t
      redirect_back(fallback_location: locale_root_url)
    end
  end

  def ratings
    @source = record(:read) or return

    if @source
      scope = @source.rated_images.includes(:source).references(:source)

      @images = Pandora::SourceCollection.new(
        scope.pageit(page, per_page),
        scope.count,
        page,
        per_page
      )
    else
      return
    end
  end

  def open_access_login
    source = record(:read) or return

    if source.open_access?
      log_in source.dbuser

      redirect_to default_location(:start)
    else
      flash[:warning] = 'Sorry, this database is not available for Open Access.'.t
      redirect_to :controller => 'account', :action => 'login'
    end
  end

  def show
    @source = record(:read) or return
    @source_counts = Pandora::Elastic.new.counts[@source.name]

    respond_to do |format|
      format.html
      format.json do
        render :json => @source.to_json
      end
    end
  end

  api_method :show, :get => {
    :doc => 'Get a source record.',
    :expects => {:id => {:type => 'string', :required => true, :doc => 'The id of the source record.'}},
    :returns => {:json => {}}
  }

  def new
    @source = Source.new(source_params)

    set_mandatory_fields
  end

  def create
    source_params_permitted = prepare_source_params_for_update(source_params)

    @source = Source.new
    @source.name = source_params_permitted.delete(:name)
    @source.title = source_params_permitted.delete(:title)

    if source_params_permitted[:type] == "upload"
      @source.owner = source_params_permitted[:institution]
    end

    source_params_permitted = prepare_source_params_for_update(source_params)
    @source.name = source_params_permitted.delete(:name)
    @source.title = source_params_permitted.delete(:title)
    @source.kind = source_params_permitted.delete(:kind)
    @source.type = source_params_permitted.delete(:type)
    @source.institution = source_params_permitted.delete(:institution)
    @source.keyword_list = source_params_permitted.delete(:keyword_list)
    @source.contact = source_params_permitted.delete(:contact)
    @source.source_admins = source_params_permitted.delete(:source_admins)

    @institution     = @source.institution
    @contact         = @source.contact
    @admins          = @source.source_admins

    if @source.update(source_params_permitted)
      flash[:notice] = "Source '%s' successfully created!" / @source

      redirect_to @source
    else
      set_mandatory_fields
      render 'new'
    end
  end

  def edit
    @source = record(:write) or return

    @institution     = @source.institution
    @contact         = @source.contact
    @admins          = @source.source_admins

    set_mandatory_fields
  end

  def update
    @source = record(:write) or return

    # Source state before update:
    @institution = @source.institution
    @contact = @source.contact
    @admins = @source.source_admins

    source_params_permitted = prepare_source_params_for_update(source_params)

    if @source.update(source_params_permitted)
      flash[:notice] = "Source '%s' successfully updated!" / @source

      redirect_to @source
    else
      unless @source.valid?(:keywords)
        # restore previous errors
        @source.valid?
      end

      set_mandatory_fields

      render 'edit'
    end
  end

  initialize_me!


  private

    def source_params
      params.fetch(:source, {}).permit(
        :name, :title, :email, :url,
        :institution, :kind, :type,
        :keyword_list,
        :contact, {admins: []},
        :open_access,
        :can_exploit_rights,
        :description, :technical_info,
        :description_de, :technical_info_de,
        :quota,
        :auto_approve_records
      )
    end

    def prepare_source_params_for_update(source_params_permitted)
      institution = source_params_permitted.delete(:institution)
      if institution.present?
        source_params_permitted.merge!(institution: Institution.find(institution))
      end

      contact = source_params_permitted.delete(:contact)
      if contact.present?
        source_params_permitted.merge!(contact: Account.find(contact))
      end

      if admins = source_params_permitted.delete(:admins)
        source_params_permitted.merge!(source_admins: Account.where(id: admins))
      end

      source_params_permitted
    end

    def records
      Source.
        allowed(current_user).
        includes(:institution).
        sorted(sort_column, sort_direction).
        search(search_column, search_value)
    end

    def record(rw = :read)
      record = Source.find_by(name: params[:id])

      if record.blank?
        flash[:notice] = "A source with name %s does not exist!" / params[:id]
        redirect_back(fallback_location: locale_root_url)
        return
      end

      access =
        (current_user && current_user.allowed?(record, rw)) ||
        (!current_user && Account.allowed?(record, rw))

      unless access
        forbidden
        return
      end

      record
    end

    def sort_column_default
      'title'
    end
end
