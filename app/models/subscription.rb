class Subscription < ActiveRecord::Base

  include Billing::CreditCard
  include Billing::Charger

  belongs_to :user, :autosave => true
  belongs_to :offer
  belongs_to :publication
  has_many :subscription_log_entries
  has_many :subscription_gifts, :dependent => :destroy

  has_many :payments, :class_name => "::Subscription::Payment", :dependent => :destroy
  has_many :invoices, :class_name => "::Subscription::Invoice", :dependent => :destroy
  
  has_many :gifts, :through => :subscription_gifts do
    # add an array of gifts
    def add_uniquely(gifts)
      gifts.each do |gift|
        self << gift unless self.include?(gift)
      end
    end
    # add one gift
    def add_uniquely_one(gift)
      self << gift unless self.include?(gift)
    end
  end
  
  accepts_nested_attributes_for :subscription_gifts, :user
  
  #validates_presence_of :expiry
  
  # Signup Wizard
  validation_group :offer, :fields => [ :publication_id, :price, :expires_at ]
  validation_group :details
  validation_group :payment
  
  before_create do |record|
    record.publication_id = record.offer.publication_id 
  end

  # Subscription States
  # has_states :incomplete, :trial, :squatter, :active, :pending, :renewal_due, :payment_failed do
  has_states :trial, :squatter, :active, :pending, :renewal_due, :payment_failed, :init => :trial do
    on :activate do
      transition :trial => :active
      transition :squatter => :active
    end
    on :verify do
      transition :pending => :active
    end
    on :expire do
      transition :trial => :squatter
      transition :active => :squatter
      transition :pending => :squatter
    end
    on :enqueue_for_renewal do
      transition :active => :renewal_due
    end
    on :paid do
      transition :renewal_due => :active
    end
    on :fail_payment do
      transition :renewal_due => :payment_failed
      transition :payment_failed => :squatter
    end
    # Expiries
    expires :pending => :squatter, :after => 14.days
  end

  # These are the options sent to the gateway when attempting to save a
  # credit card.
  def to_activemerchant
    returning({}) do |hash|
      if self.user
        hash.merge({
          :title => self.user.title,
          :country => self.user.country,
          :company => "",
          :email => self.user.email
        })
      end
    end
  end

  # These are the properties that get passed to the ActiveMerchant
  # credit card object.
  def to_credit_card
    # TODO: Should this be the name on card??
    returning({}) do |hash|
      if self.user
        hash.merge({
          :first_name => self.user.firstname,
          :last_name => self.user.lastname
        })
      end
    end
  end

  # if the sibscription is new or expired, start it from now
  # otherwise start it after the expiration time
  def get_new_expiry_date(months)
    (self.expires_at.blank? || self.expires_at < Date.today) ? Date.today.months_since(months) + 1.day : self.expires_at.months_since(months) + 1.day
  end
  
  private

  # If the current account is expired, and the subscription now has a
  # gateway token, activate the account.
  def update_from_expired
    self.activate! if gateway_token_changed? && !gateway_token.blank? && self.expired?
  end

  def default_payment_method
    self.payment_method = Billing::Charger::CREDIT_CARD
  end
end
