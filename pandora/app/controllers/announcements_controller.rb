class AnnouncementsController < ApplicationController

  include Util::Config

  skip_before_action :store_location, :only => [:hide]
  skip_before_action :login_required, :only => [:current, :hide, :index, :list]

  DEFAULT_ORDER     = 'date'.freeze
  DEFAULT_DIRECTION = 'DESC'.freeze

  def self.initialize_me!  # :nodoc:
    control_access [:admin, :superadmin] => :ALL,
                   :DEFAULT => [:current, :hide, :index, :list]

    linkable_actions :new, :list, :current
  end

  def hide
    session[:announcement_hide_time] = current_time = Time.now.utc

    if current_user && !current_user.anonymous?
      current_user.update_attribute(:announcement_hide_time, current_time)
    end

    if request.xhr?
      # REWRITE: not supported anymore, we need to deal with this client-side
      # render :update do |page|
      #   page[:announcements].hide
      # end
      render plain: 'ok'
    elsif request.env['HTTP_REFERER']
      redirect_back fallback_location: locale_root_url
    else
      head :ok
    end
  end

  def index
    if current_user && current_user.action_allowed?(:announcements, :current)
      redirect_to :action => 'current'
    else
      redirect_to :action => 'list'
    end
  end

  def list(current_only = false)
    if params[:field] == 'current'
      params.delete(:field)
      # REWRITE: limit redirect to current host 
      # redirect_to params.merge({ :action => 'current' })
      redirect_to params.merge({ :action => 'current', :only_path => true })
      return
    end

    @order     = params[:order]     || DEFAULT_ORDER
    @direction = params[:direction] || DEFAULT_DIRECTION

    set_list_search
    set_is_admin

    @params = {
      :search => params[:value] || params[:search],
      :current => current_only
    }

    @announcements = Announcement.pandora_find(:all, @params).to_a
    @announcements.delete_if { |announcement| !announcement.allowed?(current_user) }

    respond_to { |format|
      format.html { render :action => 'list' }
      format.xml  { render :xml => @announcements.to_a }
      format.json { render :json => '[' + @announcements.map { |a| a.to_json }.join( ', ') + ']' }
    }
  end

  def current
    if !current_user && request.auth_header?
      login_required
    end

    list(true)
  end

  api_method :current, :get => {
    :doc => 'Get the list of current announcements.',
    :returns => { :xml => { :root => 'announcements', :hints => { 'announcement' => true } }, :json => {} }
  }

  def new
    @announcement = Announcement.new(:title_de => '', :title_en => '', :body_de => '', :body_en => '', :starts_at => Time.now, :ends_at => Time.now, :role => '')
  end

  def create
    @announcement = Announcement.new(announcement_params)
    if @announcement.save
      redirect_to :action => 'show', :id => @announcement
    else
      render :action => 'new'
    end
  end

  def show
    @announcement = Announcement.find(params[:id])
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])

    if @announcement.update(announcement_params)
      flash[:notice] = "Announcement '%s' successfully updated!".t / @announcement
      redirect_to :action => 'show'
    else
      render :action => 'edit'
    end
  end

  def publish
    @announcement = Announcement.find(params[:id])

    if @announcement.expired?
      flash[:warning] = "Announcement '%s' could not be published! It already expired. Please change the date it ends at.".t / @announcement
      render :action => 'show'
    else
      if @announcement.update(:starts_at => Time.now.utc)
        flash[:notice] = "Announcement '%s' successfully published!".t / @announcement
        redirect_to :action => 'show'
      else
        flash[:warning] = "Announcement '%s' could not be published!".t / @announcement
        render :action => 'show'
      end
    end
  end

  def withdraw
    @announcement = Announcement.find(params[:id])

    if @announcement.update({:ends_at => Time.now.utc})
      flash[:notice] = "Announcement '%s' successfully withdrawn!".t / @announcement
      redirect_to :action => 'show'
    else
      flash[:warning] = "Announcement '%s' could not be withdrawn!".t / @announcement
      render :action => 'show'
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])

    begin
      @announcement.destroy
      flash[:notice] = "Announcement '%s' successfully deleted!".t / @announcement
      redirect_to(:action => 'list')

    rescue
      flash[:warning] = "Announcement '%s' couldn't be deleted!".t / @announcement
      redirect_to(:action => 'list')
    end
  end


  #############################################################################
  private
  #############################################################################

  def announcement_params
    params.require(:announcement).permit(:title_de, :title_en, :body_de, :body_en, :starts_at, :ends_at, :role, :id)

  end

###############################################################################
  initialize_me!
###############################################################################

end
