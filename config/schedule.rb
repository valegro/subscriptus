# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "log/cron.log"

job_type :bundle_rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"

every 1.hour do
  bundle_rake "states:expire"
end

every 1.day do
  runner "ScheduledSuspension.process!"
end
