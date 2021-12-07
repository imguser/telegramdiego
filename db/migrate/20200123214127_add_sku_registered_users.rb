class AddSkuRegisteredUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :registered_users, :sku, :text, array: true, default: []
  end

  def down
    remove_column :registered_users, :sku
  end
end
