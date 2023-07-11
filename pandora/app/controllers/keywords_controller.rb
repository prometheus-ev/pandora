class KeywordsController < ApplicationController
  def self.initialize_me!
    control_access(
      [:superadmin, :admin] => :ALL,
      DEFAULT: ['suggest']
    )
  end

  def index
    scope = records

    # view compatibility
    @keywords = Pandora::Collection.new(
      scope.pageit(page, per_page),
      scope.count,
      page,
      per_page
    )
  end

  def suggest
    @keywords = records.
      includes(:sources, :collections, :uploads).
      limit(10).
      distinct

    render layout: false
  end

  def untranslated
    scope = records.untranslated

    # view compatibility
    @keywords = Pandora::Collection.new(
      scope.pageit(page, per_page),
      scope.count,
      page,
      per_page
    )

    render action: 'index'
  end

  def similar
    @similar = Keyword.search(search_column, search_value).similar
    @by_soundex = Keyword.by_soundex(@similar.map{|s| s['sound']})
  end

  def show
    @keyword = Keyword.find(params[:id])
  end

  def new
    @keyword = Keyword.new
  end

  def create
    @keyword = Keyword.new(keyword_params)

    if @keyword.save
      flash[:notice] = "Keyword '%s' successfully created!" / @keyword.t
      redirect_to action: 'index'
    else
      # TODO: error messages
      render action: 'index'
    end
  end

  def edit
    @keyword = Keyword.find(params[:id])
  end

  def update
    @keyword = Keyword.find(params[:id])

    if @keyword.update(keyword_params)
      flash[:notice] = "Keyword '%s' successfully updated!" / @keyword.t
      redirect_to action: 'index'
    else
      # TODO: error messages
      render action: 'edit', status: 422
    end
  end

  def merge
    if params[:other_ids].is_a?(String)
      params[:other_ids] = params[:other_ids].split(',').map(&:to_i)
    end

    @keyword = Keyword.find(params[:id])
    @keyword.merge(params[:other_ids])

    flash[:notice] = "Keywords successfully merged into '%s'" / @keyword.t
    redirect_back fallback_location: similar_keywords_path
  end

  def destroy
    @keyword = Keyword.find(params[:id])

    @keyword.destroy
    flash[:notice] = "Keyword '%s' successfully deleted!" / @keyword.t
    redirect_back fallback_location: similar_keywords_path
  end

  initialize_me!


  protected

    def records(rw = :read)
      Keyword.
        sorted(sort_column, sort_direction).
        search('title', search_value)
    end

    def keyword_params
      params.fetch(:keyword, {}).permit(:title, :title_de)
    end

    def sort_column_default
      'title'
    end

    def per_page_default
      100
    end
end
