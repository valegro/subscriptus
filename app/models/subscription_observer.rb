class SubscriptionObserver < ActiveRecord::Observer
  def after_enter_trial(subscription)
   #  # CM::recipient.create (set expiry here too)
   #  # TODO: Put in Delayed Job
   #  # TODO: What if a user has multiple subscriptions - we may need to
   #  # set email address in CM as user+sid@example.com
   #  # OR use something other than email address as the PKEY
   #  # TODO: Check for errors
   # result = CM::Recipient.create!(
   #   :created_at => Time.now,
   #   :from_ip => '127.0.0.1',
   #   :email => subscription.user.email,
   #   :id => subscription.user.id,
   #   :last_modified_by => 'Subscriptus'
   # )
   # # TODO: Set expiry date
   # # TODO: Set state field
  end

  def before_enter_active(subscription)
     # CM::recipient.create (set expiry here too)
     # TODO: Put in Delayed Job
     # TODO: What if a user has multiple subscriptions - we may need to
     # set email address in CM as user+sid@example.com
     # OR use something other than email address as the PKEY
     # TODO: Check for errors
    # result = CM::Recipient.create!(
    #   :created_at => Time.now,
    #   :from_ip => '127.0.0.1',
    #   :email => subscription.user.email,
    #   :id => subscription.user.id,
    #   :last_modified_by => 'Subscriptus'
    # )
    # TODO: Set expiry date
    # TODO: Set state field
  end

  def after_update(subscription)
    #if subscription.expires_at_changed?
      # TODO: Update CM recipient expired at
      # TODO: Put in a delayed job
    #end
  end
end
