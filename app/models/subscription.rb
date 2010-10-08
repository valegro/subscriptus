class Subscription < ActiveRecord::Base
  include Utilities

  belongs_to :user
  belongs_to :offer
  belongs_to :publication
  has_many :subscription_log_entries
  has_many :subscription_gifts, :dependent => :destroy
  
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
    on :pay_later do
      transition :trial => :pending
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

  # if the sibscription is new or expired, start it from now
  # otherwise start it after the expiration time
  def set_expires_at(months)
    self.expires_at = (self.expires_at.blank? || self.expires_at < Date.today) ? Date.today.months_since(months) + 1.day : self.expires_at.months_since(months) + 1.day
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
end
