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
  end

  # def csv
    # date = params[:date] || {}

    # @from_year, @from_month, @to_year, @to_month = [
    #   date[:from_year]  || Date.today.year,
    #   date[:from_month] || Date.today.month,
    #   date[:to_year],
    #   date[:to_month]
    # ].map { |i| i.to_i }

    # is_useradmin = current_user.useradmin_only?

    # @issuers = (is_useradmin ? [] : Institution::ISSUERS.map(&:downcase))
    # @issuer  = params[:issuer] if @issuers.include?(params[:issuer])

    # @institutions = if is_useradmin
    #   institutions = current_user.admin_institutions
    #   (institutions + institutions.map(&:all_departments).flatten).uniq
    # else
    #   Institution.campuses
    # end.map { |i| i.name.downcase }

    # @institution = Institution[params[:institution]] if @institutions.include?(params[:institution])

    # @include_ips = params[:include_ips]
    # @compressed  = params[:compressed]

    # if params[:commit]
    #   options = {}

      # if @issuer && !@institution
      #   options[:issuer]   = @issuer
      #   options[:features] = :prometheus if @issuer == 'prometheus'
      # elsif @institution && !@issuer
      #   options[:for] = @institution
      #   options[:by]  = :ips if params[:include_ips]
      # else
      #   flash.now[:warning] = "You must select #{'either an issuer or ' unless is_useradmin}an institution.".t
      #   return
      # end

      # @to_year  = @from_year  if @to_year.zero?
      # @to_month = @from_month if @to_month.zero?

      # filename = 'prometheus_stats-%s-%d_%02d-%d_%02d.csv' % [
      #   @issuer || @institution.name, @from_year, @from_month, @to_year, @to_month
      # ]

    #   data = Stats.write_csv(
    #     nil, [@from_year, @from_month], [@to_year, @to_month], options
    #   )

    #   if params[:compressed]
    #     filename << '.gz'
    #     data = gzip(data)
    #   end

    #   send_data(
    #     data,
    #     :disposition => params[:compressed] ? 'attachment' : 'inline',
    #     :type        => 'text/plain; charset=utf-8',
    #     :filename    => filename
    #   )
    # end
  # end


  protected

    def csv_stats_params
      result = params.fetch(:csv_stats, {}).permit(
        :issuer, :institution, :include_ips, :compressed, :from_year,
        :from_month, :to_year, :to_month
      )
    end

    # def dates
    #   date = params.fetch(:date, {}).permit!

    #   result = {
    #     from_year: (date[:from_year] || Date.today.year).to_i,
    #     from_month: (date[:from_month] || Date.today.month).to_i,
    #     to_year: date[:to_year].to_i,
    #     to_month: date[:to_month].to_i
    #   }
    # end

    # def useradmin_only?
    #   current_user && current_user.useradmin_only?
    # end

    # def institution
    #   name = params[:institution]

    #   if institutions.include?(name)
    #     Institution.find_by(name: name)
    #   end
    # end

    # def institutions
    #   results = if is_useradmin
    #     institutions = current_user.admin_institutions
    #     (institutions + institutions.map(&:all_departments).flatten).uniq
    #   else
    #     Institution.campuses
    #   end

    #   results.map{ |i| i.name.downcase }
    # end

    # def issuer
    #   (issuers & [params[:issuer]]).first
    # end

    # def issuers
    #   useradmin_only? ? [] : Institution::ISSUERS.map(&:downcase)
    # end

  initialize_me!

end
