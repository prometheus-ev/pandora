class RemoveEncodingPrometheusAndSkipFromSources < ActiveRecord::Migration[5.2]
  def change
    remove_column :sources, :encoding, :string, default: 'utf-8'
    remove_column :sources, :prometheus, :boolean, default: false
    remove_column :sources, :skip, :boolean, default: false
  end
end
