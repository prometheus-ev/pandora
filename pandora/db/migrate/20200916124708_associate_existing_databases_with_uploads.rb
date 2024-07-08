class AssociateExistingDatabasesWithUploads < ActiveRecord::Migration[5.2]
  def change # upload.image.source is now redundant
    ActiveRecord::Base.transaction do
      Upload.find_each do |upload|
        if !upload.database
          if upload.image && (database = upload.image.source)
            upload.update(database: database)
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
