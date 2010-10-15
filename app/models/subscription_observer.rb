class SubscriptionObserver < ActiveRecord::Observer
  def before_enter_pending(subscription)
    subscription.generate_and_set_order_number  # order_num is sent to the user as a reference number of their subscriptions
  end

  def before_enter_extension_pending(subscription)
    subscription.generate_and_set_order_number  # order_num is sent to the user as a reference number of their subscriptions
  end

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

  def after_enter_active(subscription)
    # send email to the user with their full subscription details
    # SubscriptionMailer.deliver_activation(subscription)
  end

  def after_update(record)
    record.send_later :update_campaignmaster
  end

  def before_create(record)
    record.publication_id = record.offer.publication_id
  end

  def after_create(record)
    record.send_later :update_campaignmaster
  end
end
