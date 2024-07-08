class ChangeTypeOfUploadTitle < ActiveRecord::Migration[7.1]
  def up
    change_column :uploads, :title, :text
  end

  def down
    change_column :uploads, :title, :string
  end
end
