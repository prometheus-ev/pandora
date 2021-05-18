class AddIsTimeSearchableToSources < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :is_time_searchable, :boolean, default: false
  end
end
