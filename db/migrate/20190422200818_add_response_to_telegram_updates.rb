class AddResponseToTelegramUpdates < ActiveRecord::Migration[5.2]
  def change
    add_column :telegram_updates, :response, :text
  end
end
