class SubscriptionMailer < ActionMailer::Base
  include ActionView::Helpers::NumberHelper
  
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
    body           :subscription => subscription, :user => subscription.user, :gifts => subscription.try(:actions).try(:first).try(:gifts), :cost => number_to_currency(subscription.try(:actions).try(:first).try(:payment).try(:amount), :unit => "AUD $"), :gst => number_to_currency(subscription.try(:actions).try(:first).try(:payment).try(:amount).try(:/, 11.0)), :publication_name => subscription.publication.name, :expiration_date => subscription.try(:expires_at).try(:strftime, "%d/%m/%Y"), :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id), :has_gifts => (!subscription.actions.empty? && !subscription.actions.first.gifts.blank?), :address1 => subscription.user.try(:address_1), :address2 => subscription.user.try(:address_2), :city => subscription.user.try(:city), :postcode => subscription.user.try(:postcode), :state => subscription.user.try(:state).try(:to_s).try(:upcase), :country => subscription.user.try(:country)
    content_type   'text/html'
  end

  def cancelation(subscription)
    # raising exceptions for the fileds that are used in the email body
    raise Exceptions::EmailDataError.new("nil subscription") unless !subscription.blank?
    raise Exceptions::EmailDataError.new("nil user/ email") unless !subscription.user.blank? && !subscription.user.email.blank?
    recipients     "#{subscription.user.email}"
    subject        "Crikey Online Cancelation"
    from           NO_REPLY
    body           :subscription => subscription, :user => subscription.user, :squatter => subscription.state == :squatter, :publication_name => subscription.publication.name, :gifts => subscription.try(:offer).try(:gifts), :address1 => subscription.user.try(:address_1), :address2 => subscription.user.try(:address_2), :city => subscription.user.try(:city), :postcode => subscription.user.try(:postcode), :state => subscription.user.try(:state).try(:to_s).try(:upcase), :country => subscription.user.try(:country)
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
    body :subscription => subscription, :user => subscription.user, :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id), :creation_date => subscription.created_at.try(:strftime, "%d/%m/%Y")

    content_type 'text/html'
  end

  def pending_concession_verification(subscription)
    recipients subscription.user.email
    subject "Your subscription is pending verification"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user, :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id), :creation_date => subscription.created_at.try(:strftime, "%d/%m/%Y")
    content_type 'text/html'
  end

  def pending_payment(subscription)
    recipients subscription.user.email
    subject "Your subscription is pending payment"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user, :subscription_date => subscription.created_at.strftime("%d/%m/%Y"), :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id)
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
    body :subscription => subscription, :user => subscription.user, :forgot_password_url => subscription.publication.forgot_password_link, :subscription_starts => subscription.state_updated_at.try(:strftime, "%d/%m/%Y"), :subscription_ends => subscription.expires_at.try(:strftime, "%d/%m/%Y"), :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id)
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
    body :subscription => subscription, :user => subscription.user, :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id), :suspended_from => subscription.state_updated_at.strftime("%d/%m/%Y"), :suspended_to => subscription.state_expires_at.strftime("%d/%m/%Y")
    content_type 'text/html'
  end

  def unsuspended(subscription)
    recipients subscription.user.email
    subject "Your subscription has been reactivated"
    from NO_REPLY
    body :subscription => subscription, :user => subscription.user, :unsubscribe_url => unsubscribe_url(:user_id => subscription.user.id), :suspended_from => subscription.state_updated_at.strftime("%d/%m/%Y"), :suspended_to => subscription.state_expires_at.strftime("%d/%m/%Y")
    content_type 'text/html'
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
    end
    
    mailer.tap do |m|
      m.liquid_template_path = _liquid_template_path
      m.mailer_name = self.name.underscore
    end
  end
end
