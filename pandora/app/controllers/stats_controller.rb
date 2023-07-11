class StatsController < ApplicationController

  def self.initialize_me!
    control_access(
      [:superadmin, :admin] => [:ALL],
      [:useradmin] => [:new, :create]
    )
  end

  def new
    @csv_stats = CsvStats.for(current_user, csv_stats_params)
  end

  def create
    @csv_stats = CsvStats.for(current_user, csv_stats_params)

    if @csv_stats.valid?
      send_data(@csv_stats.to_csv,
        disposition: @csv_stats.compressed ? 'attachment' : 'inline',
        type: 'text/plain; charset=utf-8',
        filename: @csv_stats.filename
      )
    else
      render action: 'new', status: 422
    end
  end

  def facts_form
    render template: 'stats/facts'
  end

  def facts
    date = params[:date]
    top_terms = (
      params[:top_terms_numbers].blank? ?
      20 :
      params[:top_terms_numbers].to_i
    )
    from = Date.new(date[:top_terms_year].to_i, date[:top_terms_month].to_i, 1)
    to = from.at_end_of_month

    @top_terms = Pandora::SumStats.new(from, to).top_terms(only: top_terms)
    @collections   = Collection.count
    @boxes         = Box.count
    @comments      = Comment.count
    @uploads       = Upload.count
    @ratings       = Source.all.map{|i| i.rated_images.count}.sum
    @subscribers   = Account.email_verified.where(newsletter: true).count
  end


  protected

    def csv_stats_params
      result = params.fetch(:csv_stats, {}).permit(
        :issuer, :institution, :include_ips, :compressed, :from_year,
        :from_month, :to_year, :to_month
      )
    end

  initialize_me!

end
