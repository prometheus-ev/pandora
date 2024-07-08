require 'resolv'
require 'pandora/validation/email_validator'

class Institution < ApplicationRecord
  include Util::Config

  has_many                :licenses, :dependent => :destroy
  has_many                :accounts
  has_many                :sources, :dependent => :restrict_with_error
  has_many                :databases, :class_name => 'Source', as: :owner, :foreign_key => 'owner_id', :dependent => :destroy
  has_many                :departments, lambda{where('institutions.id != institutions.campus_id')}, :class_name => 'Institution', :foreign_key => 'campus_id'
  belongs_to              :campus,      :class_name => 'Institution', :foreign_key => 'campus_id', optional: true
  belongs_to              :contact,     :class_name => 'Account',     :foreign_key => 'contact_id', optional: true
  belongs_to              :ipuser,      :class_name => 'Account',     :foreign_key => 'ipuser_id', optional: true
  has_and_belongs_to_many :admins, ->{with_role('useradmin')}, :class_name => 'Account', :uniq => true

  serialize :hostnames, coder: YAML, type: Array

  REQUIRED = %w[name title city country]

  DEFAULT_DATABASE_QUOTA = 51200 # in megabytes

  validates_presence_of *REQUIRED
  validates_format_of :name, {
    :with => /\A#{LETTER_RE}/,
    :message => 'must begin with a letter'
  }
  validates :email, :'pandora/validation/email' => true, allow_blank: true
  validates_uniqueness_of :name, :title, :case_sensitive => false

  # REWRITE: re-activating custom legacy validations
  validate :validate_legacy

  before_validation :sanitize_email

  ISSUERS = ['prometheus', 'HBZ'].freeze

  def self.prometheus
    @prometheus ||= find_by!(name: 'prometheus')
  end

  def self.find_by_ip(ip)
    find_each batch_size: 10 do |i|
      return i if i.authorizes_ip?(ip)
    end
  end

  def self.same_campus?(*institutions)
    campus_id = nil

    institutions.uniq.each {|institution|
      id = institution.top_campus.id or return
      return false unless id == campus_id ||= id
    }

    campus_id
  end

  def self.roots
    where(campus_id: nil)
  end

  def self.issuer_ids
    where(name: ISSUERS).pluck(:id)
  end

  def self.licensed_ids(via_campus = false, at = Time.now)
    ids = License.institution_ids(at) + issuer_ids

    if via_campus
      campus_ids = ids

      while campus_ids.any?
        # TODO: break potential circular dependencies!?
        campus_ids = where(campus_id: campus_ids).pluck(:id)
        ids.concat(campus_ids)
      end
    end

    ids.uniq
  end

  def self.licensed(via_campus = false, at = Time.now)
    # REWRITE: trying to find all licensed institutions. This should be doable
    # like this:
    where(id: licensed_ids(via_campus, at))
    # find_from_ids([licensed_ids(via_campus, at)], {})
  end

  def self.licensed_anytime_within(from, to)
    ids = License.
      where('institution_id IS NOT NULL').
      where('valid_from <= :to AND expires_at >= :from', from: from, to: to).
      pluck(:institution_id)

    # prometheus is always licensed
    ids << prometheus.id

    where(id: ids)
  end

  def self.licensed_and_issuer(issuer = 'hbz', via_campus = false, at = Time.now)
    # REWRITE: find from ids is gone, we'll use find_by(id: ...) instead. Also
    # we use the new ar query interface
    # find_from_ids(licensed_ids(via_campus, at) & find_ids(:conditions => sql_in(:issuer, issuer)), {})
    ids = licensed_ids(via_campus, at) & where(issuer: issuer).pluck(:id)
    where(id: ids).to_a
  end

  def self.campuses_and_departments(at = Time.now)
    campuses(true, at)
  end

  def self.licensed_real
    ids = License.institution_ids - issuer_ids
    where(id: ids)
  end

  def self.sorted(column, direction)
    return all if column.blank?

    case column
    when 'name', 'title', 'city', 'country'
      order(column => direction)
    when 'licenses.license_type_id'
      includes(:licenses).
        references(:licenses).
        order("licenses.license_type_id #{direction}")
    else
      raise Pandora::Exception, "unknown sort criteria for Institution: #{column}"
    end
  end

  def self.search(column, value)
    return all if column.blank? or value.blank?

    case column
    when 'name', 'title', 'description', 'city'
      where("#{column} LIKE ?", "%#{value}%")
    else
      raise Pandora::Exception, "unknown search criteria for Institution: #{column}"
    end
  end

  def self.display_columns_for_user
    # REWRITE: use pconfig to avoid the conflict with the rails method
    # @display_columns_for_user ||= columns_by_name(*config[:columns_for][:user])
    @display_columns_for_user ||= columns_by_name(*pconfig[:columns_for][:user])
  end

  class << self
    alias_method :campuses, :licensed
  end

  def to_s
    shorttitle
  end

  def to_param
    name
  end

  def fulltitle
    title
  end

  def short
    # REWRITE: this method has changed signature. Also, do not escape the
    # truncated text
    # TODO: check how institution titles are getting into the system and ensure
    # security
    # @short ||= self[:short].blank? ? Util::Helpers::TextHelper.truncate(title, 30) : self[:short]
    @short ||= self[:short].blank? ? Util::Helpers::TextHelper.truncate(title, length: 30, escape: false) : self[:short]
  end

  def shorttitle
    "#{city}, #{short}"
  end

  def city_with_postalcode
    if !postalcode.blank?
      "#{postalcode} #{city}"
    else
      "#{city}"
    end
  end

  def location
    location = addressline.blank? ? '' : "#{addressline}" + (postalcode.blank? ? '' : ', ')
    location << (postalcode.blank? ? '' : "#{postalcode}" + (city.blank? ? '' : ' '))
    location << (city.blank? ? '' : "#{city}" + (country.blank? ? '' : ', '))
    location << (country.blank? ? '' : "#{country}")
  end

  def authorizes_ip?(ip)
    result = false

    ip_ranges.each do |r|
      return false if r.excludes?(ip)

      result |= r.contains?(ip)
    end

    hostnames.each do |h|
      begin
        resolver = Resolv::DNS.new
        return true if resolver.getaddress(h).to_s == ip
      rescue Resolv::ResolvError => e
        Rails.logger.info("Institution#authorizes_ip?: #{e.message}")

        false
      end
    end

    result
  end

  def ip_ranges
    return [] if ipranges.blank?

    ipranges.split(/\r?\n/).reject{|e| e.blank?}.map do |line|
      Pandora::IpRange.parse(line)
    end
  end

  def hostnames=(value)
    self[:hostnames] = from_textarea(value).map(&:strip)
  end

  def license(at = default = Time.now)
    if default
      @license ||= license(default)
    else
      # REWRITE: use new query interface
      # licenses.find(:first, License.conditions_for_current(at))
      licenses.current(at).first
    end
  end

  def elapsed_licenses(at = Time.now)
    # REWRITE: using new query interface
    # licenses.find(:all, :conditions => ['expires_at <= ?', at.utc])
    licenses.where('expires_at <= ?', at.utc)
  end

  def last_license
    @last_license ||= license || elapsed_licenses.last
  end

  def upcoming_licenses(at = Time.now)
    # REWRITE: using new query interface
    # licenses.find(:all, :conditions => ['valid_from > ?', at.utc])
    licenses.where('valid_from > ?', at.utc)
  end

  def next_license
    @next_license ||= upcoming_licenses.first
  end

  def campus_license(at = default = Time.now)
    if default
      @campus_license ||= campus_license(default)
    else
      campus.license(at) || campus.campus_license(at) if campus
    end
  end

  def licensee
    if _license = license || campus_license
      _license.licensee
    end
  end

  def licensed?
    ISSUERS.include?(name) || license || (campus && campus.licensed?)
  end

  # REWRITE: changed to prevent ruby 2.2 circular argument warning
  def license_type(license = nil)
    (license || self.license).try(:license_type)
  end

  def expire!(at = Time.now)
    at = at.utc

    if expires_at = license && license.expires_at
      license.update_attribute(:expires_at, at) if expires_at > at
    end

    departments.each{|department| department.expire!(at)}

    at
  end

  def license=(new_license)
    expire!(new_license.valid_from - 1)

    licenses << new_license
  end

  def license_attributes=(license_attributes)
    if (new_license_type = license_attributes[:license_type]).blank?
      license.update_attribute(:expires_at, Time.now.utc) if license
    else
      real_license_type =
        new_license_type.is_a?(LicenseType) ?
        new_license_type :
        LicenseType.find(new_license_type)

      if real_license_type
        # just change the current license if the license types are the same...
        old_date = (license && license.valid_from ? license.valid_from.to_date : nil)
        change_current_license = (
          real_license_type == license_type &&
          license_attributes['valid_from'] == old_date
        )

        if paid_from = license_attributes[:paid_from]
          if paid_from.is_a?(Time)
            license_attributes[:paid_from] = paid_from
          end

          if paid_from.is_a?(String)
            if paid_from.match?(/\A\d+\z/)
              license_attributes[:paid_from] = Time.at(paid_from.to_i)
            end
          end
        end

        if change_current_license
          license.update(
            license_attributes.except(:license_type, :valid_from)
          )
        else
          self.license = License.create!(
            license_attributes.merge(:license_type => real_license_type)
          )
        end
      else
        raise ArgumentError, "invalid license type: #{new_license_type.inspect}"
      end
    end
  end

  # TODO: this will only work if the server has been started within the current
  # year
  def renew_license(at = Time.now.next_year, at_beginning_of_year = true)
    at = at.utc
    at = at.at_beginning_of_year if at_beginning_of_year

    self.license_attributes = {
      :license_type => license_type(last_license),
      :valid_from => at,
      :paid_from => at,
      :expires_at => at.at_end_of_year
    } if renewable?(at)
  end

  def renewable?(at = Time.now.next_year.at_beginning_of_year)
    license && !licenses.exists?(:valid_from => at)
  end

  # alias_method :assigned_admins, :admins

  # def admins
  #   assigned_admins.select(&:useradmin?)
  # end

  def active_admins
    admins.active
  end

  def active_sources
    sources.select(&:active?)
  end

  def admin_count
    admins.active.distinct.count
  end

  def user_count(conditions = {})
    accounts.active.personal.count
  end

  def all_accounts(conditions = {})
    Account.where(institution_id: [self.id] + all_department_ids)
  end

  def all_departments(conditions = {})
    departments.empty? ? [] : self.class.where(id: all_department_ids)
  end

  def all_department_ids(ids = [])
    departments.map{|i| [i.id] + i.all_department_ids}.uniq
  end

  def top_campus
    campus ? campus.top_campus : self
  end

  def same_campus?(*others)
    raise ArgumentError, "at least one argument required" if others.empty?

    self.class.same_campus?(self, *others)
  end

  def update_ipuser
    update_attribute(:ipuser, Account.create_ipuser(self))
  end


  protected

    # REWRITE: renaming to avoid conflict with rails code (preemptive measure)
    # def validate
    def validate_legacy
      if ipranges.present?
        pristine = self.pristine

        campus_changed =
          (ipranges_changed = new_record? || ipranges != pristine.ipranges) ||
          new_record? ||
          campus_id != pristine.campus_id

        validate_ranges
        # (!ipranges_changed || validate_ranges != false) &&
        #   (!campus_changed || check_range_overlap != false)
      end
    end

    # REWRITE: changed to prevent ruby 2.2 circular argument warning
    def validate_ranges
      ip_ranges.each do |r|
        if r == :invalid
          errors.add :ipranges, :invalid
          return false
        end
      end
      # Util::IP.parse_ranges(ipranges || self.ipranges)
    end
end
