class AddObjectCountToSources < ActiveRecord::Migration[7.0]
  def change
    add_column :sources, :object_count, :integer, default: 0
  end
end
