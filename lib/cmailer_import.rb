
require 'cmailer_records'

# Clear Out Data
#Subscription.delete_all
#SubscriptionAction.delete_all
#SubscriptionLogEntry.delete_all
#User.delete_all("role = 'subscriber'")

errors = 0

CmailerUser.find(:all).each do |cm_user|
  begin
    cm_user.save_to_subscriptus
  rescue
    puts $!
    puts $!.backtrace
    p cm_user.attributes
    errors += 1
  end
end

puts "\n\n---------------"
puts "Errors: #{errors}"


__END__

errors = 0
CmailerSubscription.find(:all, :limit => 20).each do |cm_subscription|  #find_each(:batch_size => 100) do |cm_subscription|
  begin
    CmailerUser.transaction do
      cm_user = CmailerUser.find(cm_subscription.ContactId)
      user = cm_user.save_to_subscriptus
      cm_subscription.save_to_subscriptus(user)
    end
  rescue
    puts "\n\nError #{$!}"
    puts "#{$!.backtrace}"
    puts "--------"
    begin
      puts "Subscription attrs = #{cm_subscription.attributes.inspect}"
    rescue
      puts "JSON Failed"
      puts "Raw is: #{cm_subscription.subscriptions}"
    end
    #puts "User attrs = #{cm_user.try(:attributes)}"
    puts "--------"
    errors += 1
  end
end

puts "Errors: #{errors}"

# TODO: INdex subscriptions and users
# TODO: Ensure we are using InnoDB

# Merge phone_number, workphone
# Add mobile?
# login?
# How do we link to WP?
