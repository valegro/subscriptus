require 'cmailer_records'


require 'ruby-prof'

# Ignore DJ
class Object
  def delay(*args)
    # Do nothing
    mock('delay')
  end
end

# Does the user have a subscription with state = active or state = trial and expiry > now?
# Yes, just one: make this the active sub
# Yes, two: merge these into the active sub
# No: Use the most recently created subscription as the sub
#
# Every cmailer subscription should create an action

@@count = { 0 => 0, 1 => 0, '2 (active-active)' => 0, '2 (other)' => [] }

def process_subs_for_user(user, subs, cm_user = nil)
  active_in_progress = subs.select { |s| !s.expires_at.nil? && s.expires_at > Time.now && %w(active trial).include?(s.state) }

  if active_in_progress.size == 0
    @@count[0] += 1
    # Set the status to the status of the most recent sub
    # Set the start end dates to that of any subs that were active but now have an expires_at that has passed
    # If no subs match this critera then just use the latest sub

    # Weekender subs don't always have start and end dates - need to treat nil like infinity for end date and created_at is ignored
    ordered_by_expires_at = subs.sort do |a, b|
      if a.expires_at.blank? && !b.expires_at.blank?
        1
      elsif !a.expires_at.blank? && b.expires_at.blank?
        -1
      elsif a.expires_at.blank? && b.expires_at.blank?
        0
      else
        a.expires_at <=> b.expires_at
      end
    end
    unless ordered_by_expires_at.empty?
      most_recent = ordered_by_expires_at.last
      # Use the most recent state
      state = most_recent.state
      # See if there is an active sub in order to set expires_at and created_at
      active_or_trial = ordered_by_expires_at.detect { |o| %w(active trial).include?(o.state) }
      # If most_recently_created is not active then find the most recent active
      if active_or_trial
        most_recent.created_at = active_or_trial.created_at
        most_recent.expires_at = active_or_trial.expires_at
      end
      most_recent.save_to_subscriptus(user)
    end
  elsif active_in_progress.size == 1
    @@count[1] += 1
    active_in_progress.last.save_to_subscriptus(user)
  else
    first = active_in_progress.first
    last = active_in_progress.last
    @@count['2 (active-active)'] += 1
    user.subscriptions.create!(
      :created_at => first.created_at,
      :expires_at => last.expires_at,
      :user          => user,
      :state         => 'active',
      :price         => last.price,
      :offer         => last.offer,
      :publication   => last.publication
    )
    # TODO: Other state combinations
  end
  # TODO: Handle ALL the actions
end

if RAILS_ENV = 'development'
  User.delete_all "role = 'subscriber'"
  Subscription.connection.execute("delete from subscriptions")
  SubscriptionAction.delete_all
  SubscriptionLogEntry.delete_all
end

logger = Logger.new("import-results.log")

ignored = 0

logger.warn("Starting import at #{Time.now}")

#RubyProf.start

start_time = Time.now

CmailerUser.find_each(:include => [:subscriptions, :address]) do |u|
  # puts u.email
  begin
    Rails.logger.silence do
      User.transaction do
        user = u.save_to_subscriptus
        u.subscriptions.by_publication.each do |publication, subs|
          if publication.blank?
            # We should just ignore the sub if there is no publication (count it though)
            ignored += 1
          else
            process_subs_for_user(user, subs, u)
          end
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    logger.warn("------------------")
    logger.warn($!)
    logger.warn($!.backtrace)
    logger.warn(u.inspect)
    logger.warn(e.record.inspect)
  rescue
    logger.warn("------------------")
    logger.warn($!)
    logger.warn($!.backtrace)
    logger.warn(u.inspect)
  end
end

logger.warn(@@count.inspect)
logger.warn("#{ignored} subscriptions were ignored because they had no publication")
logger.warn("Finished at #{Time.now}")

end_time = Time.now

puts
puts
puts "#{(end_time - start_time)} seconds"
puts
puts
puts

=begin

result = RubyProf.stop

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)

puts "\n\n------------------------------\n\n"

printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, 0)

=end

# Have subscriptions that have not expired?
# Just one? then use this as the current subscription with whatever state it has
# Two? They shouldn't be the same state so establish an ordering that determines which state we should use
#  - both active? combine them into one (future subscriptions)
#  - Not both active? Use the one with the most recent expiry_date
#  - What about pending?
# None? Use the most recent one and apply the status from that
# - Check created_at (order by this and get the most recently created) then check state
#
#
#
# SO what states can we get?
#
# TRIAL
# Active
# Squatter
# Unsubscribed
# Suspended
# Pending



