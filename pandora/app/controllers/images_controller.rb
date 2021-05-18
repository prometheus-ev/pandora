class ImagesController < ApplicationController

  skip_before_action :store_location, :only => [:vote, :small, :medium, :large, :download]

  # this allows actions for open access sources; it does not check restrictions on non open access sources once dbuser is logged in
  # for full functionality this method must be supplemented by a source check for dbusers before calling allowed actions
  allow_open_access [:show, :small, :medium, :large, :download], [:list] do
    i = params[:id] and i.is_a?(String) and i = Image.find_by_pid(i) and i.source
  end

  # action list same as allowed actions for dbuser (DEFAULT), cf. self.initialize_me!
  before_action :check_db_user_source, :only => [:list, :show, :small, :medium, :large, :download, :publish]

  # REWRITE: it seems that nothing is being written in that action although it
  # is requested via ajax POST
  protect_from_forgery except: ['show']

  def self.initialize_me!  # :nodoc:
    control_access :superadmin => :ALL,
                   :user       => [:vote, :comment, :display_fields],
                   :DEFAULT    => [:list, :show, :publish, :small, :medium, :large, :custom, :download]
  end

  def list
    if params[:source].blank?
      render_api_422 'source has to be specified'
      return
    end

    source = Source.find_by(name: params[:source])
    unless source
      render_api_404 'source not found'
      return
    end

    if (!current_user || current_user.dbuser?) && !source.open_access?
      render_api_403 'permission denied to read non-open access source'
      return
    end

    ids = Pandora::Elastic.new.image_ids(source.name, page: page, per_page: per_page)
    render_api 200, ids
  end

  api_method :list, :get => {
    :doc => 'Get the list of all images by source.',
    :expects => {
      :source => {
        :required => true,
        :type => 'boolean',
        :doc => 'The source name, e.g "daumier" or "robertin"'
      },
      :page => {
        :type    => 'positiveInteger',
        :default => 1,
        :doc     => 'Page to return.'
      },
      :per_page => {
        :type    => 'positiveInteger',
        :default => 10,
        :doc     => 'Number of results to return per page.'
      },
    },
    :returns => { :xml => { :root => 'images', :hints => { 'pid' => true } }, :json => {} }
  }

  def show
    @super_image = Pandora::SuperImage.find(params[:id])

    @collections = Collection.
      allowed(current_user, :write).
      includes(:owner, :viewers, :collaborators)


    if params[:box_id]
      render plain: render_to_string(
        partial: 'box',
        object: @super_image.image
      )
      return
    end

    @prev = get_left_neighbour(params[:id])
    @top = get_neighbourhood
    @next = get_right_neighbour(params[:id])

    if @super_image.upload?
      # checks if current user has acess rights on upload
      unless current_user.allowed?(@super_image.image, :read)
        permission_denied
        return
      end

      @display_fields = @super_image.display_fields - ['source_url', 'keyword_artigo']

      @location_fields = @super_image.location_fields
      @latest_location   = @super_image.image.locations.order('updated_at DESC') if 
        @super_image.image.locations # Only uploads!
      if !@super_image.upload.latitude.blank? && !@super_image.upload.longitude.blank?
        @lat = @super_image.upload.latitude
        @lng = @super_image.upload.longitude
        @zoom_level = 11
      end
    else # elastic record
      # Request athene-search with ActiveResource custom REST method
      # http://apidock.com/rails/v2.3.8/ActiveResource/CustomMethods
      return unless @super_image.image
      @display_fields = @super_image.display_fields - ['source_url']
    end

    image_source_attributes = {"fulltitle" => ""}
    if @super_image.source
      image_source_attributes.merge!(@super_image.source.attributes)
      if @super_image.source.fulltitle
        image_source_attributes.merge!({"fulltitle" => @super_image.source.fulltitle})
      end
    end

    prepare_rating @super_image.image

    # binding.pry
    # update_section(@super_image.image) {} and return

    respond_to do |format|
      format.html
      format.xml {
        if @super_image.upload?
          # REWRITE: use the old implementation for now
          render :xml => @super_image.image.legacy_to_xml(
            # REWRITE: we need to specify the format and locale explicitly
            # :link => url_for(safe_params(:format => nil, locale: nil, :only_path => false))
            :link => url_for(safe_params(:format => 'html', locale: I18n.locale, 
              :only_path => false))
          )
        else
          # REWRITE: use the framework imeplementation
          # render xml: @image.to_xml(link: url_for(safe_params(format: nil, only_path: false)))
          m = [:pid, :score, :votes, :print]
          render xml: @super_image.image.to_xml(methods: m){|xml|
            xml.link url_for(safe_params(format: nil, only_path: false))
            xml.status_as_of @super_image.updated_at
            xml.descriptive_title @super_image.image.descriptive_title
            xml.source @super_image.image.source.fulltitle
          }
        end
      }
      format.json {
          image_attributes = {}
          image_attributes.merge!({"source" => image_source_attributes})
          image_attributes.merge!({"pid" => @super_image.pid})
          image_attributes.merge!(@super_image.image.display_fields_hash)
          image_attributes.merge!({"rating" => @super_image.image.rating})

          render json: image_attributes.to_json
      }
    end
  end

  api_method :show, :get => {
    :doc => "Get an image's metadata.",
    :expects => { :id  => { :required => true, :doc => 'Image ID.' } },
    :returns => { :xml => { :root => 'image', :hints => %w[pid artist title] }, :json => { :object => '{:source_id, :score, :checked_at, :votes, :pid, &lt;all display fields&gt;}' } }
  }

  def display_fields
    display_fields_translated = Image.display_fields_translated

    respond_to { |format|
      format.xml  { render :xml  => display_fields_translated.to_xml  }
      format.json { render :json => display_fields_translated.to_json }
    }
  end

  api_method :display_fields, :get => {
    :doc => "Get image display fields and German translation.",
    :returns => { :xml => { :root => 'display_fields' }, :json => {} }
  }

  def publish
    @super_image = Pandora::SuperImage.find(params[:id])
    @image = @super_image.image
    return unless @image

    # @rights_exploiter = @image.rights_exploiter
    @institution = @super_image.source.institution

    set_mandatory_fields(required = %w[
      publication firstname lastname email
      addressline postalcode city country
    ])

    if request.post?
      data = publishing_request_params
      # institution = @rights_exploiter.institution

      if @institution.name == 'erlangen_uni'
        unless %w[extern intern].include?(@status = params[:status])
          @status = false
          flash.now[:warning] = "Please select the status of affiliation to the institution: #{@institution}".t
          return
        end
      end

      if %w[scientific commercial].include?(@type = params[:type])
        if @type == 'scientific' && @institution.name != 'erlangen_uni'
          unless %w[print online].include?(@mode = params[:mode])
            @mode = false
            flash.now[:warning] = 'Please select the publication mode'.t
            return
          end
        end

        unless data.values_at(*required).any?(&:blank?)
          image_info = "#{@image.path} (#{@image.artist}: #{@image.title})"

          AccountMailer.publication_inquiry(
            @type, @status, @mode, data, image_info, @institution, @super_image.source.email
          ).deliver_now
          AccountMailer.publication_response(
            @type, @status, @mode, data, image_info, @institution, data[:email],
            current_user.anonymous? ? 'user'.t : current_user.fullname
          ).deliver_now

          flash.now[:notice] = @type == 'scientific' ?
            'Your inquiry has been delivered. For further information read the e-mail you will receive shortly!'.t :
            'Your inquiry has been delivered. The rights exploiter will contact you shortly!'.t
        else
          flash.now[:warning] = 'Please fill in all required form fields.'.t
        end
      else
        @type = false
        flash.now[:warning] = 'Please select the type of your publication'.t
      end
    end

    @data = OpenStruct.new(data)
  end

  def vote
    @super_image = Pandora::SuperImage.find(params[:id])
    return unless current_user.allowed?(@super_image.image, :read)

    @image = @super_image.image

    unless voted = @image.voters.include?(current_user)
      rating = params[:rating].to_i
      rating = [rating, MIN_RATING].max
      rating = [rating, MAX_RATING].min

      @image.vote(rating, current_user)

      saved = @image.save
    end

    if request.xhr?
      prepare_rating @image
      render :partial => 'ratings/show', layout: false, locals: {
        super_image: Pandora::SuperImage.from(@image)
      }
    else
      flash[:warning] = 'You have already rated this image!'.t if voted
      flash[:notice]  = ("Successfully rated image '%s' with %d star!" / rating) % @image if saved

      redirect_to :action => 'show', :id => @image
    end
  end

  def small
    # this will redirect to an url with a numeric resize directive (r140x140)
    redirect_to_image(:small)
  end

  api_method :small, :get => {
    :doc => "Get an image's binary representation in small size.",
    :expects => { :id   => { :required => true, :doc => 'Image ID.' } },
    :returns => { :blob => { :type => 'image' } }
  }

  def medium
    # this will redirect to an url with a numeric resize directive (r400x400)
    redirect_to_image(:medium)
  end

  api_method :medium, :get => {
    :doc => "Get an image's binary representation in medium size.",
    :expects => { :id   => { :required => true, :doc => 'Image ID.' } },
    :returns => { :blob => { :type => 'image' } }
  }

  def large
    si = Pandora::SuperImage.find(params[:id])
    
    send_data si.image_data(:large), disposition: 'inline', content_type: 'image/jpeg'
  end

  api_method :large, :get => {
    :doc => "Get an image's binary representation in large size.",
    :expects => { :id   => { :required => true, :doc => 'Image ID.' } },
    :returns => { :blob => { :type => 'image' } }
  }

  def custom
    @super_image = Pandora::SuperImage.find(params[:id])
    resolution = "r#{params[:resolution]}#{params[:mode]}"

    respond_to do |format|
      format.blob do
        redirect_to @super_image.image_url(resolution)
      end
    end
  end

  def download
    @super_image = Pandora::SuperImage.find(params[:id])

    zip = Pandora::Zip.new

    image_data = @super_image.image_data(:large)

    if image_data.nil?
      # image unretrievable
      flash[:error] = 'Image could not be retrieved'.t
      redirect_to action: 'show', id: params[:id]
    else
      zip[@super_image.filename('jpg')] = image_data
      zip[@super_image.filename('txt')] = @super_image.to_txt(
        link: url_for(action: 'show', id: @super_image.pid, format: 'html')
      )

      send_data zip.generate, {
        filename: @super_image.filename('zip'),
        content_disposition: 'download',
        content_type: 'application/zip'
      }
    end
  end


  private

    def publishing_request_params
      params.fetch(:data, {}).permit(
        :publication, :firstname, :lastname, :email, :addressline, :postalcode,
        :city, :country, :annotations
      )
    end

    def prepare_rating image
      @rating   = image.rating
      @rateable = current_user.action_allowed?(:images, :vote)
      @rated    = current_user.rated_images.exists?(image.id)

      @vote_url = { :action => 'vote', :id => image }
    end

    def redirect_to_image(size)
      @super_image = Pandora::SuperImage.find(params[:id])
      return unless current_user.allowed?(@super_image.image, :read)

      @image = @super_image.image

      redirect_to Image.url_for(@image, size)
    end

    def check_db_user_source
      if current_user && current_user.dbuser?
        if (source = Source.find_by(name: params[:source]))
          if source.dbuser != current_user
            permission_denied
          end
        # elsif (image = Image.find(params[:id]))
        elsif (image = Pandora::SuperImage.find(params[:id]))
          if image.source.dbuser != current_user
            permission_denied
          end
        end
      end
      # permission_denied unless permit?(self.class.access_control(action_name))
    end


  initialize_me!

end
