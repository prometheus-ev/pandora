class License < ApplicationRecord

  belongs_to :license_type
  belongs_to :account, optional: true
  belongs_to :institution, optional: true

  validates_presence_of :license_type
  validates_presence_of :valid_from, :expires_at, :on => :update

  before_validation on: :create do
    self.valid_from ||= Time.now.utc
    self.paid_from ||= valid_from.utc.beginning_of_quarter
    self.expires_at ||= [valid_from, paid_from].max.utc.at_end_of_year
  end

  def self.count_institutional(at = Time.now)
    current(at).not_single.select(:institution_id).distinct.count
  end

  def self.institution_ids(at = Time.now)
    current(at).where('institution_id IS NOT NULL').pluck(:institution_id)
  end

  def single?
    license_type == LicenseType[:single]
  end

  def self.not_single
    where('license_type_id <> ?', LicenseType.find_by!(title: 'single').id)
  end

  def current?(at = Time.now)
    at = at.utc
    valid_from && expires_at && valid_from <= at && expires_at > at
  end

  def self.current(at = nil)
    at ||= Time.now
    where('valid_from <= :at AND expires_at > :at', at: at.utc)
  end

  def to_s
    # TODO: include amount only optionally?
    # TODO: include duration or start/end?
    license_type.to_s
  end

  def licensee
    institution_id ? institution : account
  end

  def duration  # years
    months = expires_at.month - paid_from.month + (expires_at.year - paid_from.year) * 12
    months != 0 ? months / 12.0 : (expires_at - paid_from) / 1.year
  end

  def expired?
    expires_at < Date.today
  end

  def self.valid
    where("valid_from >= :date OR paid_from >= :date", date: Time.now)
  end

  def self.expired
    where("valid_from < :date AND paid_from < :date", date: Time.now)
  end

  alias_method :_original_license_type_setter, :license_type=
  protected :_original_license_type_setter

  def license_type=(license_type)
    raise 'not a new record' unless new_record?
    _original_license_type_setter(license_type)
  end

  def paid_from_quarter
    if date = self.paid_from
      Pandora::Utils.quarter_for(date)
    end
  end

  def paid_from_quarter=(value)
    if value.is_a?(String) && m = value.match(/^(\d{4})\/(\d)$/)
      year = m[1].to_i
      month = (m[2].to_i - 1) * 3 + 1
      value = Date.new(year, month, 1)
    end

    self.paid_from = value
  end
end
