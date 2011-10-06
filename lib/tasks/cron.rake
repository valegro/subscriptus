desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  puts "Expiring states..."
  Subscription.expire_states
  puts "done."

  puts "Processing scheduled suspensions..."
  ScheduledSuspension.process!
  puts "done."
end
