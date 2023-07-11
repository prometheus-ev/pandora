class UploadsController < ApplicationController

  include Util::Config
  include ActionView::Helpers::NumberHelper

  VARIOUS_VALUES = '<various values>'

  before_action :current_user_writables, :only => [:index, :all, :unapproved, :approved, :associated, :list_index_remove_requests, :create, :edit]
  before_action :check_quota, only: ['new', 'create']

  #############################################################################
  # Class methods
  #############################################################################

  def self.initialize_me!  # :nodoc:
    control_access [:superadmin, :admin] => action_symbols - [:feed],
                   [:user] => [:index, :associated, :new, :create, :update, :show, :edit, :edit_selected, :update_selected, :destroy, :disconnect, :record, :record_image_url]

    linkable_actions :all, :unapproved, :approved, :new
  end

  def self.api_method_index_get
    {
      :doc => 'Get the list of your database records.',
      :expects => {
        :page => {
          :type    => 'positiveInteger',
          :default => 1,
          :doc     => 'Number of page to return.'
        },
        :per_page => {
          :type    => 'positiveInteger',
          :default => UploadSettings.default_for(:per_page),
          :doc     => 'Number of results to display per page.'
        },
        :order => {
          :select  => UploadSettings.values_for(:order),
          :default => UploadSettings.default_for(:order),
          :doc     => 'Attribute to sort database records by.'
        },
        :direction => {
          :select  => UploadSettings.values_for(:direction),
          :default => 'ASC',
          :doc     => 'Direction to sort database records in.'
        },
        :field => {
          :select => Upload.search_columns,
          :doc    => 'Search field.'
        },
        :value => {
          :doc => 'Query term.'
        }
      },
      :returns => { :xml => { :root => 'uploads', :hints => { 'upload' => true } }, :json => {} }
    }
  end

  api_method :index, get: api_method_index_get
  api_method :list, :get => api_method_index_get

  def index
    scope = records.where(database: current_user.database)

    # view compatibility
    @uploads = Pandora::Collection.new(
      scope.pageit(page, per_page),
      scope.count,
      page,
      per_page
    )
    set_list_title

    respond_to do |format|
      format.html do
        store_neighbours_for(@uploads.items)
      end

      # api compatibility
      format.xml  {render :xml => @uploads.items}
      format.json do
        render :json => {
          number_of_pages: @uploads.number_of_pages,
          uploads: @uploads.items
        }
      end
    end
  end

  def all
    scope = records

    # view compatibility
    @uploads = Pandora::Collection.new(
      scope.pageit(page, per_page),
      scope.count,
      page,
      per_page
    )

    space_used_total = number_to_human_size(space_used_in_bytes_total, precision: 2)
    @page_title = 'Using %s in total' / space_used_total

    store_neighbours_for(@uploads.items)

    render action: 'index'
  end

  def unapproved
    scope = records.unapproved

    # view compatibility
    @uploads = Pandora::Collection.new(
      scope.pageit(page, per_page),
      scope.count,
      page,
      per_page
    )

    store_neighbours_for(@uploads.items)

    render action: 'index'
  end

  def approved
    scope = records.approved

    # view compatibility
    @uploads = Pandora::Collection.new(
      scope.pageit(page, per_page),
      scope.count,
      page,
      per_page
    )

    store_neighbours_for(@uploads.items)

    render action: 'index'
  end

  def associated
    @upload = Upload.
      allowed(current_user).
      includes(:parent, :children).
      find(params[:id])

    ids = [@upload.parent_id] + @upload.children.pluck(:id)
    ids << @upload.parent.children.pluck(:id) if @upload.parent
    ids = ids.flatten.uniq

    all = records.where(id: ids)

    # view compatibility
    @uploads = Pandora::Collection.new(
      all.pageit(page, per_page),
      all.count,
      page,
      per_page
    )
    set_list_title

    store_neighbours_for(@uploads.items)

    render action: 'index'
  end

  def show
    @upload = records(:read).find(params[:id])

    respond_to do |format|
      format.html
      format.json
      format.xml do
        render xml: @upload.to_xml(only: @upload.attributes.keys)
      end
    end
  end

  def new
    @upload = Upload.new(upload_params)
    @upload.add_to_index = true if @upload.add_to_index.nil?

    # view compatibility
    @page_title = "Select a file and add the mandatory metadata".t
    set_mandatory_fields
  end

  def create
    @upload = Upload.new(upload_params)
    @upload.database = current_user.database

    upload_latest = current_user.database.uploads.order('updated_at DESC').first

    if @upload.save
      @upload.index_doc

      flash[:notice] = [
        'File successfully uploaded!'.t,
        translate_with_link(
          'Add further metadata now or %{upload another file}%.',
          action: 'new'
        )
      ].join(' ').html_safe

      respond_to { |format|
        format.html { redirect_to :action => 'edit', :id => @upload, :upload_latest => upload_latest }

        # api compatibility
        format.xml  { render :xml => @upload.to_xml(:only => @upload.attributes.keys) }
        format.json { render :json => @upload }
      }
    else
      set_mandatory_fields

      render action: 'new', status: 422
    end

    # view compatibility
    @page_title = "Select a file and add the mandatory metadata".t
  end

  api_method :create, :post => {
    :doc => "Create a record for your database.",
    :expects => { :upload => { :type => 'string', :required => true, :doc => 'Nested parameter that must contain upload[file], upload[title], upload[rights_reproduction] or upload[credits] and upload[rights_work].' } },
    :returns => { :xml => { :root => 'upload' }, :json => {} }
  }

  def edit
    @upload = records(:write).includes(:parent, :children).find(params[:id])

    @prev, @next, @top = neighbours_of(@upload.image)

    if id = params[:upload_latest]
      @upload_latest = records(:read).find(id)
    end

    # view compatibility
    @page_title = 'Edit object: %s' / ERB::Util.h(@upload.title)
    set_mandatory_fields

    render :action => 'edit'
  end

  def update
    @upload = records(:write).find(params[:id])

    @upload.assign_attributes upload_params

    if @upload.approved_record_changed? && @upload.approved_record == false
      # remove re-unapproved upload thumbnail
      @upload.image.collections.each do |c|
        if c.thumbnail == @upload.image
          c.thumbnail = nil
          c.save
        end
      end
      # remove re-unapproved upload from public collections
      @upload.image.collections = @upload.image.collections.select{|c| !c.public_access}
    end

    if @upload.update(upload_params)
      @upload.index_doc

      respond_to { |format|
        format.html do
          flash[:notice] = "Object successfully updated!".t
          redirect_to action: 'edit'
        end

        # api compatibility
        format.xml  { render :xml => @upload.to_xml(:only => @upload.attributes.keys) }
        format.json { render :json => @upload }
      }
    else
      respond_to do |format|
        format.html do
          set_mandatory_fields

          render :action => 'edit', status: 422
        end

        # api compatibility
        format.xml  { render :xml => @upload.errors, status: 422 }
        format.json { render :json => @upload.errors, status: 422 }
      end
    end
  end

  api_method :show, :get => {
    :doc => "Read a record of your database.",
    :expects => { :id => { :type => 'string', :required => true, :doc => 'The id of the record of your database.' } },
    :returns => { :xml => { :root => 'upload' }, :json => {} }
  }

  api_method :edit, :put => {
    :doc => "Update a record of your database.",
    :expects => { :id => { :type => 'string', :required => true, :doc => 'The id of the record of your database.' }, :upload  => { :type => 'string', :required => true, :doc => 'Nested parameter where upload[title], upload[rights_reproduction] or upload[credits] and upload[rights_work] can not be empty.' } },
    :returns => { :xml => { :root => 'upload' }, :json => {} }
  }

  def edit_selected
    if params[:uploads].blank?
      flash[:notice] = 'Select some objects first!'.t
      redirect_back(fallback_location: uploads_path)
      return
    end

    @upload = Upload.new
    @uploads = records(:write).includes(:keywords).find(params[:uploads])
    columns = Upload.new.attributes.keys - ['approved_record']
    columns.each do |a|
      values = @uploads.map{|u| u.send(a.to_sym)}.reject{|v| v.blank?}.uniq

      if values.size == 1
        @upload.send("#{a}=", values.first)
      elsif values.size > 1
        @upload.send("#{a}=", VARIOUS_VALUES)
      end
    end

    # view compatibility
    @page_title = 'Multi-Edit'.t + ': ' + @uploads.size.to_s + ' ' + (@uploads.size > 1 ? 'images'.t : 'image'.t)
    @page_info = 'Be careful, you are changing the metadata of multiple objects!'.t + ' ' + '<various values>'.t + ' ' + 'denotes that various values exist for the field in the various objects. A single value hints that all objects have the same value.'.t
  end

  def update_selected
    @uploads = records(:write).find(params[:uploads])

    attribs = upload_params
    attribs.delete_if{ |_, value| value == VARIOUS_VALUES }

    success = @uploads.all? do |u|
      if u.update(attribs)
        u.index_doc
        true
      else
        false
      end
    end

    if success
      flash[:notice] = "Objects successfully updated!".t
      redirect_to :action => :edit_selected, :uploads => params[:uploads]
    else
      flash[:notice] = 'Could not update all selected objects, please verify your changes.'.t
      redirect_to :action => :edit_selected, :uploads => params[:uploads]
    end
  end

  def disconnect
    @upload = records(:write).find(params[:id])

    @upload.parent = nil
    @upload.save

    flash[:notice] = "Parent successfully disconnected!".t
    redirect_to :action => "edit"
  end

  def destroy
    @upload = records(:write).find(params[:id])

    @upload.remove_index_doc

    @upload.image.destroy
    @upload.destroy

    @upload.children.update_all("parent_id = NULL")

    if File.exist?(@upload.path)
      File.delete(@upload.path)
    end

    respond_to { |format|
      format.html do
        flash[:notice] = "Upload successfully deleted!".t

        redirect_to uploads_path
      end

      # api compatibility
      format.xml  { render :xml => @upload.to_xml }
      format.json { render :json => @upload }
    }
  end

  api_method :destroy, :delete => {
    :doc => "Delete a record of your database.",
    :expects => { :id => { :type => 'string', :required => true, :doc => 'The id of the record of your database.' } },
    :returns => { :xml => { :root => 'upload' }, :json => {} }
  }

  def record_image_url
    @upload = records.find(params[:id])
    si = Pandora::SuperImage.new(@upload.pid, upload: @upload)

    render plain: si.image_url(:small)
  end

  # api only
  def record
    upload_record = records(:read).find(params[:id])

    upload_record_hash = upload_record.attributes.except("id", "parent_id", "image_id", "approved_record", "public_record", "destroy_record", "index_record", "indexed_record", "filename_extension", "file_size", "created_at", "updated_at")
    upload_record_hash["keyword_list"] = upload_record.keywords.map{|keyword| keyword.title}.join(TEXTAREA_SEPARATOR)

    if Upload.pconfig[:licenses].keys.include?(upload_record.license) || upload_record.license.blank?
      upload_record_hash["license_text_field"] = ""
    else
      upload_record_hash["license"] = "Other"
      upload_record_hash["license_text_field"] = upload_record.license
    end

    render :json => upload_record_hash
  end


  private

    def check_quota
      if space_used_in_bytes > current_user.database_quota_bytes
        link = helpers.link_to('Please contact the prometheus office to extend your quota'.t, home_url('contact'))
        flash[:notice] = helpers.sanitize(
          "You've reached your quota limit of ".t +
          number_to_human_size(current_user.database_quota_bytes, precision: 2) + ". " +
          link + ".")
        redirect_to :action => 'index'
      end
    end

    def current_user_writables
      @collections = Collection.
        allowed(current_user, :write).
        includes(:owner, :viewers, :collaborators)
    end

    def space_used_in_bytes
      current_user.database.uploads.sum(:file_size) or 0
    end

    def space_used_in_bytes_total
      Upload.sum(:file_size) or 0
    end

    def set_list_title
      if action_name == 'index'
        quota = number_to_human_size(current_user.database_quota_bytes, precision: 2)
        space_used = number_to_human_size(space_used_in_bytes, precision: 2)
        space_used_percentage = number_to_percentage(space_used_in_bytes/current_user.database_quota_bytes*100, :precision => 2)
        @page_title = 'Using %s of %s (about %s)'.t % [space_used, quota, space_used_percentage]
      elsif action_name == 'all'
        space_used_total = number_to_human_size(space_used_in_bytes_total, precision: 2)
        @page_title = 'Using %s in total' / space_used_total
      end
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

    ############################################################################
    initialize_me!
    ############################################################################

end
