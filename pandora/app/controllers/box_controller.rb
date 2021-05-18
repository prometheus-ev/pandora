class BoxController < ApplicationController

  skip_before_action :store_location

  def self.initialize_me!  # :nodoc:
    control_access [:superadmin, :user] => :ALL
  end

  # api compatibility
  def list
    boxes = current_user.boxes

    respond_to { |format|
      format.html { redirect_back_or_default }
      format.xml  { render :xml => boxes.to_xml }
      format.json { render :json => "[#{boxes.map { |box| box.to_json }.join(',')}]" }
    }
  end

  api_method :list, :get => {
    :doc => "List a user's favorites.",
    :returns => { :xml => { :root => 'box', :hints => %w[id] }, :json => {} }
  }

  ## Create new box from set of parameters
  def create
    box = Box.from_params(params, current_user.boxes)

    respond_to { |format|
      format.html do
        if request.xhr?
          render partial: 'shared/layout/boxes'
        else
          redirect_back fallback_location: locale_root_url
        end
      end
      format.xml  { render :xml => box.to_xml(:only => [:id]) }
      format.json { render :json => box.to_json(:only => :id) }
    }
  end

  api_method :create, :post => {
    :doc => "Create a favorite.",
    :expects => { :box => { :type => 'string', :required => true, :doc => 'Nested parameter that must contain box[id] (the ID of the object), box[controller] (the controller of the object, namely image, collection, or presentation), and box[action]=\'show\'.' } },
    :returns => { :xml => { :root => 'box', :hints => %w[id] }, :json => {} }
  }

  ## Delete the box from the favourites sidebar
  def delete
    box = Box.find(params[:id])
    return unless current_user.allowed?(box, :delete)

    # box = ensure_find(Box, params[:id], :delete) { 
    #   binding.pry
    #   update_boxes 
    # } or return

    if box.destroy && !update_boxes
      flash[:notice] = "Box '%s' successfully deleted!" / box.title

      respond_to { |format|
        format.html { redirect_back fallback_location: locale_root_url }
        format.xml  { render :xml => box.to_xml(:only => [:id]) }
        format.json { render :json => box.to_json(:only => :id) }
      }
    end
  end

  api_method :delete, :delete => {
    :doc => "Delete a favorite.",
    :expects => { :id => { :type => 'string', :required => true, :doc => 'The id of the favorite.' } },
    :returns => { :xml => { :root => 'box', :hints => %w[id] }, :json => {} }
  }

  def order
    return permission_denied unless request.xhr?

    ids = Array(params[:boxes]).map(&:to_i)
    Box.order(ids & current_user.box_ids, current_user.boxes) unless ids.empty?

    update_boxes
  end


  private

    def update_boxes
      return unless request.xhr?

      render partial: 'shared/layout/boxes'

      true
    end

  initialize_me!

end
