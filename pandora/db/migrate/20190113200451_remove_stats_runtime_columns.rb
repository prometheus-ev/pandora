class RemoveStatsRuntimeColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :sum_stats, :runtime_sum
    remove_column :sum_stats, :runtime_sqr
    remove_column :sum_stats, :runtime_min
    remove_column :sum_stats, :runtime_max
    remove_column :sum_stats, :runtime_count
  end
end
