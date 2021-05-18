class Source < ApplicationRecord

  include Util::Config
  include Util::Attribution

  self.inheritance_column = :_type_disabled

  enum type: [:dump, :upload]

  belongs_to              :institution
  belongs_to              :contact, class_name: 'Account', foreign_key: 'contact_id', optional: true

  has_and_belongs_to_many :source_admins, -> {with_role('dbadmin')}, :class_name => 'Account', join_table: "admins_sources", :uniq => true

  belongs_to              :dbuser,  class_name: 'Account', foreign_key: 'dbuser_id',  optional: true
  belongs_to              :owner, polymorphic: true,  foreign_key: 'owner_id',  optional: true

  has_many                :images, :dependent => :destroy
  has_many                :uploads, :foreign_key => 'database_id', :dependent => :destroy
  has_many                :rated_images, lambda{where(Image.conditions_for_rated[:conditions])}, class_name: 'Image', :dependent => :destroy

  has_and_belongs_to_many :keywords, :uniq => true, :order => 'title'

  # Required attributes for a source
  REQUIRED = %w[name title kind institution keywords]

  validates_presence_of   *REQUIRED

  validates_format_of     :name, :with => /\A#{LETTER_RE}/,
                          :message => 'must begin with a letter'
  validates_format_of     :name, :with => /\A\w+\z/,
                          :message => 'must only consist of word characters'
                          # in particular: must not match Image::PID_SEPARATOR!
  validates_as_email      :email, allow_blank: true
  validates_presence_of   :emails, if: :can_exploit_rights?

  validates_uniqueness_of :name

  # number in megabytes
  validates :quota, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 50000, allow_nil: true  }

  # Action to be taken before validation
  before_validation :sanitize_email
  after_validation :handle_dbuser

  #############################################################################
  # Class methods
  #############################################################################

  def self.create_user_database(user)
    src = Source.new(
      :title       => "User database #{user.id}",
      :kind        => "User database",
      :type        => "upload",
      :institution => Institution.find_by!(name: 'prometheus'),
      :owner_id    => user.id,
      :keywords    => [Keyword.ensure('Upload')],
      :quota       => Account::DEFAULT_DATABASE_QUOTA
    )

    src.name = "user_database_#{user.id}"
    src.save!

    user.database = src
    user.save!

    src
  end

  # def self.create_institutional_user_database(institution)
  #   src = Source.new(
  #     :title       => "Institutional user database #{institution.id}",
  #     :kind        => "Institutional database",
  #     :type        => "upload",
  #     :institution => institution,
  #     :owner_id    => institution.id,
  #     :keywords    => [Keyword[' Institutional Upload']],
  #     :quota       => Institution::DEFAULT_DATABASE_QUOTA
  #   )

  #   src.name = "institutional_user_database_#{institution.id}"
  #   src.save!

  #   institution.database = src
  #   institution.save!

  #   src
  # end

  def self.find_and_update_or_create_by(name:, kind: '<kind> database', type: 'dump', is_time_searchable: false, record_count:)
    source = self.find_by_name(name)

    unless source
      source = Source.new(
        title: name.titleize,
        kind: kind,
        type: type,
        institution: Institution.find_by!(name: 'prometheus'),
        keywords: [Keyword.ensure('Index')]
      )
      source.name = name
    end

    source.record_count = record_count
    source.is_time_searchable = is_time_searchable
    source.save!
    source.touch

    source
  end

  def self.active_names
    active.order(:name).pluck(:name)
  end

  def self.count_active
    active.count
  end

  def dbadmin_editable_fields
    @dbadmin_fields ||= pconfig[:columns_for][:dbadmin]
  end

  def self.open_access
    where('dbuser_id IS NOT NULL')
  end

  def self.active
    where("record_count > ? AND kind != 'User database'", 0)
  end

  def self.dbadmin(user_id)
    active.join(:admins_sources).where("account_id = ?", user_id)
  end

  def self.any_open_access?
    open_access.exists?
  end

  def self.sorted(column, direction)
    return all if column.blank?

    case column
    when *sort_columns
      order = column
      order = order + ' ' + direction unless direction.blank?

      if column == 'city' || column == 'country'
        includes(:institution).order("institutions.#{order}")
      elsif column == 'institution'
        includes(:institution).order('institutions.title')
      else
        order("sources.#{order}")
      end
    else
      raise Pandora::Exception, "unknown sort criteria for Source: #{column}"
    end
  end

  def self.search(column, value)
    return all if column.blank? or value.blank?

    case column
    when *search_columns
      if column == 'city' || column == 'country'
        includes(:institution).references(:institution).where("institutions.#{column} LIKE ?", "%#{value}%")
      elsif column == 'institution'
        includes(:institution).references(:institution).where("institutions.name LIKE ? or institutions.title LIKE ?", "%#{value}%", "%#{value}%")
      elsif column == 'keywords'
        includes(:keywords).references(:keywords).where('keywords.title LIKE ?', "%#{value}%")
      else
        where("sources.#{column} LIKE ?", "%#{value}%")
      end
    else
      raise Pandora::Exception, "unknown search criteria for Source: #{column}"
    end
  end

  def self.allowed(user)
    if user
      if user.admin? || user.superadmin?
        return all
      else
        return active
      end
    else
      return active
    end
  end

  # Get Source names as array of strings.
  #
  # @return [Array] An array of Source name strings.
  def self.names
    all.map { |source|
      source.name
    }
  end

  def self.search_columns
    ['name', 'title', 'kind', 'city', 'country', 'institution', 'description', 'keywords']
  end

  def self.sort_columns
    ['name', 'title', 'kind', 'city', 'country', 'institution', 'record_count']
  end

  #############################################################################
  # Instance methods
  #############################################################################

  def to_param
    name
  end

  def to_s
    title
  end

  def name=(name)
    if new_record?
      self[:name] = name
    else
      raise "Can't change name"
    end
  end

  def record_count
    if user_database? || institutional_user_database?
      if uploads && record_count = uploads.size
        record_count
      else
        0
      end
    else
      self[:record_count]
    end
  end

  def user_database?
    kind == 'User database'
  end

  def institutional_user_database?
    upload? && kind != 'User database'
  end

  def city
    institution ? institution.city : ''
  end

  def country
    institution ? institution.country : ''
  end

  def emails
    self[:email].presence ||
    (contact && contact.email) ||
    (source_admins.any? && source_admins.map{|a| a.email}) ||
    nil

    # email = self[:email]
    # email = contact.email if email.blank? && contact
    # if email.blank? && source_admins
    #   email = source_admins.map{ |a| a.email }
    # end
    # email || ''
  end

  def keyword_list
    keywords.map{|k| k.title}.join("\n")
  end

  def keyword_list=(value)
    unless value.nil?
      self.keywords = Keyword.from_keyword_list(value)
    end
  end

  def human_title
    user_database? ? "#{owner}, #{'User database'.t}" : title
  end

  def fulltitle
    department_title = "#{human_title}, #{institution.fulltitle}"
    !institution.campus.blank? ? department_title + ", #{institution.campus.fulltitle}" : department_title
  end

  def record_module
    @record_module ||= extend_record_module
  end

  def votes
    @votes ||= rated_images.sum(:votes)
  end

  def score
    @score ||= rated_images.sum(:score)
  end

  def update_rating
    update_attribute(:rating, score.to_f / votes) unless votes.zero?
  end

  def sample
    @sample ||= begin
      elastic = Pandora::Elastic.new
      data = elastic.search [name], {size: 20}
      data['hits']['total']['value'] > 0 ? data['hits']['hits'].shuffle : []
    rescue Pandora::Exception => e
      []
    end
  end

  def active?
    record_count > 0
  end

  def open_access?
    # the attribute might have been changed, but the dbuser might still exist
    return @open_access unless @open_access == nil

    dbuser.is_a?(Account)
  end

  alias_method :open_access, :open_access?

  def open_access=(flag)
    @open_access = [true, '1'].include?(flag)
    # validations might still fail, so we delay destroying the dbuser (with a
    # callback) until after the source has been validated, see next method
  end

  def handle_dbuser
    case @open_access
    when nil then # do nothing, attribute wasn't touched
    when true
      self.dbuser ||= Account.new(
        login: 'source',
        institution: self.institution,
        roles: [Role.find_by!(title: 'dbuser')],
        newsletter: false
      )
      self.dbuser.save validate: false
    when false
      self.dbuser.destroy if self.dbuser
      self.dbuser_id = nil
    end
  end

  def description_translated
    if I18n.locale == :de
      description_de
    else
      description
    end
  end

  def technical_info_translated
    if I18n.locale == :de
      technical_info_de
    else
      technical_info
    end
  end

  def index
    Pandora::Elastic.new.index_uploads(self)
  end
end
