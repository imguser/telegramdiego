class TelegramUpdate < ApplicationRecord
  scope :failed, -> {where(pending: false, success: false)}
  scope :successful, -> {where(pending: false, success: true)}
  scope :pending, -> {where(pending: true)}

  def set_error_and_response(e, r)
    if e.present?
      update_attributes success: false, error_class: e.class, pending: false,
        error_message: e.message, error_backtrace: e.backtrace.join("\n"),
        response: r
    else
      update_attributes success: true, error_class: nil, response: r,
        error_message: nil, error_backtrace: nil, pending: false
    end
  end

  def set_payload(payload)
    self.payload = payload
    self.content_type = payload.keys.detect{|k| payload[k].is_a?(Hash) && payload[k].present? }
    self.content = payload[self.content_type].try(:[], "text")
    return if self.content.present?

    left = has_left?(payload, self.content_type)
    self.content = "-- left: #{left} --" if left.present?

    joined = has_joined?(payload, self.content_type)
    self.content = "-- joined: #{joined} --" if joined && self.content.blank?
  end

  def has_left?(payload, content_type)
    payload.dig(content_type, 'left_chat_member', 'id')
  rescue
  end

  def has_joined?(payload, content_type)
    payload.dig(content_type, 'new_chat_member', 'id')
  rescue
  end

  def success?
    !pending? && super
  end

  def failed?
    !pending? && !success?
  end
end
