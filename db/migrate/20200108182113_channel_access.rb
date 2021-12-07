class ChannelAccess < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :channel_accesses, :registered_users
    add_foreign_key :channel_accesses, :registered_users, on_delete: :cascade
  end

  def down
    remove_foreign_key :channel_accesses, :registered_users
    add_foreign_key :channel_accesses, :registered_users
  end
end
