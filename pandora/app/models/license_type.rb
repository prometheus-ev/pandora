class LicenseType < ApplicationRecord

  has_many :licenses, :dependent => :destroy

  validates_presence_of   :amount, :title
  validates_uniqueness_of :title, case_sensitive: true

  def to_s
    "#{title} (#{amount})"
  end

end
