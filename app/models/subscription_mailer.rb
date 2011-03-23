class SubscriptionMailer < ActionMailer::Base
  
  SEND_TO = nil
  NO_REPLY = "noreply@crikey.com.au"
  
  # Note: Payment Method is written as Credit Card at the moment. FIXME if needed in the future.
  def activation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject        "Crikey Online Order #{subscription.reference}"
    from           SEND_TO
    body           :subscription => subscription
    content_type   'text/html'
  end

  def cancelation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject        "Crikey Online Cancelation"
    from           SEND_TO
    body           :subscription => subscription
    content_type   'text/html'
  end

  def new_trial(subscription)
    recipients subscription.user.email
    subject "New Trial Subscription"
    from NO_REPLY
    body :user => subscription.user
    content_type 'text/html'
  end
  
  def pending(subscription)
    recipients subscription.user.email
    subject "Your subscription is pending verification"
    from NO_REPLY
    body :subscription => subscription
    content_type 'text/html'
  end

  def pending_expired(subscription)
    recipients subscription.user.email
    subject "Your pending subscription has expired"
    from NO_REPLY
    body :subscription => subscription
    content_type 'text/html'
  end  

  def verified(subscription)
    recipients subscription.user.email
    subject "Your pending subscription has been verified"
    from NO_REPLY
    body :subscription => subscription
    content_type 'text/html'
  end
  
end
