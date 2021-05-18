class AddIsbnKeywordTechniqueToUpload < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :isbn, :string
    add_column :uploads, :keyword, :string
    add_column :uploads, :technique, :string
  end
end
