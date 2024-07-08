class Location < ApplicationRecord
  include Util::Config

  belongs_to :owner, :class_name => 'Account', :foreign_key => 'owner_id'
  belongs_to :image, :dependent => :destroy

  REQUIRED = %w[owner_id image_id latitude longitude]
  validates_presence_of *REQUIRED
end
