class AddQuotaToDatabases < ActiveRecord::Migration[5.2]
  def change
    add_column :sources, :quota, :integer, default: 1000
  end
end
