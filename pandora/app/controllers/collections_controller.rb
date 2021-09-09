class CollectionsController < ApplicationController

  # include Util::Resourceful::Controller

  skip_before_action :store_location, :only => [:store, :remove]

  def self.initialize_me!
    control_access [:user] => :ALL

    linkable_actions :create, :index, :shared, :public
  end

  helper_method :owner?

  def self.list_returns
    { 
      :xml => { :root => 'collections', :hints => { 'collection' => true } },
      :json => { :object => '[{&lt;collection fields&gt;},...]' }
    }
  end

  def self.list_expects
    {
      :page => {
        :type    => 'positiveInteger',
        :default => 1,
        :doc     => 'Number of page to return.'
      },
      :order => {
        :select  => CollectionSettings.values_for(:list_order),
        :default => CollectionSettings.default_for(:list_order),
        :doc     => 'Attribute to sort collections by.'
      },
      :direction => {
        :select  => CollectionSettings.values_for(:list_direction),
        :default => CollectionSettings.default_for(:list_direction),
        :doc     => 'Direction to sort collections in.'
      },
      :field => {
        :select => Collection.search_columns.map(&:name),
        :doc    => 'Search field.'
      },
      :value => {
        :doc => 'Query term.'
      }
    }
  end

  def index
    items = records.owned_by(current_user)

    respond_to do |format|
      format.html do
        @collections = Pandora::Collection.new(
          items.pageit(page, per_page),
          items.count,
          page,
          per_page
        )

        # view compatibility
        @count = items.count
        @order = sort_column
        @direction = sort_direction
        @page = page
        @per_page = per_page
      end
      format.xml {render xml: items.pageit(page, per_page)}
      format.json {render json: items.pageit(page, per_page)}
    end
  end

  api_method :index, :get => {
    :doc => 'Get the list of your collections.',
    :expects => list_expects,
    :returns => list_returns
  }

  # def own_all
  #   @collections = records.allowed(current_user, :write)

  #   respond_to do |format|
  #     format.xml {render xml: @collections}
  #     format.json {render json: @collections}
  #   end
  # end

  # api_method :own_all, :get => {
  #   :doc => 'Get the list of all your collections.',
  #   :expects => {},
  #   :returns => list_returns
  # }

  def sharing
    items = records.sharing(current_user)

    @collections = Pandora::Collection.new(
      items.pageit(page, per_page),
      items.count,
      page,
      per_page
    )

    # view compatibility
    @count = items.count
    @order = sort_column
    @direction = sort_direction
    @page = page
    @per_page = per_page
  end

  def shared
    items = records.shared(current_user)

    respond_to do |format|
      format.html do
        @collections = Pandora::Collection.new(
          items.pageit(page, per_page),
          items.count,
          page,
          per_page
        )

        # view compatibility
        @count = items.count
        @order = sort_column
        @direction = sort_direction
        @page = page
        @per_page = per_page
      end
      format.xml {render xml: items.pageit(page, per_page)}
      format.json {render json: items.pageit(page, per_page)}
    end
  end

  api_method :shared, :get => {
    :doc => 'Get the list of collections that have been shared with you.',
    :expects => list_expects,
    :returns => list_returns
  }

  def public
    items = records.public

    respond_to do |format|
      format.html do
        @collections = Pandora::Collection.new(
          items.pageit(page, per_page),
          items.count,
          page,
          per_page
        )

        # view compatibility
        @count = items.count
        @order = sort_column
        @direction = sort_direction
        @page = page
        @per_page = per_page
      end
      format.xml {render xml: items.pageit(page, per_page)}
      format.json {render json: items.pageit(page, per_page)}
    end
  end

  api_method :public, :get => {
    :doc => 'Get the list of public collections.',
    :expects => list_expects,
    :returns => list_returns
  }

  def show
    @collection = Collection.find(params[:id])

    unless current_user.allowed?(@collection, :read)
      permission_denied
      return
    end

    @images = @collection.images_pandora_collection(current_user,
      search_column: search_column,
      search_value: search_value,
      sort_column: sort_column,
      sort_direction: sort_direction,
      page: page,
      per_page: per_page
    )

    # view compatibility
    @count = @collection.images.count
    @order = sort_column
    @collections = Collection.
      allowed(current_user, :write).
      includes(:owner, :viewers, :collaborators)
    @keywords = @collection.keywords
    @links = @collection.links
    @references = @collection.references
    @viewers = @collection.viewers
    @collaborators = @collection.collaborators
    store_neighbours_for(@images)
  end

  def new
    @collection = Collection.new(new_collection_params)
  end

  def create
    # we add the image param to the object as image_list so that these images
    # get added to the new collection
    @collection = Collection.new(new_collection_params)
    @collection.owner = current_user

    if @collection.save
      @collection.notify_sharees

      respond_to do |format|
        format.html do
          l = helpers.link_to(@collection.title, collection_path(@collection))
          case @collection.images.size
          when 0
            flash[:notice] = "Collection '%s' successfully created!".t / l
          when 1
            flash[:notice] = "Image successfully stored in collection '%s'.".t / l
          else
            flash[:notice] = "%d images successfully stored in collection '%s'.".t / [@collection.images.size, l]
          end

          redirect_to params[:back_to] || collection_path(@collection)
        end
        format.xml { render xml: @collection }
        format.json { render json: @collection }
      end
    else
      respond_to do |format|
        format.html { render action: 'new', status: 422 }
        format.xml { render xml: @collection.errors, status: 406 }
        format.json { render json: @collection.errors, status: 406 }
      end
    end
  end

  api_method :create, :post => {
    :doc => "Create a collection.",
    :expects => { :collection => { :type => 'string', :required => true, :doc => 'Nested parameter that must contain collection[title]. Images are included as nested parameter collection[images] with an array of image pids as value.' } },
    :returns => { :xml => { :root => 'collection' }, :json => {} }
  }

  def edit
    @collection = Collection.find(params[:id])

    unless current_user.allowed?(@collection, :write)
      permission_denied
      return
    end
  end

  def update
    @collection = Collection.find(params[:id])

    unless current_user.allowed?(@collection, :write)
      permission_denied
      return
    end

    # this shouldn't happen via GUI
    collection_params = self.collection_params
    if ["read", "write"].include?(collection_params[:public_access]) && @collection.images.any?{|i| i.has_unapproved_upload_record?}
      collection_params.delete(:public_access)
      flash[:warning] = "You can't publish collections containing unapproved uploads. Please wait for their approval by the prometheus office or remove them from your collection.".t
      render action: 'edit', status: 422
      return
    end

    if @collection.update_attributes(collection_params)
      @collection.notify_sharees

      flash[:notice] = "Collection '%s' successfully updated!".t / @collection.title
      redirect_to action: 'show'
    else
      render action: 'edit', status: 422
    end
  end

  def destroy
    @collection = Collection.find(params[:id])

    unless owner?
      permission_denied
      return
    end

    @collection.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = "Collection '%s' successfully deleted!".t / @collection.title
        redirect_to action: 'index'
      end
      format.xml  { render :xml => @collection.to_xml }
      format.json { render :json => @collection.to_json }
    end
  end

  api_method :delete, :post => {
    :doc => "Delete a collection.",
    :expects => { :id => { :type => 'string', :required => true, :doc => 'The id of the collection.' } },
    :returns => { :xml => { :root => 'collection' }, :json => {} }
  }

  def suggest_keywords
    @query = params[:q]
    @keywords = Keyword.
      search(@query).
      pageit(1, 10)

    render layout: false
  end

  # api compatibility
  def number_of_pages
    @collections = case params[:type]
    when 'own' then records.owned_by(current_user)
    when 'shared' then records.shared(current_user)
    when 'public' then records.public
    else
      render plain: "unknown type: #{params[:type].inspect}", status: 404
      return
    end

    @results = Pandora::Collection.new(
      @collections.pageit(page, per_page),
      @collections.count,
      page,
      per_page
    )

    respond_to do |format|
      format.xml {render xml: {number_of_pages: @results.number_of_pages}}
      format.json {render json: {number_of_pages: @results.number_of_pages}}
    end
  end

  api_method :number_of_pages, :get => {
    :doc => "Get number of pages for collections.",
    :expects => { :type  => { :required => true, :doc => 'Collection type, either own, shared or public.' } },
    :returns => { :xml => { :root => 'number_of_pages' }, :json => { :object => "{:number_of_pages}" } }
  }

  def shared_owners_fullname
    owners_fullname(:shared)
  end

  api_method :shared_owners_fullname, :get => {
    :doc => 'Get the list of the owners fullname from collections that have been shared with you.',
    :expects => list_expects,
    :returns => { :xml => { :root => 'fullnames' }, :json => { :object => '[{"fullname":&lt;fullname&gt;, "id":&lt;id&gt;},...]' } }
  }

  def public_owners_fullname
    owners_fullname(:public)
  end

  api_method :public_owners_fullname, :get => {
    :doc => 'Get the list of the owners fullname from public collections.',
    :expects => list_expects,
    :returns => { :xml => { :root => 'fullnames' }, :json => { :object => '[{"fullname":&lt;fullname&gt;, "id":&lt;id&gt;},...]' } }
  }

  def writable
    @collections = records.allowed(current_user, :write).to_a

    respond_to { |format|
      format.xml  { render xml: @collections.to_xml }
      format.json {
        @collections.map!{ |collection|
          type = if collection.owned_by?(current_user)
            "own"
          elsif collection.shared_with?(current_user)
            "shared"
          else
            "public"
          end

          {
            id: collection.id,
            owner_id: collection.owner_id,
            title: collection.title,
            type: type
          }
        }

        render json: @collections.to_json
      }
    }
  end

  api_method :writable, :get => {
    :doc => 'Get the list of current user\'s writable collections.',
    :returns => { :xml => { :root => 'fullnames' }, :json => { :object => '[{"id":&lt;id&gt;, "title":&lt;title&gt;},...]' } }
  }

  def store
    # view compatibility
    params[:id] ||= (params[:target_collection] || {})[:collection_id]
    params[:id] ||= (params[:collection] || {})[:collection_id]

    if params[:image].blank?
      flash[:warning] = 'Please select images to store in this collection!'.t
      redirect_back fallback_location: searches_path
      return
    end

    if params[:id].blank?
      redirect_to(
        action: 'new',
        collection: {image_list: params[:image].join(',')},
        back_to: params[:back_to]
      )
      return
    end

    @collection = records.find(params[:id])

    unless current_user.allowed?(@collection, :write)
      permission_denied
      return
    end

    # api compatibility
    params[:image] = [params[:image]] if params[:image].is_a?(String)

    # to ensure the image exists
    images = params[:image].map{|pid| Pandora::SuperImage.new(pid).image}
    doubles = @collection.images.where(pid: params[:image])
    uniques = images - doubles

    # prevent unapproved uploads in publicly visible collections
    if @collection.public?
      if images.any?{|i| i.upload_record? && !i.upload.approved_record?}
        flash[:warning] = 'Unapproved uploads cannot be added to publicly visible collections'.t
        redirect_back fallback_location: searches_path
        return
      end
    end

    @collection.images += uniques
    if @collection.save
      respond_to do |format|
        format.html do
          if doubles.any?
            link = helpers.link_to(@collection.title, @collection)

            if doubles.size == 1
              push_flash(:notice,
                "Image is already in collection '%s'." / link
              )
            else
              push_flash(:notice,
                "%d images are already in collection '%s'." / [uniques.size, link]
              )
            end
          end

          if uniques.any?
            link = helpers.link_to(@collection.title, @collection)

            if uniques.size == 1
              push_flash(:notice,
                "Image successfully stored in collection '%s'." / link
              )
            else
              push_flash(:notice,
                "%d images successfully stored in collection '%s'." / [uniques.size, link]
              )
            end
          end

          redirect_back fallback_location: searches_path
        end

        store_result = { :collection => { :store => true } }
        format.xml  { render :xml => store_result.to_xml }
        format.json { render :json => store_result.to_json }
      end
    else
      flash[:warning] = "Couldn't add the images to the collection".t
      redirect_back fallback_location: searches_path
    end
  end

  api_method :store, :post => {
    :doc => "Store images in a collection.",
    :expects => {
      :collection => { :type => 'string', :required => true, :doc => 'Nested parameter that must contain collection[collection_id].' },
      :image => { :type => 'array', :required => true, :doc => 'Images are included as an array of image pids.' }
    },
    :returns => { :xml => { :root => 'collection' }, :json => {} }
  }

  def remove
    @collection = Collection.find(params[:id])

    unless current_user.allowed?(@collection, :write)
      permission_denied
      return
    end

    @super_image = Pandora::SuperImage.find(params[:image])
    @collection.images.delete(@super_image.image)

    respond_to do |format|
      store_result = {
        collection: {
          id: @collection.id,
          image: params[:image],
          remove: true
        }
      }

      format.html do
        flash[:notice] = 'Image successfully removed from collection'.t
        redirect_to action: 'show', id: @collection.id
      end
      format.xml  { render xml: store_result.to_xml }
      format.json { render json: store_result.to_json }
    end
  end

  api_method :remove, :post => {
    :doc => "Remove an image from a collection.",
    :expects => {
      :id => { :type => 'string', :required => true, :doc => 'The id of the collection.' },
      :image => { :type => 'array', :required => true, :doc => 'The pid of the image.' }
    },
    :returns => { :xml => { :root => 'collection' }, :json => {} }
  }

  def download
    @collection = records.find(params[:id])

    unless current_user.allowed?(@collection, :read)
      permission_denied
      return
    end

    @zip = Pandora::Zip.new

    @zip[@collection.filename('-collection.txt')] = @collection.to_txt(
      link: url_for(action: 'edit', id: @collection.id)
    )

    @collection.images.each do |image|
      next unless current_user.allowed?(image, :read)

      si = Pandora::SuperImage.from(image)

      if image_data = si.image_data(:large)
        # fullsize image
        @zip[si.image.filename('image/jpeg')] = image_data
      else
        # or link
        @zip[si.image.filename('image/jpeg')] = image_data
        @zip[si.image.filename('-link.txt')] = url_for(
          controller: 'images',
          action: 'large',
          id: image.id,
          format: 'html'
        )
      end

      # metadata
      @zip[image.filename('txt')] = si.to_txt(
        link: url_for(
          controller: 'images', action: 'show', id: image.id, format: 'html'
        )
      )
    end

    send_data(@zip.generate,
      filename: @collection.filename('zip'),
      content_type: 'application/zip',
      disposition: 'attachment'
    )
  end

  # api compatibility (same image listing capabilies as #show)
  def images
    @collection = Collection.allowed(current_user, :read).find(params[:id])

    @images = @collection.images_pandora_collection(current_user,
      search_column: search_column,
      search_value: search_value,
      sort_column: sort_column,
      sort_direction: sort_direction,
      page: page,
      per_page: per_page
    )

    respond_to do |format|
      format.xml  do
        render xml: {"collection" => @collection, "images" => @images.items.to_a}.to_xml
      end
      format.json do
        data = @collection.attributes.merge(
          "number_of_pages" => @images.number_of_pages,
          "images" => @images.items.map{ |result|
            # TODO Since the field transformation is done at multiple places, find a common place in the future.
            result.image.attributes.merge(
              "artist" => result.artist.is_a?(Array) ? result.artist.join(" | ") : result.artist,
              "title" => result.title.is_a?(Array) ? result.title.join(" | ") : result.title,
              "location" => result.location.is_a?(Array) ? result.location.join(" | ") : result.location,
              "date" => result.date,
              "credits" => result.credits.is_a?(Array) ? result.credits.join(" | ") : result.credits
            )
          }
        )

        render json: data
      end
    end
  end

  api_method :images, :get => {
    :doc => "Get the list of a collection's images.",
    :expects => {
      :id  => {
        :required => true, :doc => 'Collection ID.'
      },
      :per_page => {
        :type    => 'positiveInteger',
        :default => CollectionSettings.default_for(:per_page),
        :doc     => 'Number images per page to return.'
      },
      :page => {
        :type    => 'positiveInteger',
        :default => 1,
        :doc     => 'Number of page to return.'
      },
      :order => {
        :select  => [:insertion_order, :artist, :title, :location, :credits],
        :default => :insertion_order,
        :doc     => 'Attribute to sort collections by.'
      },
      :direction => {
        :select  => CollectionSettings.values_for(:list_direction),
        :default => CollectionSettings.default_for(:list_direction),
        :doc     => 'Direction to sort collections in.'
      }
    },
    returns: {
      xml: {root: 'images', hints: { 'image' => true } },
      json: {object: "{:id, :title, :notes, :forked_at, :owner_id, :thumbnail_id, :public_access, :created_at, :updated_at, :references, :description, :links, images: [{:pid, :artist, :title, :location, :date, :credits, :source_id, :collection_id, :votes, :image_id, :score, :checked_at}]}"}
    }
  }

  protected

    def records
      Collection.
        search(search_column, search_value).
        sorted(sort_column, sort_direction)
    end

    def collection_params
      fields = [:description, :links, :references, :keyword_list]

      if owner?
        fields += [
          :title, :thumbnail_id, :public_access, :viewer_list,
          :collaborator_list
        ]
      end

      params.fetch(:collection, {}).permit(*fields)
    end

    def new_collection_params
      fields = [
        :title, :description, :links, :references, :keyword_list, :image_list,
        :public_access, :viewer_list, :collaborator_list
      ]

      params.fetch(:collection, {}).permit(*fields)
    end

    def owner?
      return false unless @collection
      return true if @collection.new_record?

      @collection.owned_by?(current_user)
    end

    def owners_fullname(public_view = :shared)
      @collections = case public_view
      when :shared
        records.shared(current_user).pageit(page, per_page)
      when :public
        records.public.pageit(page, per_page)
      end

      ids = @collections.pluck(:owner_id)
      owners = Account.where(id: ids).order(:lastname, :firstname)

      @results = owners.map do |owner|
        {
          'id' => owner.id,
          'fullname' => owner.fullname
        }
      end

      respond_to do |format|
        format.xml  { render xml: @results }
        format.json { render json: @results }
      end
    end

    # def options_for_list_search(klass, field = @field, value = @value, order = @order, direction = @direction)
    #   order = 'accounts.lastname' if order == 'owner'
    #   super
    # end

    def sort_column_default
      # we need to distinguish between listing images within a collection and
      # listing collections
      if ['show', 'images'].include?(action_name)
        # so we are listing images within the collection
        collection_settings[:order] || 'title'
      else
        # so we are listing collections
        collection_settings[:list_order] || 'title'
      end
    end

    def sort_direction_default
      # we need to distinguish between listing images within a collection and
      # listing collections
      if ['show', 'images'].include?(action_name)
        if (sort_column == 'insertion_order')
          'desc'
        else
          metric = ['rating_average', 'rating_count', 'comment_count'].include?(sort_column)
          collection_settings[:direction] || (metric ? 'desc' : 'asc')
        end
      else
        metric = ['updated_at'].include?(sort_column)
        collection_settings[:list_direction] || (metric ? 'desc' : 'asc')
      end
    end

    def per_page_default
      if ['show', 'images'].include?(action_name)
        collection_settings[:per_page] || super
      else
        collection_settings[:list_per_page] || super
      end
    end

    def view_default
      collection_settings[:view] || super
    end

    def zoom_default
      !collection_settings[:zoom].nil? ? collection_settings[:zoom] : true
    end

    def collection_settings
      current_user.try(:collection_settings) || {}
    end


  initialize_me!

end
