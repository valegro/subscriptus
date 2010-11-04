class Subscription < ActiveRecord::Base
  #include Billing::Cycle
  include Utilities

  acts_as_archive  # so that the records are not actually deleted from database. makes it possible to keep track of used <sources> and <publications>

  belongs_to :user, :autosave => true
  belongs_to :offer
  belongs_to :publication
  belongs_to :source # with this attribute there is no need to have the SubscriptionLogEntry as sources are easily trackable through subscription. but subscription needs to act_as_paranoid
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
  
  attr_accessor :starts_at # the start date of the newest subscription
  accepts_nested_attributes_for :subscription_gifts, :user

  named_scope :ascend_by_name, :include => 'user', :order => "users.lastname ASC, users.firstname ASC"
  named_scope :descend_by_name, :include => 'user', :order => "users.lastname DESC, users.firstname DESC"

  # Used for search controller
  named_scope :user_firstname_or_user_lastname_like, lambda { |arg|
    { :include => :user, :conditions => ["lower(users.firstname) || ' ' || lower(users.lastname) LIKE ?", "%#{arg.try(:downcase)}%"] }
  }

  def self.per_page
    20
  end

  def get_user
    self.user_id ? User.find(self.user_id) : nil
  end

  # Signup Wizard
  #validation_group :offer, :fields => [ :publication_id, :price, :expires_at ]
  #validation_group :details
  #validation_group :payment

  validates_presence_of :publication #, :price ??
  
  # Subscription States
  # has_states :incomplete, :trial, :squatter, :active, :pending, :renewal_due, :payment_failed do
  has_states :trial, :squatter, :active, :pending, :extension_pending, :cancelled, :renewal_due, :payment_failed, :init => :trial do
    on :activate do
      transition :active => :active # when the subscriber extends their subscription while its still active
      transition :trial => :active
      transition :squatter => :active
    end
    on :pay_later do
      transition :trial => :pending
      transition :active => :extension_pending # when the subscriber is currently active but is going to pay for the new subscription using Direct Debit
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
    on :cancel do
      transition :trial => :squatter
      transition :active => :cancelled # subscription will remain in cancelled state untill it manually processed by admin users
      transition :pending => :cancelled
      transition :extension_pending => :cancelled
    end
    on :mark_processed do # when the cancelled subscription is manually processed by admin users
      transition :cancelled => :squatter
    end
    # Expiries
    expires :pending => :squatter, :after => 14.days
    # expires :trial => :squatter, :after => 21.days
  end

  def update_campaignmaster
    # TODO: determine how publication name on campaignmaster is managed.
    #       currently (temporarily) using publication_123{expiry} style for keys.
    result = CM::Recipient.update(
        :fields => { :"publication_#{self.publication_id}{state}" => self.state,
                     :"publication_#{self.publication_id}{expiry}" => self.expires_at,
                     :user_id => self.user_id
        }
    )
    return result
  rescue RuntimeError => ex
    CM::Proxy.log_cm_error(ex)
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
  def increment_expires_at(offer_term)
    self.expires_at = nil && return unless offer_term.expires?
    self.expires_at = Date.today if self.expires_at.blank? || self.expires_at < Date.today
    self.starts_at = self.expires_at
    self.expires_at = self.expires_at.advance(:months => offer_term.months)
  end

  # generates a random number that is saved after a successful recurrent profile creation and used later
  # to access the subscription and to be sent to the client so that in case of any problems they can easily refer to
  # the logs using this number
  # this method uses secure random number generator in combination with offset(unique) that makes the number unique
  # the generated number is 16 numbers long
  def generate_and_set_order_number
    returning num = generate_unique_random_number(15) do
      self.order_num = num
    end
  end

  def pay_non_first_time(payment)
    returning self do
      payment.money = price # setting the money of payment object
      payment.customer_id = self.user.recurrent_id
      payment.order_num = self.generate_and_set_order_number # order_num is sent to the user as a reference number of their subscriptions
      payment.call_recurrent_profile # make the payment through secure pay
      # change the state of subscription from trial to active
      self.activate
    end
  end
  
  def pay_first_time(payment)
    returning self do
      payment.money = self.price # setting the money of payment object
      payment.customer_id = self.user.generate_recurrent_profile_id # customer_id is used to create recurrent_profile in secure pay
      payment.create_recurrent_profile
      # recurrent setup successul, so now the customer_id should be saved as a reference to later transactions
      self.user.recurrent_id = payment.customer_id
      payment.order_num = self.generate_and_set_order_number # order_num is sent to the user as a reference number of their subscriptions
      payment.call_recurrent_profile # make the payment through secure pay
      # change the state of subscription from trial to active
      self.activate
    end
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
