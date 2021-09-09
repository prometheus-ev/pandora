class CleanupIssue1035 < ActiveRecord::Migration[5.2]
  def change
    drop_table :ar_mails
    drop_table :change_sets
    drop_table :changes
    drop_table :discount_codes
    drop_table :invoices
    drop_table :accounts_groups
    drop_table :groups_permissions
    drop_table :accounts_permissions
    drop_table :ip_nets

    change_table :collections do |t|
      t.remove :parent_id
      t.remove :forked_at
    end

    change_table :boxes do |t|
      t.remove :presentation_id
      t.remove :params
      t.rename :type, :ref_type
    end

    change_table :comments do |t|
      t.remove :presentation_id
    end

    Box.find_each do |box|
      if ['images', 'ImageBox'].include?(box.ref_type)
        box.update_column :ref_type, 'image'
      end

      if ['collections', 'CollectionBox'].include?(box.ref_type)
        box.update_column :ref_type, 'collection'
      end
    end
  end
end
