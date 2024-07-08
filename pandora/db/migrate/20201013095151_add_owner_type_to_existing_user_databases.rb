class AddOwnerTypeToExistingUserDatabases < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.transaction do
      Source.find_each do |source|
        if source.kind == "User database" && !source.owner_type
          source.update(owner_type: "Account")
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
