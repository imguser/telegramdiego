class CreateChannelAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :channel_accesses do |t|
      t.references :registered_user, foreign_key: true, null: false
      t.references :channel, foreign_key: true, null: false
      t.boolean :valid_details, default: false
      t.boolean :matching_sku, default: false
      t.boolean :restricted, default: false
      t.boolean :banned, default: false
      t.text :reasons, array: true, default: ['ACTIVE (NEW RECORD)']

      t.timestamps
    end
  end
end
