class RemoveUploadsOwnerId < ActiveRecord::Migration[7.0]
  def change
    remove_column :uploads, :owner_id, :integer
  end
end
