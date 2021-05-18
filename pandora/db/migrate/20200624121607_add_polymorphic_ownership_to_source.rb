class AddPolymorphicOwnershipToSource < ActiveRecord::Migration[5.2]
  def change
    change_table :sources do |t|
      t.string  :owner_type
    end
    
    add_index :sources, [:owner_type, :owner_id]
  end
end
