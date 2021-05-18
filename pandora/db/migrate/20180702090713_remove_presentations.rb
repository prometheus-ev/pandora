class RemovePresentations < ActiveRecord::Migration[5.1]
  def change
    execute "DELETE FROM boxes WHERE type = 'PresentationBox'"

    drop_table :slide_images, if_exists: true
    drop_table :slide_items
    drop_table :slides

    drop_table :presentations_collaborators
    drop_table :presentations_viewers
    drop_table :keywords_presentations
    drop_table :presentations
  end
end
