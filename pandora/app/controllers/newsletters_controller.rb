class NewslettersController < ApplicationController
  skip_before_action :login_required, only: [:archive, :webview]

  def self.initialize_me! # :nodoc:
    control_access [:admin, :superadmin] => :ALL,
                   :DEFAULT => [:archive, :webview]
  end

  def index
    emails = records.
      search(search_column, search_value).
      sorted(sort_column, sort_direction)

    # view compatibility
    @page = page
    @per_page = per_page
    @emails = Pandora::Collection.new(
      emails.pageit(page, per_page),
      emails.count,
      page,
      per_page
    )
  end

  def pending
    emails = records.
      pending.
      search(search_column, search_value).
      sorted(sort_column, sort_direction)

    # view compatibility
    @page = page
    @per_page = per_page
    @emails = Pandora::Collection.new(
      emails.pageit(page, per_page),
      emails.count,
      page,
      per_page
    )

    render action: 'index'
  end

  def archive
    emails = records.
      delivered.
      search(search_column, search_value).
      sorted(sort_column, sort_direction)

    # view compatibility
    @page = page
    @per_page = per_page
    @emails = Pandora::Collection.new(
      emails.pageit(page, per_page),
      emails.count,
      page,
      per_page
    )
  end

  def show
    @email = records.find(params[:id])

    allowed =
      (current_user && current_user.admin_or_superadmin?) ||
      (@email.newsletter? && @email.delivered?)
    return forbidden unless allowed
  end

  def webview
    @email = records.find(params[:id])

    allowed =
      (current_user && current_user.admin_or_superadmin?) ||
      (@email.newsletter? && @email.delivered?)

    return forbidden unless allowed
  end

  def recipients
    @email = records.find(params[:id])

    @recipients = @email.recipients_with_expansions
  end

  def new
    @email = if params[:clone_from].present?
      records.find(params[:clone_from]).dup
    else
      Email.newsletter
    end

    # view compatibility
    set_mandatory_fields ['body']
  end

  def edit
    @email = records.find(params[:id])

    return if @email.delivered?

    # view compatibility
    set_mandatory_fields ['body']
  end

  def create
    @email = Email.newsletter

    if @email.update(newsletter_params)
      if params[:deliver].present?
        @email.deliver(current_user)
        flash[:notice] = message(@email, "'%s' successfully created and delivered!")
      else
        flash[:notice] = message(@email, "'%s' successfully created!")
      end

      redirect_to action: 'show', id: @email.id
    else
      # view compatibility
      set_mandatory_fields ['body']

      render action: 'new', status: 422
    end
  end

  def update
    @email = records.find(params[:id])

    if @email.update(newsletter_params)
      # if params[:deliver].present?
      #   @email.deliver_later(current_user)
      #   flash[:notice] = message(@email, "'%s' successfully updated and delivered!")
      # else
      #   flash[:notice] = message(@email, "'%s' successfully updated!")
      # end

      flash[:notice] = message(@email, "'%s' successfully updated!")
      redirect_to action: 'show', id: @email
    else
      # view compatibility
      set_mandatory_fields ['body']

      render action: 'edit', status: 422
    end
  end

  def deliver
    @email = records.find(params[:id])

    if @email.delivered?
      flash[:notice] = message(@email, 'has already been delivered')
      redirect_to action: 'show', id: @email.id
    else
      @email.deliver_later(current_user)

      flash[:notice] = message(@email, 'successfully delivered!')
      redirect_to action: 'show', id: @email.id
    end
  end

  def destroy
    @email = records.find(params[:id])

    if @email.destroy
      flash[:notice] = message(@email, "'%s' successfully deleted!")
      redirect_back fallback_location: url_for(action: 'index')
    end
  end


  protected

    def records
      Email.newsletters
    end

    def newsletter_params
      params.fetch(:email, {}).permit(
        _translations: {
          en: [:subject, :body, :body_html],
          de: [:subject, :body, :body_html]
        }
      )
    end

    def sort_column_default
      'sent_at'
    end

    def sort_direction_default
      if ['sent_at', 'updated_at'].include?(sort_column)
        'desc'
      else
        'asc'
      end
    end

    def message(email, msg)
      "Newsletter #{msg}" / ERB::Util.html_escape(email)
    end

    initialize_me!
end
