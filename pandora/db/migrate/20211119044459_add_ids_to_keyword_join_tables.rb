class AddIdsToKeywordJoinTables < ActiveRecord::Migration[5.2]
  def change
    change_table :collections_keywords do |t|
      t.primary_key :id
    end

    change_table :keywords_sources do |t|
      t.primary_key :id
    end

    change_table :keywords_uploads do |t|
      t.primary_key :id
    end
  end
end
