class TelegramController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include TelegramWorkarounds

  before_action :verify_from

  class << self
    def dispatch(bot, update)
      id = update["update_id"]
      return if TelegramUpdate.where(update_id: id).exists?
      record = TelegramUpdate.new(update_id: id, pending: true)
      record.set_payload(update.to_hash)
      record.save

      error = begin
                super
                nil
              rescue StandardError => e
                e
              end

      result = update.to_hash.detect{|k,v| v.is_a?(Hash) && v.key?("response")}
      result = result.present? ? result[1]['response'].join("\n-------\n") : nil
      record.set_error_and_response(error, result)
    end
  end

  def start!(data=nil, *)
    user, action, success = RegisteredUser.create_via_telegram(from)
    case
    when @invalid
      respond_with_message_reply('/start:failed:group')
    when user && user.verified?
      respond_with_message_reply('interview:finish')
      on_verification_success(user)
    when user && action != :new
      save_context :interview_finish
      respond_with_message_reply('interview:step1:short')
    when user && action == :new
      save_context :interview_finish
      respond_with_message_reply('interview:step1')
    else
      respond_with_message_reply('/start:failed')
    end
  end

  def verify!(*)
    user, _, _ = RegisteredUser.create_via_telegram(from)
    return unless user
  
    user.update_attributes(
      external_id: nil,
      provided_email: nil,
      external_response: nil,
      verified: false,
      sku: [],
      sku_synchronized_at: nil,
    )
    user.remove_channels_access()

    case
    when @invalid
      respond_with_message_reply('/start:failed:group')
    when user
      save_context :interview_finish
      respond_with_message_reply('/start')
    else
      respond_with_message_reply('/start:failed')
    end
  end

  def list!(*)
    user, _, _ = RegisteredUser.create_via_telegram(from)
    if @invalid
      respond_with_message_reply('/start:failed:group')
    elsif user && user.verified? && user.available_channels.any?
      respond_with_message_reply('verification:successful')
    elsif user && user.verified?
      respond_with_message_reply('verification:successful:no_channel')
    else
      respond_with_message_reply('verification:failure')
    end
  end

  def cancel!(*)
    respond_with_message_reply('/cancel') unless @invalid
  end

  def help!(*)
    respond_with_message_reply('/help') unless @invalid
  end

  # match user information and set active status
  def interview_finish(*words)
    user, _, _ = RegisteredUser.create_via_telegram(from)
    return unless user
    provided_username = words[0].to_s.strip.downcase

   if RegisteredUser.where(username: provided_username).exists?
      respond_with_message_reply("interview:finish:exists")
      return
    end
    info = user.get_info(username,'username')

    user.update_attributes(
      username: provided_username,
      verified: !!info,
      external_response: { "external_id": info["mlm_unique_id"] },
    )
    if !!info
      respond_with_message_reply("interview:finish:success")
      on_verification_success(user)
    else
      respond_with_message_reply("interview:finish:failed")
      respond_with_message_reply("verification:failure")
    end
  end

  def interruption(*words)
    respond_with_message_reply('interruption')
  end

  def message(message)
    if message["left_chat_member"].present?
      user_removed_from_chat(message["left_chat_member"], message)
    elsif message["new_chat_members"].present?
      message["new_chat_members"].each do |user|
        user_added_to_chat(user, message)
      end
    end
    # return if message['text'].blank?
    # respond_with_message_reply('/help:short') unless @invalid
  end
  alias :channel_post :message

  def on_verification_success(user)
    return unless user
    user.update_sku()
    user.create_channel_access()

    if user.available_channels.any?
      respond_with_message_reply('verification:successful')
    else
      respond_with_message_reply('verification:successful:no_channel')
    end
  end

  protected

  def verify_from
    @invalid = from.blank? && chat.present?
  end

  def user_removed_from_chat(user, message)
    # add user to our registered user list for reference later
    user = RegisteredUser.create_via_telegram(user)

    payload['response'] ||= []
    payload['response'].push "user saved: #{user['id']}" if user.present?
  end

  def user_added_to_chat(user, message)
    # add user to our registered user list for reference later
    user, _, _ = RegisteredUser.create_via_telegram(user)
    Channel.all.each do |channel|
      access = ChannelAccess.for(channel, user)
      access.restrict! if user.present?
    end

    # ask user to authenticate themselves in private
    respond_with_message_reply('/start:group') if user && !user.verified?

    payload['response'] ||= []
    payload['response'].push "user added and restricted: #{user['id']}" if user.present?
  end

  private

  def respond_with_message_reply(name)
    mr = MessageReply.find_by!(name: name)
    return if mr.blank?

    reply = mr.with_payload(payload){ parsed_content }
    puts(reply)
    puts(reply[:valid] && reply[:content].present?)
    return unless reply[:valid] && reply[:content].present?
    options = {text: reply[:content]}
    options = options.merge(parse_mode: :Markdown) if mr.use_markdown?

    if mr.private?
      user = payload.to_hash.dig('from', 'id') rescue nil
      bot.send_message options.merge(chat_id: user)
    else
      command = mr.quote_message? ? :reply_with : :respond_with
      send command, :message, options
    end

    payload['response'] ||= []
    payload['response'].push options[:text]
  end

  # In this case session will persist for user only in specific chat.
  # Same user in other chat will have different session.
  def session_key
    "#{bot.username}:#{chat['id']}:#{from['id']}" if chat && from
  end
end
