module TelegramWorkarounds
  extend ActiveSupport::Concern
  include Telegram::Bot::UpdatesController::MessageContext
  
  # Ignore stale chats.
  def process(*)
    super
  rescue Telegram::Bot::Forbidden
    logger.info { 'Reply failed due to stale chat.' }
  end

  # Telegram requires answer to any callback query, so if you just edit
  # the message user will still see spinner in the callback button.
  # This module makes #edit_message automatically answers callback queries
  # with same text.
  def edit_message(type, params = {})
    super
    if type == :text && params[:text] && payload_type == 'callback_query'
      answer_callback_query params[:text]
    end
  end

  # Telegram responds with error, if you edit message and new content
  # is same to current. This patch make it ignore this errors.
  def edit_message(type, params = {})
    super
  rescue Telegram::Bot::Error => e
    raise unless e.message.include?('message is not modified')
    logger.info { "Ignoring telegram error: #{e.message}" }
  end

  # Ingore errors that appears when user sends too much callback queries in a short
  # time period. Seems like telegram drops first queries before app is able to
  # answer them.
  def answer_callback_query(*)
    super
  rescue Telegram::Bot::Error => e
    raise unless e.message.include?('QUERY_ID_INVALID')
    logger.info { "Ignoring telegram error: #{e.message}" }
  end

  def action_for_message()
    val = message_context_session[:context]
    context = val && val.to_s
    result = super()
    return result unless result
    message_type = result[0][1][:type]
    command = result[0][1][:command]
    unless message_type == :command && command != 'cancel' && context
      return result
    end

    # save context again
    save_context(val)
    args = payload['text'].try!(:split) || []
    action = 'interruption'
    return [[action, type: :message_context, context: context], *args]
  end
end
