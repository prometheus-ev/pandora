class AddAddToIndexToUploads < ActiveRecord::Migration[7.0]
  def change
    change_table :uploads do |t|
      t.boolean :add_to_index
    end

    Upload.update_all add_to_index: false
  end
end
