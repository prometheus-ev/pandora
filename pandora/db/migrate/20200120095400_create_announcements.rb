class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        drop_table :announcements, if_exists: true
        create_table :announcements do |t|
          t.datetime :starts_at
          t.datetime :ends_at
          t.timestamps null: false

          t.string :role, default: 'anyone'

          t.string :title_de
          t.string :title_en
          t.text :body_de
          t.text :body_en
        end
      end
      dir.down do
        drop_table :announcements, if_exists: true
        create_table :announcements do |t|
          t.datetime :starts_at
          t.datetime :ends_at

          # t.datetime :created_at
          # t.datetime :updated_at
          t.timestamps null: false

          t.text :roles
          t.string :category

          t.text :message
          t.text :message_de
        end
      end
    end
  end
end
