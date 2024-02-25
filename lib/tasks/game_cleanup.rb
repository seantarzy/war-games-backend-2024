# lib/tasks/session_cleanup.rake

namespace :games do
    desc "Remove games (and sessions) older than 3 days"
    task cleanup: :environment do
      Game.where('created_at < ?', 3.days.ago).destroy_all
      puts "Old Games removed"
    end
  end
  