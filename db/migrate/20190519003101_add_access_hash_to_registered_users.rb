class AddAccessHashToRegisteredUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :registered_users, :access_hash, :string
  end
end
