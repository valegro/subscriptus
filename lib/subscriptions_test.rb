require 'cmailer_records'

# Does the user have a subscription with state = active or state = trial and expiry > now?
# Yes, just one: make this the active sub
# Yes, two: merge these into the active sub
# No: Use the most recently created subscription as the sub
#
# Every cmailer subscription should create an action

@@count = { 0 => 0, 1 => 0, '2 (active-active)' => 0, '2 (other)' => [] }

def process_subs_for_user(user, subs, cm_user = nil)
  active_in_progress = subs.select { |s| !s.expires_at.nil? && s.expires_at > Time.now && %(active trial).include?(s.state) }

  if active_in_progress.size == 0
    @@count[0] += 1
    begin
      most_recently_created = subs.max { |a,b| (a.created_at || a.expires_at) <=> (b.created_at || b.expires_at) }
      most_recently_created.save_to_subscriptus(user)
    rescue
      puts $!
      p subs
      exit
    end
    #
  elsif active_in_progress.size == 1
    @@count[1] += 1
    active_in_progress.last.save_to_subscriptus(user)
  else
    first, last = active_in_progress
    if first.state == 'active' && last.state == 'active'
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
      # TODO: Two actions here
    else
      @@count['2 (other)'] << "#{cm_user.id}: #{first.state}:#{last.state}"
    end
    # TODO: Other state combinations
  end
  # TODO: Handle ALL the actions
end

User.delete_all "role = 'subscriber'"
Subscription.connection.execute("delete from subscriptions")
SubscriptionAction.delete_all
SubscriptionLogEntry.delete_all

CmailerUser.find(:all, :limit => 5000).each do |u|
  begin
    User.transaction do
      user = u.save_to_subscriptus
      u.subscriptions.by_publication.each do |publication, subs|
        if publication.blank? || publication.name.blank?
          # TODO: Work out what to do here!
        else
          puts "Processing #{publication.name}"
          process_subs_for_user(user, subs, u)
        end
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    puts $!
    puts e.record.inspect
  end
end

p @@count

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



