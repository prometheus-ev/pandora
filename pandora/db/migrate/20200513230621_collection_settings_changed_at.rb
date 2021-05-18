class CollectionSettingsChangedAt < ActiveRecord::Migration[5.2]
  def change
    CollectionSettings.where(list_order: 'changed_at').each do |cs|
      cs.update_column :list_order, 'updated_at'
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
