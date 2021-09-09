class ChangeTypeOfUploadAddition < ActiveRecord::Migration[5.2]
  def up
    change_column :uploads, :addition, :text
  end

  def down
    change_column :uploads, :addition, :string
  end
end
