class ExtendCreditsField < ActiveRecord::Migration[5.1]
  def change
    change_column :uploads, :credits, :text
  end
end
