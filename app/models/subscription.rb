class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
  has_many :subscription_log_entries
  belongs_to :publication

  #validates_presence_of :expiry

  # Signup Wizard
  validation_group :offer
  validation_group :details
  validation_group :payment

=begin
  # Subscription States
  has_states :trial, :squatter, :active, :pending, :renewal_due, :payment_failed do
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
