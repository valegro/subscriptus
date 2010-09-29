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
  
  # generates a random number that is saved after a successful recurrent profile creation and used later 
  # to access the users recurrent profile in secure pay in order to make new payments or cancel the proile
  # this unique number (called Client ID in AU sequre pay gateway) should be less than 20 characters long
  # this method uses secure random number generator in combination with offset(unique) that makes the number unique
  # the generated number is 18 numbers long
  def generate_recurrent_profile_id
    len = self.id.to_s.size
    raise Exception::UnableToGenerateRecurrentId.new("subscription id is too long") unless len < 19
    raise Exception::UnableToGenerateRecurrentId.new("nil subscription id")         unless self.id > 0
    diff = 19 - len # size of the random number
    max = "1"
    for i in 1...diff
      max += "0"
    end
    num = SecureRandom.random_number(max.to_i).to_s + self.id.to_s # self.id makes the number unique
    num.to_i
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
