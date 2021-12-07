class CreateRegisteredUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :registered_users do |t|
      t.string :external_id, index: true
      t.string :telegram_id, unique: true, index: true
      t.string :username, unique: true, index: true
      t.string :first_name
      t.string :last_name
      t.string :language_code, default: 'en'
      t.jsonb :external_response, default: {}
      t.string :provided_email
      t.boolean :verified, default: false

      t.timestamps
    end
  end
end
