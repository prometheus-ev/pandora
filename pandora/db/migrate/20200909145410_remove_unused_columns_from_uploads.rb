class RemoveUnusedColumnsFromUploads < ActiveRecord::Migration[5.2]
  def change
    remove_column :uploads, :public_record
    remove_column :uploads, :destroy_record
    remove_column :uploads, :index_record
    remove_column :uploads, :indexed_record
  end
end
