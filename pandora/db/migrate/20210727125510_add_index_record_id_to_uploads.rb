class AddIndexRecordIdToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :index_record_id, :string
  end
end
