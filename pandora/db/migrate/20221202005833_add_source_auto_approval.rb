class AddSourceAutoApproval < ActiveRecord::Migration[7.0]
  def change
    add_column :sources, :auto_approve_records, :boolean
  end
end
