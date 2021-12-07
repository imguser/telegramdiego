class RemoveUniqueUsernameFromRegisteredUsers < ActiveRecord::Migration[5.2]
  def up
    remove_index :registered_users, :username
    add_index :registered_users, :username
  end

  def down
    remove_index :registered_users, :username
    add_index :registered_users, :username, unique: true
  end
end
