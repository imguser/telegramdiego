class RemoveUnverifiedWorker
  include Sidekiq::Worker

  def perform()
    RegisteredUser
      .where("verified = FALSE AND created_at <= ? ", 1.days.ago)
      .delete_all()
  end
end