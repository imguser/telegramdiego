class ChannelAccess < ApplicationRecord
  belongs_to :registered_user
  belongs_to :channel

  validates_presence_of :channel_id, :registered_user_id
  validates_uniqueness_of :channel_id, scope: :registered_user

  scope :banned, -> {where(banned: true)}
  scope :active, -> {where(banned: false)}

  def self.for(channel, user)
    find_or_create_by(channel_id: channel.id, registered_user_id: user.id)
  end

  def update_access(user, channel, force: false)
    reason = self.ban_reason(user, channel)
    return banned? if !reason && unban!(force: force)
    return banned? if reason && ban!(reason, force: force)
  end

  def ban!(reason, force: false)
    _success, _e = with_telegram :kick do
      Telegram.bot.kick_chat_member chat_id: channel.chat_id, user_id: registered_user.telegram_id
    end if !banned? || force

    reasons = self.reasons
    last_reason = reasons.try(:[], 0).try(:split, " - ", 3).try(:[], 2)
    reasons.unshift("#{Time.now.utc} - BANNED - #{reason}") if reason != last_reason
    update_attributes(banned: true, reasons: reasons)
    banned?
  end

  def unban!(force: false)
    success, _e = with_telegram :unban do
      Telegram.bot.unban_chat_member chat_id: channel.chat_id, user_id: registered_user.telegram_id
    end if !unbanned? || force
    reasons = self.reasons
    
    last_action = reasons.try(:[], 0).try(:split, " - ", 3).try(:[], 1)
    reasons.unshift("#{Time.now.utc} - ACTIVATED") if last_action != 'ACTIVATED'
    update_attributes(banned: false, reasons: reasons)
    unbanned?
  end

  def restrict!
    success, _e = with_telegram :unban do
      Telegram.bot.restrict_chat_member chat_id: chat_id, user_id: registered_user.telegram_id,
      can_send_messages: false, can_send_media_messages: false, can_send_other_messages: false,
      can_add_web_page_previews: false
    end
    update_attributes restricted: true if success
    success
  end

  def unbanned?
    !banned?
  end

  protected

  def with_telegram(action)
    success, error = false, nil
    Rails.logger.warn "[#{action.to_s.upcase}] user: #{registered_user.to_s} from channel: #{channel.name}"
    begin
      yield
      success = true
    rescue Telegram::Bot::Error => e
      error = e
    end
    [success, error]
  end

  def ban_reason(user, channel)
    return "Invalid Access Details. Provided Email: '#{user.provided_email}'" if !self.valid_details
    return "SKU do not match. User: #{user.sku}, Channel: #{channel.valid_sku}" if !self.matching_sku
  end
end
