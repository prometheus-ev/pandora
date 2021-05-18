class ChangeSourcesTypeColumnFromStringToInteger < ActiveRecord::Migration[5.2]
  def up
    execute "UPDATE sources SET type = 1 where kind = 'User database'"
    execute "UPDATE sources SET type = 0 where kind != 'User database'"

    change_column :sources, :type, :integer, using: 'type::integer', default: 0
  end

  def down
    change_column :sources, :type, :string, using: 'type::string', default: 'dump'

    execute "UPDATE sources SET type = 'upload' where kind = 'User database'"
    execute "UPDATE sources SET type = 'dump' where kind != 'User database'"
  end
end
