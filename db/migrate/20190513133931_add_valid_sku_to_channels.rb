class AddValidSkuToChannels < ActiveRecord::Migration[5.2]
  def up
    add_column :channels, :valid_sku, :text, array: true, default: []

    valid_sku = ENV['VALID_SKU'].split(/\s*,\*/)
    Channel.update_all valid_sku: valid_sku
  end

  def down
    remove_column :channels, :valid_sku
  end
end
