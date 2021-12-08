class RegisteredUser < ApplicationRecord
  has_many :channel_accesses, dependent: :delete_all
  has_many :channels, through: :channel_accesses
  # banned: false,
  # matching_sku: true,
  # valid_details: true,
  has_many(
    :active_channels_access,
    -> { where(
        "banned = FALSE AND matching_sku = TRUE " \
        "AND valid_details = TRUE AND reasons[1] like '%ACTIVATED'"
    )},
    class_name: 'ChannelAccess'
  )
  has_many :active_channels, :through => :active_channels_access, class_name: 'Channel', :source => :channel

  # validates :username, presence: true, uniqueness: true
  validates :telegram_id, presence: true, uniqueness: true
  validates :external_id, uniqueness: true, allow_nil: true

  scope :verified, -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  def to_s
    username || id
  end

  def name
    username || id
  end

  def self.create_via_telegram(from)
    return [nil, nil, false] if from.blank? || from['is_bot']
    user = find_or_initialize_by(telegram_id: from["id"])
    fields = %w[first_name last_name language_code username access_hash]
    fields.each{|f| user[f] = from[f] if user[f].blank? && from.key?(f)}
    action = user.new_record? ? :new : user.changed? ? :updated : :none
    success = user.save unless action == :none
    puts user.errors.full_messages if user.errors.present?
    [user, action, false]
  rescue StandardError => e
    puts "#{e.class} #{e.message}"
    [nil, :failed, nil]
  end

  def available_channels
    Channel.where(id: channel_accesses.active.pluck(:channel_id))
  end

  def send_message(message)
    id = username.present? ? ['username', username, nil] : ['id', telegram_id, access_hash]
    sleep(1+rand)
    `python3 #{Rails.root.join('telethon', 'send_message.py')} #{id.join(" ")} "#{message}" 2>&1`
  end

 def get_info(user_provider, type)
    header = ENV["EXTERNAL_API_KEY"]
    body = {user: user_provider}.to_json
    response = HTTParty.post("https://www.ixacademy.us/afl/api/v1/get-user-details/", headers:{"apikey": header}, body: body )
    user = JSON.parse(response.body)["data"]
    return if user.nil?
    line_items = user["line_items"]
    return type == "sku" ? line_items : user["data"]
  end

  def update_sku()
    return unless self.username
    sku = get_sku(self.username, "sku")
    update_attributes(sku: sku, sku_synchronized_at: Time.now.utc)
  end

  def matching_sku?(channel)
    # Check that user have at least one common SKU with channel
    return !(channel.valid_sku & self.sku).empty?
  end

  def create_channel_access()
    Channel.all.each do |channel|
      # create access from every channel
      access = ChannelAccess.for(channel, self)

      # IF not common sku with channel and user, than user
      matching_sku = self.matching_sku?(channel)
      access.update_attributes(
        matching_sku: matching_sku,
        valid_details: self.verified,
      )

      # ban or unban user
      access.update_access(self, channel, force: true)
    end
  end

  def update_channel_access()
    changes = []
    # Check for every channel access changes
    Channel.all.each do |channel|
      access = ChannelAccess.for(channel, self)
      matching_sku = self.matching_sku?(channel)
      # If previous SKU match and current sku match 
      # changed than update user access to channel
      if access.matching_sku != matching_sku
        action = matching_sku ? 'activated' : 'banned'
        changes << "[#{channel.name}](#{channel.invite_link}) - #{action}"
        access.update_attributes(matching_sku: matching_sku, valid_details: self.verified)
        access.update_access(self, channel)
      end
    end
    # Send message to user if there are any changes
    return if changes.empty?
    mr = MessageReply.find_by!(name: "changes")
    company = GlobalSnippet.find_by(name: 'company').value
    reply = mr.content % {company: company, changes: changes.join("\r\n")}
    send_message(reply)
  end

  def ban_all_channels()
    reason = "#{Time.now.utc} - BANNED - Banned by administrators"
    ChannelAccess
      .where('registered_user_id = ?', id)
      .update_all(["banned = true, reasons = array_prepend(?, reasons)", reason])
  end

  def remove_channels_access()
    ChannelAccess
      .where('registered_user_id = ?', id)
      .delete_all()
  end

  def ban_channel(channel_id)
    reason = "#{Time.now.utc} - BANNED - Banned by administrators"
    ChannelAccess
      .where('registered_user_id = ? AND channel_id = ?', id, channel_id)
      .update_all(["banned = true, reasons = array_prepend(?, reasons)", reason])
  end

  def unban_channel(channel_id)
    reason = "#{Time.now.utc} - ACTIVATED"
    ChannelAccess
      .where('registered_user_id = ? AND channel_id = ?', id, channel_id)
      .update_all(["banned = false, reasons = array_prepend(?, reasons)", reason])
  end

  private
end
