class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
  belongs_to :publication
  has_many :subscription_log_entries
  has_many :subscription_gifts, :dependent => :destroy
  
  #has_many :gifts, :through => :subscription_gifts

  accepts_nested_attributes_for :subscription_gifts

  #validates_presence_of :expiry

  # Signup Wizard
  validation_group :offer, :fields => [ :publication_id, :price, :expires_at ]
  validation_group :details
  validation_group :payment

  before_create do |record|
    record.publication_id = record.offer.publication_id
  end

=begin
  # Subscription States
  has_states :incomplete, :trial, :squatter, :active, :pending, :renewal_due, :payment_failed do
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
=end
end
