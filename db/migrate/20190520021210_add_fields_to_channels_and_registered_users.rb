class AddFieldsToChannelsAndRegisteredUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :channels, :access_hash, :integer, default: 0
    add_column :registered_users, :ban_counter, :integer, default: 0
  end
end
