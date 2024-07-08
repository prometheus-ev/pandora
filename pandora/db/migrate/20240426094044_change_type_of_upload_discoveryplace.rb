class ChangeTypeOfUploadDiscoveryplace < ActiveRecord::Migration[7.1]
  def up
    change_column :uploads, :discoveryplace, :text
  end

  def down
    change_column :uploads, :discoveryplace, :string
  end
end
