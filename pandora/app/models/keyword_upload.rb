class KeywordUpload < ApplicationRecord
  self.table_name = 'keywords_uploads'

  belongs_to :keyword
  belongs_to :upload
end