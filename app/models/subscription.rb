class Subscription < ActiveRecord::Base

  acts_as_archive :indexes => :id # so that the records are not actually deleted from database. makes it possible to keep track of used <sources> and <publications>
  class Archive
    belongs_to :offer
  end
  
  belongs_to :user, :autosave => true
  belongs_to :offer
  belongs_to :publication
  belongs_to :source

  has_many :log_entries, :class_name => "SubscriptionLogEntry"
  has_many :subscription_gifts, :dependent => :destroy
  has_many :payments, :autosave => true
  has_many :orders
  
  # TODO: Test this
  has_many :gifts, :through => :subscription_gifts, :uniq => true, :before_add => Proc.new { |a, gift| raise "Gift is out of stock" unless gift.in_stock? }
  
  attr_accessor :note # Used to save notes to the subscription
  attr_accessor :terms
  attr_accessor :starts_at # the start date of the newest subscription #TODO: Is this used anywhere?
  accepts_nested_attributes_for :payments, :user

  named_scope :ascend_by_name, :include => 'user', :order => "users.lastname ASC, users.firstname ASC"
  named_scope :descend_by_name, :include => 'user', :order => "users.lastname DESC, users.firstname DESC"
  named_scope :recent, :order => "updated_at desc"

  validates_presence_of :publication, :user, :state
  validates_acceptance_of :terms

  # Used to specify what the pending state is waiting on
  enum_attr :pending, %w(payment concession)
  
  # Subscription States
  has_states :trial, :squatter, :active, :suspended, :pending, :renewal_due, :payment_failed, :init => :trial do
    on :activate do
      transition :active => :active # when the subscriber extends their subscription while its still active
      transition :trial => :active
      transition :squatter => :active
    end
    on :pay_later do
      transition :trial => :pending
      transition :active => :pending # when the subscriber is currently active but is going to pay for the new subscription using Direct Debit
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
      transition :active => :squatter
      transition :pending => :squatter
    end
    on :suspend do
      transition :active => :suspended
    end
    on :unsuspend do
      transition :suspended => :active
    end
    
    # Expiries
    expires :pending => :squatter, :after => 14.days
    expires :trial => :squatter, :after => 21.days

  end
  after_exit_suspended :restore_subscription_expiry

  def apply_term(offer_term)
    if offer_term.blank? || offer_term.offer.blank? || offer_term.offer != self.offer
      raise Exceptions::InvalidOfferTerm
    end
    self.price = offer_term.price
    self.term_length = offer_term.months
    # Set the payment price
    self.payments.last.try(:amount=, offer_term.price)
    self.increment_expires_at(offer_term)
  end
  
  def restore_subscription_expiry
    if self.state_expires_at
      days_to_restore = (Date.yesterday - self.state_expires_at.to_date).to_i
      if (days_to_restore < 0)
        self.expires_at = self.expires_at.advance(:days => days_to_restore).to_datetime
      end
      self.state_expires_at = nil
      self.save
    end
  end

  # TODO: Also alias verify
  def verify_with_params!(object = nil)
    # TODO: Transaction?
    case pending.to_sym
      when :payment
        raise "Requires Payment to verify" unless object.kind_of?(Payment)
        payments << object
      when :concession
    end
    verify_without_params!
  end

  alias_method_chain :verify!, :params
  private :verify_with_params!, :verify_without_params!
  
  def suspend_with_number_of_days!(number_of_days = nil)
    if number_of_days
      self.state_expires_at = Date.today.advance(:days => number_of_days).to_datetime
      self.expires_at = self.expires_at.advance(:days => number_of_days).to_datetime
    else
      raise "Cannot suspend a subscription without a time period"
    end
    suspend_without_number_of_days!
  end

  alias_method_chain :suspend!, :number_of_days
  private :suspend_with_number_of_days!, :suspend_without_number_of_days!

  def state_expiry_period_in_days
    (self.state_expires_at.to_date - Date.today) if self.state_expires_at
  end
  
  def self.per_page
    20
  end

  def self.format_reference(reference)
    "S%07d" % reference
  end
  
  def self.id_from_reference(reference)
    reference.sub(/^S/i, '').to_i
  end
  
  def reference
    Subscription.format_reference(self.id)
  end

  def sync_to_campaign_master
    hash = {
      :email => self.user.email,
      :fields => {
        :subscription_id  => self.id,
        :status           => self.state,
        :publication_id   => self.publication_id,
        :user_id          => self.user_id,
        :expires_at       => self.expires_at.try(:strftime, "%d/%m/%y"),
        :firstname        => self.user.firstname,
        :lastname         => self.user.lastname,
        :country          => self.user.country,
        :city             => self.user.city,
        :state            => self.user.state,
        :title            => self.user.title,
        :phone_number     => self.user.phone_number,
        :postcode         => self.user.postcode,
        :address_1        => self.user.address_1,
        :address_2        => self.user.address_2
      }
    }
    # TODO: Solus, Weekender? Are these even needed?

    if CM::Recipient.exists?(:fields => { 'subscription_id' => self.id })
      CM::Recipient.update(hash)
    else
      CM::Recipient.create!(hash)
    end
  rescue RuntimeError => ex
    CM::Proxy.log_cm_error(ex)
  end

  # if the subscription is new or expired, start it from now
  # otherwise start it after the expiration time
  def increment_expires_at(offer_term)
    self.expires_at = nil && return unless offer_term.expires?
    self.expires_at = Date.today if self.expires_at.blank? || self.expires_at < Date.today
    self.starts_at = self.expires_at
    self.expires_at = self.expires_at.advance(:months => offer_term.months)
  end

  def pay_non_first_time(payment)
    returning self do
      payment.money = price # setting the money of payment object
      payment.customer_id = self.user.recurrent_id
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
