class AddUploadSourceAssociation < ActiveRecord::Migration[5.2]
  def change

    change_table :uploads do |t|
      t.belongs_to :database
    end

  end
end
