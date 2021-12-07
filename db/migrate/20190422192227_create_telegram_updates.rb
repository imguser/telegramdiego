class CreateTelegramUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :telegram_updates do |t|
      t.string :update_id, index: true, unique: true

      t.jsonb :payload
      t.text :content
      t.string :content_type

      t.boolean :pending, default: true
      t.boolean :success, default: false
      t.string :error_class
      t.string :error_message
      t.text :error_backtrace

      t.timestamps
    end
  end
end
