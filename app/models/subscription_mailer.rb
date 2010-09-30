class SubscriptionMailer < ActionMailer::Base
  
  SEND_TO = nil
  
  def activation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject        'Crikey - Activated'
    from           SEND_TO
    body           :subscription => subscription
    content_type   'text/html'
  end
end
