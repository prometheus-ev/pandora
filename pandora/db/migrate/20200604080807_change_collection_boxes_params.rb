class ChangeCollectionBoxesParams < ActiveRecord::Migration[5.2]
  def change

    reversible do |dir|
      dir.up do
        # change params name for CollectionBox after refactoring
        execute <<-SQL
          UPDATE boxes
            SET params = REPLACE(params, 'controller: collection', 'controller: collections'),
              params = REPLACE(params, 'action: edit', 'action: show')
            WHERE type = 'CollectionBox';
        SQL
      end
      dir.down do
        # change params for CollectionBox before refactoring
        execute <<-SQL
          UPDATE boxes
            SET params = REPLACE(params, 'controller: collections', 'controller: collection'),
              params = REPLACE(params, 'action: show', 'action: edit')
            WHERE type = 'CollectionBox';
        SQL
      end
    end

  end
end
