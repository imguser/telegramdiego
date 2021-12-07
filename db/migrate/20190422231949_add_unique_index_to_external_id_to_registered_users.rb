class AddUniqueIndexToExternalIdToRegisteredUsers < ActiveRecord::Migration[5.2]
  def up
    remove_index :registered_users, :external_id
    add_index :registered_users, :external_id, unique: true
  end

  def down
    remove_index :registered_users, :external_id
    add_index :registered_users, :external_id
  end
end
