class AddUserMetadata < ActiveRecord::Migration[7.0]
  def up
    create_table :user_metadata do |t|
      t.string :pid
      t.text :updates

      t.timestamps
    end

    add_index :user_metadata, [:pid], name: 'identy'
  end

  def down
    drop_table :user_metadata
  end
end
