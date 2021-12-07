require_relative '../../app/workers/ban_worker'
require_relative '../../app/workers/check_worker'
require_relative '../../app/workers/remove_unverified_worker'

namespace :user_manager do
  desc 'Check users for access to Private channels and ban/unban them.'
  task check: :environment do
    CheckWorker.perform_async()
  end

  task ban: :environment do
    BanWorker.perform_async()
  end

  task remove_unverified: :environment do
    RemoveUnverifiedWorker.perform_async()
  end
end
