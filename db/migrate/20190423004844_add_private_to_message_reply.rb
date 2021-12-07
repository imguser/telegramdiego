class AddPrivateToMessageReply < ActiveRecord::Migration[5.2]
  def change
    add_column :message_replies, :private, :boolean, default: false
  end
end
