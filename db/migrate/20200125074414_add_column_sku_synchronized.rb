class AddColumnSkuSynchronized < ActiveRecord::Migration[5.2]
  def up
    add_column :registered_users, :date_sku_syncrhonized, :datetime
  end

  def down
    remove_column :registered_users, :date_sku_syncrhonized
  end
end
