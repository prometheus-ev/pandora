class CollectionImage < ApplicationRecord
  self.table_name = 'collections_images'

  belongs_to :collection
  belongs_to :image

  def self.insertion_order(direction)
    order(created_at: direction)
  end
end