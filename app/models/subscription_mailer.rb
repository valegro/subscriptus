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
    from           NO_REPLY
    body           :subscription => subscription, :user => subscription.user
    content_type   'text/html'
  end

  def cancelation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject        "Crikey Online Cancelation"
    from           NO_REPLY
    body           :subscription => subscription, :user => subscription.user
    content_type   'text/html'
  end

  def new_trial(subscription)
    recipients subscription.user.email
    subject "New Trial Subscription"
    from NO_REPLY
    body :user => subscription.user, :password => subscription.temp_password, :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id)
    content_type 'text/html'
  end
  
  def pending_student_verification(subscription)
    recipients subscription.user.email
    subject "Your subscription is pending verification"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user
    content_type 'text/html'
  end

  def pending_concession_verification(subscription)
    recipients subscription.user.email
    subject "Your subscription is pending verification"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user
    content_type 'text/html'
  end

  def pending_payment(subscription)
    recipients subscription.user.email
    subject "Your subscription is pending payment"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user
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
    body :subscription => subscription, :user => subscription.user
    content_type 'text/html'
  end

  def expired(subscription)
    recipients subscription.user.email
    subject "Your subscription has expired"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user
    content_type 'text/html'
  end
  
  def suspended(subscription)
    recipients subscription.user.email
    subject "Your subscription has been suspended"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user
    content_type 'text/html'
  end

  def unsuspended(subscription)
    recipients subscription.user.email
    subject "Your subscription has been reactivated"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user
    content_type 'text/html'
  end
  
  def render_message(template, body)
    liquid_template_path = File.join('public', 'templates', 'crikey')
    Liquid::Template.file_system = Liquid::LocalFileSystem.new(liquid_template_path)
    liquid_template = File.join(mailer_name, template)
    
    unless File.exists?(Liquid::Template.file_system.full_path(liquid_template))
      super
    else
      Liquid::Template.parse(Liquid::Template.file_system.read_template_file(liquid_template)).render(HashWithIndifferentAccess.new(body).to_hash)
    end
  end
end
