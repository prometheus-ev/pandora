class AddIndexOnCollectionsImages < ActiveRecord::Migration[5.2]
  def change
    change_table :collections_images do |t|
      t.index ['collection_id'], name: 'collectiony'
    end
  end
end
