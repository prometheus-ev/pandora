class RemoveGlobalizeTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :globalize_languages
    drop_table :globalize_countries
    drop_table :globalize_translations
  end
end
