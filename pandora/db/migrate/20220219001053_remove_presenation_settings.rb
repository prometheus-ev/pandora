class RemovePresenationSettings < ActiveRecord::Migration[5.2]
  def up
    Settings.where(type: 'PresentationSettings').delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
