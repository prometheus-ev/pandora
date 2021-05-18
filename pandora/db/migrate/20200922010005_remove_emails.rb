class RemoveEmails < ActiveRecord::Migration[5.2]
  def up
    Email.where('newsletter IS NULL').destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
