require 'csv'

class CsvStats

  include ActiveModel::Model

  def self.for(user, attribs)
    result = new(user: user)
    result.assign_attributes(attribs)
    result    
  end

  attr_writer :from_year
  attr_writer :from_month
  attr_writer :to_year
  attr_writer :to_month
  attr_reader :issuer
  attr_accessor :institution
  attr_reader :include_ips
  attr_reader :compressed
  attr_accessor :features
  attr_accessor :user

  def from_year
    (@from_year ||= Date.today.year).to_i
  end

  def from_month
    (@from_month ||= Date.today.month).to_i
  end

  def to_year
    (@to_year ||= from_year).to_i
  end

  def to_month
    (@to_month ||= from_month).to_i
  end

  def issuer=(value)
    if issuers.include?(value)
      @issuer = value
    end
  end

  def include_ips=(value)
    @include_ips = ActiveModel::Type::Boolean.new.cast(value)
  end

  def compressed=(value)
    @compressed = ActiveModel::Type::Boolean.new.cast(value)
  end

  def features
    issuer == 'prometheus' ? :prometheus : nil
  end

  def by
    include_ips ? :ips : nil
  end

  def for
    if institutions.include?(institution)
      Institution.find_by(name: institution)
    end
  end

  def filename
    result = 'prometheus_stats-%s-%d_%02d-%d_%02d.csv' % [
      issuer || self.for.name, from_year, from_month, to_year, to_month
    ]

    compressed ? result + '.gz' : result
  end

  validate do |s|
    if s.issuer.present? == s.institution.present?
      if s.user.useradmin_only?
        s.errors.add :base, "You must select an institution.".t
      else
        s.errors.add :base, "You must select either an issuer or an institution.".t
      end
    end
  end

  def issuers
    user.useradmin_only? ? [] : Institution::ISSUERS.map(&:downcase)
  end

  def institutions
    result = if user.useradmin_only?
      institutions = user.admin_institutions
      (institutions + institutions.map(&:all_departments).flatten).uniq
    else
      Institution.campuses
    end

    result.map{|i| i.name.downcase}
  end

  def to_csv
    data = self.class.write_csv(nil,
      [from_year, from_month],
      [to_year, to_month],
      issuer: issuer,
      features: features,
      for: self.for,
      by: by
    )

    compressed ? Pandora.gzip(data) : data
  end

  # generate the stats CSV from with the SumStats model according to
  # https://redmine.prometheus-srv.uni-koeln.de/issues/1188
  # @param from [Array<String, Integer>] the start month, e.g. [2019, 4] for
  #                                      January 2019
  # @param to [Array<String, Integer>] the end month, for example see from
  #                                    parameter
  # @param receiver [Array] the result is pushed to this array
  # @option options [Institution] :for (nil) the institution to get stats for
  # @option options [String] :issuer (nil) either "prometheus" or "hbz"
  def self.get_csv(from = [], to = [], receiver = [], options = {})
    headers = [
      'Jahr_Monat',
      'Name',
      'Title',
      'Sessions',
      'Searches',
      'Downloads'
    ]

    dates = []
    from = Date.new(from.first, from.last, 1)
    to = Date.new(to.first, to.last, 1).at_end_of_month
    current = from
    while current < to
      dates << current
      current += 1.month
    end

    institutions = (
      options[:for] ?
      [options[:for]] :
      Institution.
        licensed_anytime_within(
          dates.first.at_beginning_of_month,
          dates.last.at_end_of_month
        ).
        roots.
        where(issuer: options[:issuer]).
        order(:name)
    )

    receiver << headers

    institutions.each do |institution|
      dates.each do |date|
        ids = [institution.id] + institution.departments.map{|d| d.id}
        scope = SumStats.
          where(institution_id: ids).
          where(year: date.year, month: date.month)
        receiver << [
          date.strftime('%Y_%m'),
          institution.name,
          institution.title,
          scope.total_sessions,
          scope.total_searches,
          scope.total_downloads
        ]
      end
    end

    receiver
  end

  def report(date, institution, scope)
    return [
      date.strftime('%Y_%m'),
      institution.name,
      institution.title,
      scope.sum(:sessions_campus) + scope.sum(:sessions_personalized),
      scope.sum(:searches_campus) + scope.sum(:searches_personalized),
      scope.sum(:downloads_campus) + scope.sum(:downloads_personalized)
    ]
  end

  def self.get_console_csv(from, to)
    result = []

    result << [
      'Jahr_Monat',
      'Name',
      'Title',
      'Sessions',
      'Sessions personalized',
      'Searches',
      'Searches personalized',
      'Downloads',
      'Downloads personalized'
    ]

    institutions = Institution.order(:name)

    dates = []
    current = from
    while current < to
      dates << current
      current += 1.month
    end

    dates.each do |date|
      scope = SumStats.where(year: date.year, month: date.month)

      institutions.each do |institution|
        iscope = scope.where(institution_id: institution.id)

        result << [
          date.strftime('%Y_%m'),
          institution.name,
          institution.title,
          iscope.sum(:sessions_campus),
          iscope.sum(:sessions_personalized),
          iscope.sum(:searches_campus),
          iscope.sum(:searches_personalized),
          iscope.sum(:downloads_campus),
          iscope.sum(:downloads_personalized)
        ]
      end
    end

    result
  end

  def self.write_csv(filename = nil, from = [], to = [], options = {})
    csv = CSV.new(
      filename ?
        filename =~ /\.gz/i ?
          Zlib::GzipWriter.open(filename) :
          File.open(filename, 'w') :
        str = ''
    )

    get_csv(from, to, csv, options).close

    str || csv
  end
end
