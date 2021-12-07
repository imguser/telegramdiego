class UpdateFieldsOnChannelsAndRegisteredUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :registered_users, :ban_counter, :integer, default: 0
    remove_column :channels, :access_hash, :integer, default: 0
    add_column :channels, :access_hash, :string
  end
end
