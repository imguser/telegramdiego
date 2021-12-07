class RenameSkUsyncrhonized < ActiveRecord::Migration[5.2]
  def up
    add_column :registered_users, :sku_synchronized_at, :datetime
    remove_column :registered_users, :date_sku_syncrhonized
  end

  def down
    remove_column :registered_users, :sku_synchronized_at
    add_column :registered_users, :date_sku_syncrhonized, :datetime
  end
end
