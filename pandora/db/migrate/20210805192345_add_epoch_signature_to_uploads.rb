class AddEpochSignatureToUploads < ActiveRecord::Migration[5.2]
  def change
    add_column :uploads, :epoch, :string
    add_column :uploads, :signature, :string
  end
end
