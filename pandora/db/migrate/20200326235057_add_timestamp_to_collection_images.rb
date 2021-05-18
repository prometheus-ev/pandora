class AddTimestampToCollectionImages < ActiveRecord::Migration[5.2]
  def up
    add_column :collections_images, :created_at, :datetime
  end

  def down
    remove_column :collections_images, :created_at
  end
end
