class CreateSourceAdmins < ActiveRecord::Migration[5.2]
  def up
    create_table :admins_sources, id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to :account, index: true
      t.belongs_to :source, index: true
    end

    # after successful migration Source[:admin_id] can be removed
    Source.where.not(admin_id: nil).each do |s|
      execute "INSERT INTO admins_sources (account_id, source_id) VALUES (#{s.admin_id}, #{s.id})"
    end
  end

  def down
    drop_table :admins_sources
  end
end
