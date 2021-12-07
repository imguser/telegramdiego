class Channel < ApplicationRecord
  has_many :channel_accesses, dependent: :delete_all
  has_many :registered_users, through: :channel_accesses

  before_validation :create_telegram_channel
  validates :name, uniqueness: true, presence: true
  validates :chat_id, uniqueness: true, presence: true
  after_create :send_message_to_group
  before_destroy :delete_telegram_channel

  scope :with_chat_id, -> { where.not(chat_id: nil) }

  def link
    "https://t.me/#{username}" if username.present?
  end

  def missing_info?
    chat_id.blank? || name.blank? || invite_link.blank?
  end

  def valid_sku=(val)
    val.is_a?(String) ? super(val.split(/\s*,\s*/).map(&:to_i)) : super
  end

  def get_participants
    response = `python3 #{Rails.root.join('telethon', 'get_participants.py')} #{chat_id} #{access_hash} #{invite_link} 2>&1`
    response = JSON.parse(response.strip)
    update_attributes(access_hash: response["access_hash"]) if access_hash.blank?
    return response["users"]
  rescue => e
    puts(e)
    puts(response)
    return []
  end

  private

  def create_telegram_channel
    return if self.name.blank? && self.chat_id.blank?
    return if self.class.where(name: name.strip).exists?

    if self.chat_id.blank?
      response = `python3 #{Rails.root.join('telethon', 'create_channel.py')} #{name} #{ENV['TELEGRAM_BOT_USERNAME']} 2>&1`
      data = JSON.parse(response.strip) rescue nil
      if data.nil?
        errors.add(:base, response.to_s.strip)
      else
        self.chat_id = data['id'] if data['id']
      end
      return if self.chat_id.blank?
    end

    begin
      Telegram.bot.export_chat_invite_link chat_id: chat_id
    rescue Telegram::Bot::Error => e
    end

    begin
      info = Telegram.bot.get_chat chat_id: chat_id
      self.chat_id = info["id"]
      self.name = info["title"]
      self.invite_link = info["invite_link"] || self.link
    rescue Telegram::Bot::Error => e
      self.name = nil
    end

    if self.name.blank?
      errors.add(:chat_id, 'Seems like I could not find that chat.')
    end
  end

  def delete_telegram_channel
    return if self.name.blank?
    `python3 #{Rails.root.join('telethon', 'delete_channel.py')} #{name} 2>&1`
  end

  def send_message_to_group
    Telegram.bot.send_message chat_id: chat_id, text: "This chat has been added to @#{ENV['TELEGRAM_BOT_USERNAME']}."
  rescue Telegram::Bot::Error
  end
end
