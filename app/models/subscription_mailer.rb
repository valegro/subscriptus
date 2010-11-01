class SubscriptionMailer < ActionMailer::Base
  
  SEND_TO = nil
  
  # Note: Payment Method is written as Credit Card at the moment. FIXME if needed in the future.
  def activation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject        "Crikey Online Order #{subscription.order_num}"
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
end
