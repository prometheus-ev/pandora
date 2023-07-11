class SearchesController < ApplicationController
  include Util::Config

  helper_method :search_params, :db_group_column, :db_sort_column

  ###############################################################################
  def self.initialize_me!
    control_access [:superadmin, :user] => :ALL,
      [:admin, :useradmin, :dbadmin] => :ALL,
      [:ipuser] => [:index, :advanced, :hits],
      [:dbuser] => [:index, :hits]

    allow_open_access [:index], [:hits] do
      s = (params[:s] || [params[:index]]) and s.is_a?(Array) and s.size == 1 and Source.find_by_name(s)
    end

    linkable_actions :index, :advanced
  end
  ###############################################################################

  def index
    if search_params[:mode] == 'similar'
      @search = ::Pandora::Query.new(current_user, search_params).similar
    else
      @search = ::Pandora::Query.new(current_user, search_params).run
    end
    flash[:warning] = @search.flash[:warning].html_safe if @search.flash[:warning]

    # view compatibility
    @controller_title = "Search".t unless @controller_title
    @page_size_selection = pconfig[:results_per_page] | [per_page]
    @page_size_selection.sort!
    @collections = Collection.
      allowed(current_user, :write).
      includes(:owner, :viewers, :collaborators)

    set_neighbours(@search.hits.map{|h| h['_id']})
    set_neighbourhood

    respond_to do |format|
      format.html
      format.json do
        render :json => api_data(@search), :layout => false
      end
      format.xml do
        render :xml => api_data(@search), :layout => false
      end
    end
  end

  def advanced
    @search = ::Pandora::Query.new(current_user, search_params).run
    flash[:warning] = @search.flash[:warning].html_safe if @search.flash[:warning]

    # view compatibility
    @controller_title = "Advanced search".t unless @controller_title
    @page_size_selection = pconfig[:results_per_page] | [per_page]
    @page_size_selection.sort!
    @collections = Collection.
      allowed(current_user, :write).
      includes(:owner, :viewers, :collaborators)

    set_neighbours(@search.hits.map{|h| h['_id']})
    set_neighbourhood

    respond_to do |format|
      format.html do
         @db_group = search_params["db_group"]
         @expand_list = params["expand_list"]
      end
      format.json do
        render :json => api_data(@search), :layout => false
      end
      format.xml do
        render :xml => api_data(@search), :layout => false
      end
    end
  end

  # api compatibility
  def hits
    account = Account.find_by!(login: 'superadmin')
    @search = Pandora::Query.new(account, search_params).run

    fields = search_params[:search_field] || {'0' => ''}
    values = search_params[:search_value] || {'0' => ''}

    @data = {
      query: {
        field: fields['0'],
        term: values['0']
      },
      count: @search.total
    }

    respond_to { |format|
      format.html { render text: '%d hits' / @search.total }
      format.xml  { render xml: @data.to_xml(root: 'hits') }
      format.json { render json: @data }
      format.all  { render plain: @search.total }
    }
  end


  # API docs

  def self.sort_fields
    SearchSettings.values_for(:order)
  end

  def self.search_fields
    return [
      'all',
      *Indexing::IndexFields.search,
      'associated',
      'related'
    ]
  end

  def self.common_expects
    {
      :page => {
        :type    => 'positiveInteger',
        :default => 1,
        :doc     => 'Number of page to return.'
      },
      :per_page => {
        :type    => 'positiveInteger',
        :default => pconfig[:results_per_page].first,
        :doc     => 'Number of results to display per page.'
      },
      :order => {
        :select  => sort_fields,
        :default => sort_fields.first,
        :doc     => 'Field to sort results by.'
      }
    }
  end

  def self.simple_expects
    {
      :term => {
        :required => true,
        :doc      => 'Query term.'
      },
      :field => {
        :select  => search_fields,
        :default => search_fields.first,
        :doc     => 'Search field.'
      }
    }
  end

  def self.search_returns
    {
      :xml => {
        :root  => 'search',
        :hints => {
          'query'          => false,
          'count'          => false,
          'results/result' => true
        }
      },
      :json => {}
    }
  end

  def self.api_method_index_get
    {
      :doc => 'Perform a "simple" search.',
      :expects => common_expects.merge(simple_expects),
      :returns => search_returns
    }
  end

  api_method :index, :get => api_method_index_get
  api_method :search, :get => api_method_index_get

  api_method :advanced_search, :get => {
    :doc => 'Perform an "advanced" search.',
    :expects => common_expects.merge(
      'v[]' => {
        :required  => true,
        :repeating => true,
        :doc       => 'Query term.'
      },
      'f[]' => {
        :required  => true,
        :repeating => true,
        :doc       => 'Search field.',
        :select    => search_fields
      },
      'o[]' => {
        :repeating => true,
        :doc       => 'Search operator.',
        :select    => pconfig[:operators]
      },
      's[]' => {
        :repeating => true,
        :doc       => 'Sources to search.',
        :select    => Source.active_names
      }
    ),
    :returns => search_returns
  }

  api_method :hits, :get => {
    :doc => 'Number of hits a "simple" search would yield.',
    :expects => simple_expects,
    :returns => { :xml   => { :root => 'hits', :hints => %w[query count] },
                  :json  => {} }
  }


  private

    def default_per_page
      try_setting(:per_page, :search)
    end
    
    def zoom_default
      !search_settings[:zoom].nil? ? search_settings[:zoom] : true
    end
    
    def search_settings
      current_user.try(:search_settings) || {}
    end

    def api_data(search)
      search.hits.map do |hit|
        si = Pandora::SuperImage.new(hit['_id'], elastic_record: hit)

        {
          'source' => {
            'id' => si.source.id,
            'fulltitle' => si.source.fulltitle
          },
          'pid' => si.pid,
          'title' => hit['_source']['title'].to_s || '',
          'descriptive_title' => '',
          'artist' => hit['_source']['artist'].to_s || '',
          'description' => hit['_source']['description'].to_s || '',
          'location' => hit['_source']['location'].to_s || '',
          'date' => hit['_source']['date'].to_s || '',
          'rights_work' => hit['_source']['rights_work'].to_s || '',
          'rights_reproduction' => hit['_source']['rights_reproduction'].to_s || '',
          'credits' => hit['_source']['credits'].to_s || '',
          'size' => hit['_source']['size'].to_s || ''
        }
      end
    end

    def search_params
      # convert legacy :s, :v, :f, :o, :field and :term params, these are not
      # compatible with the new param format so you can either use :s, :v etc.
      # or :search_value, :search_field etc.
      if params[:s].present?
        params[:indices] ||= {}
        params[:s].each{|i| params[:indices][i] = true}
        params.delete :s
      end

      if params[:v].present?
        params[:search_value] ||= {}
        params[:v].each.with_index{|e, i| params[:search_value][i] = e}
        params.delete :v
      end

      if params[:f].present?
        params[:search_field] ||= {}
        params[:f].each.with_index{|e, i| params[:search_field][i] = e}
        params.delete :f
      end

      if params[:o].present?
        params[:boolean_fields_selected] ||= {}
        params[:o].each.with_index{|e, i| params[:boolean_fields_selected][i] = e}
        params.delete :o
      end

      if params[:term].present?
        params[:search_value] ||= {}
        params[:search_value]['0'] = params[:term]
        params.delete :term

        f = params[:field] || 'all'
        f = 'all' unless self.class.search_fields.include?(f)
        params[:search_field] ||= {}
        params[:search_field]['0'] = f
        params.delete :field
      end

      if params[:indices]
        params[:indices].transform_values! do |v|
          [true, 'true'].include?(v) ? true : false
        end
      end

      further_params = {
        page: {size: per_page, number: page},
        sort: {field: sort_column, order: sort_direction},
        db_sort: db_sort_column,
        db_group: db_group_column,
        sample_size: sample_size
      }

      params.permit(
        :source_name,
        :previous_search_value,
        :sample,
        :time,
        :objects,
        :mode,
        boolean_fields_selected: {},
        search_field: {},
        search_value: {},
        indices: {},
        date: {},
        start_date: {},
        end_date: {}
      ).to_h.merge(further_params)
    end

    def per_page_default
      try_setting(:search, :per_page) || super
    end

    def sort_column_default
    end

    def sort_direction_default
    end

    def view_default
      try_setting(:search, :view) || super
    end

    def db_sort_column
      params[:db_sort] || 'title'
    end

    def db_group_column
      params[:db_group].blank? ? 'kind' : params[:db_group]
    end

    def sample_size
      params[:sample_size] || 1
    end

  ###############################################################################
  initialize_me!
  ###############################################################################
end
