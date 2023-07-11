class CollectionKeyword < ApplicationRecord
  self.table_name = 'collections_keywords'

  belongs_to :keyword
  belongs_to :collection
end