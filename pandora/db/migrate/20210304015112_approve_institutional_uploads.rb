class ApproveInstitutionalUploads < ActiveRecord::Migration[5.2]
  def up
    Upload.find_each do |upload|
      if upload.institutional?
        upload.update_column :approved_record, true
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
