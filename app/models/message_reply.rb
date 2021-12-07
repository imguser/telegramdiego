class MessageReply < ApplicationRecord
  attr_accessor :payload
  validates :name, uniqueness: true, presence: true

  TELEGRAM_METHODS = {
    group: 'joined_group',
    username: "@telegram_username",
    available_invite_list: "- [channel](https://t.me/channel)",
    changes: "[channel1](https://t.me/channel1) - activated.\r\n[channel2](https://t.me/channel2) - banned."
  }

  def snippets
    available_snippets.
    merge("related_link" => related_link).
    merge(telegram_snippets).
    merge(channel_snippets).
    merge(channels_snippet).
    merge(GlobalSnippet.available).
    stringify_keys
  end

  def telegram_snippets
    available = TELEGRAM_METHODS.select{|k| respond_to?(k, true)}
    available.map{|k,v| [k, has_payload? ? safe_try(k) : "#{v}"]}.to_h
  end

  def channel_snippets
    # TDOO: remove this function

    user = RegisteredUser.find_by(telegram_id: payload["from"]["id"]) rescue nil
    channels = user && user.verified? ? user.available_channels.pluck(:id) : []
    Channel.pluck(:id, :name, :invite_link).map do |ch|
      ["channel_#{ch[0]}", channels.include?(ch[0]) ? "[#{ch[1]}](#{ch[2]})" : "#{ch[1]} - No access."]
    end.to_h
  end

  def channels_snippet
    user = RegisteredUser.find_by(telegram_id: payload["from"]["id"]) rescue nil
    channels = user && user.verified? ? user.available_channels : []
    channels = channels.map { |ch| "- [#{ch.name}](#{ch.invite_link})" }

    channels = channels.join("\n")
    return { 'channels' => channels }
  end

  def parsed_content
    return "" if content.blank?
    message = content % snippets.symbolize_keys
    {valid: true, content: message}
  rescue KeyError => e
    {valid: false, content: "ERROR: #{e.message}" }
  end

  def parsed_html_content
    response = parsed_content
    return "<strong style='color: red'>#{response[:content]}<br/>Reply will not be sent.</strong>" unless response[:valid]

    response[:content] = response[:content].split(/\r+\n+/).join("<br/>")
    if use_markdown?
      extensions = {no_intra_emphasis: true, tables: true, autolink: true}
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions)
      response[:content] = markdown.render(response[:content])
    end
    response[:content].html_safe
  end

  def with_payload(payload, &block)
    @payload = payload
    block.arity > 0 ? yield(self) : instance_eval(&block)
  ensure
    @payload = nil
  end

  def has_payload?
    @payload.present?
  end

  protected

  def username
    username = payload.dig("from", "username") rescue nil
    "@#{username}" if username.present?
  end

  def group
    id = payload.dig(:chat, :id).to_s rescue nil
    name = payload.dig(:chat, :title).to_s rescue nil
    invite_link = payload.dig(:chat, :invite_link).to_s rescue nil

    channel = Channel.find_by(chat_id: id)
    name, invite_link = channel.name, channel.invite_link if channel

    invite_link.present? ? "[#{name}](#{invite_link})" : name
  end

  def available_invite_list
    return Channel.none if payload['from'].blank?
    user = RegisteredUser.find_by(telegram_id: payload["from"]["id"])
    channels = user && user.verified? ? user.available_channels : Channel.none
    "- " + channels.map{|ch| "[#{ch.name}](#{ch.invite_link})"}.join("\r\n- ")
  end

  private

  def safe_try(method)
    send(method)
  rescue StandardError => e
    puts "#{e.class}: #{e.message}"
  end
end
