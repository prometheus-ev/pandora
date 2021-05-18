class RemoveBounceEmails < ActiveRecord::Migration[5.2]
  def change
    drop_table :bounce_emails do |t|
      t.string :message_id, :address
      t.text :error
      t.datetime :date
      t.boolean :retryable, :default => false
      t.integer :user_id
      t.timestamps
    end
  end
end
