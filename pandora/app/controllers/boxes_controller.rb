class BoxesController < ApplicationController
  skip_before_action :login_required, only: [:index]
  # skip_before_action :store_location

  skip_before_action :verify_account_email, only: [:index]
  skip_before_action :verify_account_active, only: [:index]
  skip_before_action :verify_account_not_deactivated, only: [:index]
  skip_before_action :verify_account_signup_complete, only: [:index]
  skip_before_action :verify_account_terms_accepted, only: [:index]

  def self.initialize_me!  # :nodoc:
    control_access(
      [:superadmin, :user] => :ALL,
      DEFAULT: :index
    )
  end

  def index
    @boxes = records.
      includes(:image, :collection).
      to_a.select{|b| b.ref.present?}

    respond_to do |format|
      format.html { render layout: false }
      format.xml  { render xml: @boxes.to_xml }
      format.json { render json: "[#{@boxes.map { |box| box.to_json }.join(',')}]" }
    end
  end

  api_method :list, get: {
    doc: "List a user's favorites.",
    returns: { xml: { root: 'box', hints: %w[id] }, json: {} }
  }

  def show
    @box = records.find(params[:id])

    if allowed?(@box.ref, :read)
      respond_to do |format|
        format.html do
          render partial: "show", layout: false, locals: {box: @box}
        end
        format.xml  { render xml: @box.to_xml }
        format.json { render json: @box.to_json }
      end
    else
      render_403 object: @box.ref
    end
  end

  def create
    @box = records.build(box_params)

    # box = Box.from_params(params, current_user.boxes)
    if @box.save
      respond_to do |format|
        format.html { redirect_to boxes_path }
        # format.html do
        #   if request.xhr?
        #     render partial: 'shared/layout/boxes'
        #   else
        #     redirect_back fallback_location: locale_root_url
        #   end
        # end
        format.xml  { render xml: @box.to_xml(only: [:id]) }
        format.json { render json: @box.to_json(only: :id) }
      end
    else
      message = 'You cannot create a box like that'.t

      respond_to do |format|
        format.html do
          flash[:error] = message
          redirect_to boxes_path, status: :see_other
        end
        format.xml { render xml: {message: message, errors: @box.errors} }
        format.json { render json: {message: message, errors: @box.errors} }
      end
    end
  end

  api_method :create, :post => {
    :doc => "Create a favorite.",
    :expects => { :box => { :type => 'string', :required => true, :doc => 'Nested parameter that must contain box[id] (the ID of the object), box[controller] (the controller of the object, namely image, collection, or presentation), and box[action]=\'show\'.' } },
    :returns => { :xml => { :root => 'box', :hints => %w[id] }, :json => {} }
  }

  def toggle
    @box = records.find(params[:id])

    @box.update_attribute(:expanded, !@box.expanded)

    redirect_to boxes_path
  end

  def destroy
    @box = records.find(params[:id])
    @box.destroy

    redirect_to boxes_path, status: :see_other

    # return unless current_user.allowed?(box, :delete)

    # box = ensure_find(Box, params[:id], :delete) { 
    #   update_boxes 
    # } or return

    # if box.destroy && !update_boxes
    #   flash[:notice] = "Box '%s' successfully deleted!" / box.title

    #   respond_to { |format|
    #     format.html { redirect_back fallback_location: locale_root_url }
    #     format.xml  { render :xml => box.to_xml(:only => [:id]) }
    #     format.json { render :json => box.to_json(:only => :id) }
    #   }
    # end
  end

  api_method :delete, :delete => {
    :doc => "Delete a favorite.",
    :expects => { :id => { :type => 'string', :required => true, :doc => 'The id of the favorite.' } },
    :returns => { :xml => { :root => 'box', :hints => %w[id] }, :json => {} }
  }

  def reorder
    # ids = records.where(id: params[:ids]).pluck(:id)
    records.order_by!(params[:ids])

    head :ok
  end


  private

    def records
      return Box.none unless current_user

      current_user.boxes.order('position ASC')
    end

    def box_params
      result = params.fetch(:box, {}).permit(
        :ref_type, :image_id, :collection_id
      )

      # api compatibility
      if legacy_id = (params[:box] || {})[:id]
        legacy_type = (params[:box] || {})[:controller]

        if ['images', 'image', 'ImageBox'].include?(legacy_type)
          result[:ref_type] ||= 'image'
          result[:image_id] ||= legacy_id
        end

        if ['collections', 'collection', 'CollectionBox'].include?(legacy_type)
          result[:ref_type] ||= 'collection'
          result[:collection_id] ||= legacy_id
        end
      end

      result
    end

    # def update_boxes
    #   return unless request.xhr?

    #   render partial: 'shared/layout/boxes'

    #   true
    # end

  initialize_me!

end
