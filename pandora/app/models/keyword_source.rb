class KeywordSource < ApplicationRecord
  self.table_name = 'keywords_sources'

  belongs_to :keyword
  belongs_to :source
end