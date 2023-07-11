class InstitutionalUploadsController < ApplicationController

  include Util::Config
  include ActionView::Helpers::NumberHelper

  before_action :current_user_writables, :only => [:index, :create]
  before_action :check_quota, only: ['new', 'create']

  #############################################################################
  # Class methods
  #############################################################################

  def self.initialize_me!  # :nodoc:
    control_access [:superadmin, :admin, :dbadmin] => [:institutional_databases, :index, :new, :create]
  end

  #############################################################################

  def new
    unless current_user && current_user.institutional_user_dbadmin?
      forbidden
      return
    end

    @institutional_upload_database = current_user.admin_sources.where(type: "upload").find(params[:id])

    @upload = Upload.new(upload_params)
    @upload.add_to_index = true if @upload.add_to_index.nil?

    @page_title = "Select a file and add the mandatory metadata".t
    set_mandatory_fields
  end

  def create
    unless current_user && current_user.institutional_user_dbadmin?
      forbidden
      return
    end

    @institutional_upload_database = current_user.admin_sources.where(type: "upload").find(params[:id])

    @upload = Upload.new(upload_params)
    @upload.database = @institutional_upload_database
    @upload.approved_record = @institutional_upload_database.auto_approve_records?

    upload_latest = @institutional_upload_database.uploads.order('updated_at DESC').first

    if @upload.save
      @upload.index_doc

      flash[:notice] = [
        'File successfully uploaded!'.t,
        translate_with_link(
          'Add further metadata now or %{upload another file}%.',
          new_institutional_upload_path(@institutional_upload_database.id)
        )
      ]

      # flash_with_link(:notice,
      #   "#{'File successfully uploaded!'.t} #{'Add further metadata now or %_.'.t}",
      #   'upload another file'.t,
      #   new_institutional_upload_path(@institutional_upload_database.id)
      # )

      redirect_to :controller => 'uploads', :action => 'edit', :id => @upload, :upload_latest => upload_latest
    else
      set_mandatory_fields
      
      render action: 'new', status: 422
    end

    @page_title = "Select a file and add the mandatory metadata".t
    set_mandatory_fields
  end

  def index
    if current_user && (current_user.institutional_user_dbadmin? || current_user.admin_or_superadmin?)
      if current_user.admin_or_superadmin?
        @institutional_upload_databases = Source.where(type: 'upload').where.not(kind: 'User database').order(:title)
      else
        @institutional_upload_databases = current_user.admin_sources.where(type: 'upload').order(:title)
      end

      if params[:id]
        @institutional_upload_database = @institutional_upload_databases.find(params[:id])
      elsif !@institutional_upload_databases.empty?
        @institutional_upload_database = @institutional_upload_databases.order(:created_at).first
      end

      scope = records.where(database: @institutional_upload_database)

      @uploads = Pandora::Collection.new(
        scope.pageit(page, per_page),
        scope.count,
        page,
        per_page
      )

      if @institutional_upload_database
        @page_title = set_list_title(@institutional_upload_database)
      else
        @page_title = 'No institutional database available'
      end

      store_neighbours_for(@uploads.items)
    else
      forbidden
      return
    end
  end

  ##########

  private

  def set_list_title(database)
    quota = number_to_human_size(database.quota.megabytes, precision: 2)
    space_used = number_to_human_size(space_used_in_bytes(database), precision: 2)
    space_used_percentage = number_to_percentage(space_used_in_bytes(database)/database.quota.megabytes*100, :precision => 2)
    'Using %s of %s (about %s)'.t % [space_used, quota, space_used_percentage]
  end

  # overwrites generic ApplicationController#set_mandatory_fields
  def set_mandatory_fields
    mandatory = Set.new(Upload::REQUIRED)
    @mandatory = HashWithIndifferentAccess.new { |h, k| h[k] = mandatory.include?(k.to_s) }
  end

  def check_quota
    if (database = Source.find(params[:id]))
      if space_used_in_bytes(database) > database.quota.megabytes
        flash[:notice] = 
          "You've reached your quota limit of ".t + 
          number_to_human_size(database.quota.megabytes, precision: 2) + ". " +
          "Please delete some of your images!".t
        redirect_to :action => 'index'
      end
    else
      flash[:warning] =  "You have to specify an institutional uploads database"
      redirect_to :action => 'index'
    end
  end

  def space_used_in_bytes(database)
    database.uploads.sum(:file_size) or 0
  end

  def current_user_writables
    @collections = Collection.
      allowed(current_user, :write).
      includes(:owner, :viewers, :collaborators)
  end

  def records(rw = :read)
    Upload.
      allowed(current_user, rw).
      includes(image: [:collections, :source, :voters, :locations]).
      preload(:database).
      sorted(sort_column, sort_direction).
      search(search_column, search_value)
  end

  def sort_column_default
    upload_settings[:order] || 'title'
  end

  def sort_direction_default
    upload_settings[:direction] || 'asc'
  end

  def per_page_default
    upload_settings[:per_page] || super
  end

  def zoom_default
    !upload_settings[:zoom].nil? ? upload_settings[:zoom] : true
  end

  def upload_settings
    current_user.try(:upload_settings) || {}
  end

  def upload_params
    if current_user.admin_or_superadmin?
      params.fetch(:upload, {}).permit!
    else
      params.fetch(:upload, {}).permit(
        :title, :file, :rights_reproduction, :credits, :license, :rights_work,
        :latitude, :longitude, :discoveryplace, :date, :artist, :genre,
        :keyword_list, :location, :addition, :annotation, :iconography,
        :institution, :inventory_no, :origin, :other_persons, :photographer,
        :size, :subtitle, :text, :parent_id, :material, :description,
        :add_to_index
      )
    end
  end

  ############################################################################
  initialize_me!
  ############################################################################

end
