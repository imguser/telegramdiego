class CheckWorker
  include Sidekiq::Worker

  def perform()
    # find all members for all channels
    users = Channel.all.map{ |channel| channel.get_participants }.flatten(1).uniq

    # find channel members that are not registered
    reg = RegisteredUser.pluck(:telegram_id)
    unregistered = users.reject{|u| reg.include?(u["id"].to_s)}

    # find channel members that are already registered and update access_hash for them
    without_access_hash = RegisteredUser.where(access_hash: nil).pluck(:telegram_id)
    users.each do |user|
        next unless without_access_hash.include?(user['id'].to_s)
        RegisteredUser.where(telegram_id: user['id']).update_all access_hash: user['access_hash']
    end

    # register and send all these unregistered users a warning
    mr = MessageReply.find_by!(name: "/start:group")
    company = GlobalSnippet.find_by(name: 'company').value
    reply = mr.content % {company: company}
    unregistered.each do |user|
        user, _, _ = RegisteredUser.create_via_telegram(user)
        user.send_message(reply) if user
    end
  end
end