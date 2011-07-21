class SubscriptionMailer < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  include SubscriptionMailerHelper
  
  SEND_TO = nil
  NO_REPLY = "noreply@crikey.com.au"
  
  # Note: Payment Method is written as Credit Card at the moment. FIXME if needed in the future.
  def activation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject(publication_subject(subscription, "Online Order #{subscription.reference}"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
                     :order_date => subscription.updated_at.try(:strftime, "%d/%m/%Y"),
                     :gifts => subscription.try(:actions).try(:first).try(:gifts),
                     :has_gifts => (!subscription.actions.empty? && !subscription.actions.first.gifts.blank?),
                     :cost => number_to_currency(subscription.try(:actions).try(:first).try(:payment).try(:amount), :unit => "AUD $"),
                     :gst => number_to_currency(subscription.try(:actions).try(:first).try(:payment).try(:amount).try(:/, 11.0))
                   )
    content_type   'text/html'
  end

  def cancelation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject(publication_subject(subscription, "Online Cancelation"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
                     :squatter => subscription.state == :squatter,
                     :gifts => subscription.try(:offer).try(:gifts)
                   )
    content_type   'text/html'
  end

  def new_trial(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "New Trial Subscription"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription, :password => subscription.temp_password)
    content_type 'text/html'
  end
  
  def pending_student_verification(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "Your subscription is pending verification"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
           :creation_date => subscription.created_at.try(:strftime, "%d/%m/%Y")
         )
    content_type 'text/html'
  end

  def pending_concession_verification(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "Your subscription is pending verification"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
           :creation_date => subscription.created_at.try(:strftime, "%d/%m/%Y")
         )
    content_type 'text/html'
  end

  def pending_payment(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "Your subscription is pending payment"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
           :subscription_date => subscription.created_at.strftime("%d/%m/%Y")
         )
    content_type 'text/html'
  end

  def pending_expired(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "Your pending subscription has expired"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription)
    content_type 'text/html'
  end  

  def verified(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "Your pending subscription has been verified"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
           :forgot_password_url => subscription.publication.forgot_password_link,
           :subscription_starts => subscription.state_updated_at.try(:strftime, "%d/%m/%Y"),
           :subscription_ends => subscription.expires_at.try(:strftime, "%d/%m/%Y")
         )
    content_type 'text/html'
  end

  def suspended(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "Your subscription has been suspended"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
           :suspended_from => subscription.try(:state_updated_at).try(:strftime, "%d/%m/%Y"),
           :suspended_to => subscription.try(:state_expires_at).try(:strftime, "%d/%m/%Y")
         )
    content_type 'text/html'
  end

  def unsuspended(subscription)
    recipients subscription.user.email
    subject(publication_subject(subscription, "Your subscription has been reactivated"))
    from(publication_sender(subscription))
    
    body extract_liquid_variables(subscription,
           :suspended_from => subscription.try(:state_updated_at).try(:strftime, "%d/%m/%Y"),
           :suspended_to => subscription.try(:state_expires_at).try(:strftime, "%d/%m/%Y")
         )
    content_type 'text/html'
  end
  
  def publication_subject(subscription, subject_text)
    "[#{subscription.publication.try(:name)}] #{subject_text}"
  end
  
  def publication_sender(subscription, fallback_sender = NO_REPLY)
    subscription.publication.try(:from_email_address) || fallback_sender
  end
  
  def render_message(template, body)
    return super unless self.respond_to?(:liquid_template_path)
    Liquid::Template.file_system = Liquid::LocalFileSystem.new(File.join('public', 'templates', liquid_template_path))
    liquid_template = File.join(mailer_name, template)
    unless File.exists?(Liquid::Template.file_system.full_path(liquid_template))
      super
    else
      Liquid::Template.parse(Liquid::Template.file_system.read_template_file(liquid_template)).render(HashWithIndifferentAccess.new(body).to_hash)
    end
  end
  
  def self.with_template(_liquid_template_path)
    mailer = Class.new(self) do
      cattr_accessor :liquid_template_path
      def self.dump_for_delayed_job
        "#{superclass.name};#{liquid_template_path}"
      end
    end

    mailer.tap do |m|
      m.liquid_template_path = _liquid_template_path
      m.mailer_name = self.name.underscore
    end
  end
  
  def self.load_for_delayed_job(obj)
    obj.blank? ? self : self.with_template(obj)
  end
end
