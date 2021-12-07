class BanWorker
  include Sidekiq::Worker
  # Update SKU of users syncronized more than day ago
  # and verify changes in in channel's and user's SKU. 

  def perform()
    query = (
      "sku_synchronized_at <= ? 
      OR sku_synchronized_at IS NULL 
      AND verified IS TRUE"
    )
    RegisteredUser.where(query, 1.days.ago).each do |user|
      begin
        user.update_sku()
        user.update_channel_access()
      rescue
          puts "Runtime error on user ban"
      end
    end
  end
end