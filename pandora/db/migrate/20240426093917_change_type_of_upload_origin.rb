class ChangeTypeOfUploadOrigin < ActiveRecord::Migration[7.1]
  def up
    change_column :uploads, :origin, :text
  end

  def down
    change_column :uploads, :origin, :string
  end
end
