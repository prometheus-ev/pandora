class ChangeDescDirectionValueForUploadSettings < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      UPDATE settings
        SET direction = 'DESC'
        WHERE type = 'UploadSettings' AND direction = 'D';
    SQL
  end
end
