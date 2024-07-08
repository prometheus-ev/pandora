class ChangeBoxesParamsImagesControllerName < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        # change controller name for ImagesController after refactoring
        execute <<-SQL
          UPDATE boxes
            SET params = REPLACE(params, 'controller: image', 'controller: images');
        SQL
      end
      dir.down do
        # change controller name for ImageController before refactoring
        execute <<-SQL
          UPDATE boxes
            SET params = REPLACE(params, 'controller: images', 'controller: image');
        SQL
      end
    end
  end
end
