class MakeAnnouncementsUseInnodb < ActiveRecord::Migration[5.2]
  def up
    execute 'ALTER TABLE announcements ORDER BY id'
    execute 'ALTER TABLE announcements ENGINE = INNODB'
  end

  def down
    execute 'ALTER TABLE announcements ORDER BY id'
    execute 'ALTER TABLE announcements ENGINE = MYISAM'
  end
end
