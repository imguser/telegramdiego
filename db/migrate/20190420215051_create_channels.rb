class CreateChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :channels do |t|
      t.string :chat_id, index: true
      t.string :name
      t.string :username, index: true
      t.string :invite_link, unique: true, index: true

      t.timestamps
    end
  end
end
