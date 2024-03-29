class Subscription < ActiveRecord::Base

  acts_as_archive :indexes => :id # so that the records are not actually deleted from database. makes it possible to keep track of used <sources> and <publications>
  class Archive
    belongs_to :offer
  end
  
  belongs_to :user
  belongs_to :offer
  belongs_to :publication
  belongs_to :pending_action, :class_name => "SubscriptionAction"

  has_many :actions,
           :class_name => "SubscriptionAction",
           :order => "applied_at desc",
           :autosave => true,
           :before_add => Proc.new { |s, a|
             a.applied_at ||= Time.now.utc
             a.renewal = true if !s.actions.empty?
           }

  has_many :log_entries, :class_name => "SubscriptionLogEntry", :dependent => :destroy
  has_many :orders
  has_many :scheduled_suspensions, :dependent => :destroy
  
  delegate :template_name, :to => :publication
  
  attr_accessor :temp_password # Used for sending password to new trialers
  attr_accessor :note # Used to save notes to the subscription
  attr_accessor :terms
  attr_accessor :starts_at # the start date of the newest subscription #TODO: Is this used anywhere?
  accepts_nested_attributes_for :user

  named_scope :ascend_by_name, :include => 'user', :order => "users.lastname ASC, users.firstname ASC"
  named_scope :descend_by_name, :include => 'user', :order => "users.lastname DESC, users.firstname DESC"
  named_scope :recent, :order => "updated_at desc"
  named_scope :expired, lambda { { :conditions => [ "expires_at < ?", Time.now ] } }
  named_scope :not_unsubscribed, :conditions => "state != 'unsubscribed'"
  # Pending and Renewal Pending
  named_scope :any_pending, :conditions => { :state => %w(pending renewal_pending) }

  liquid_methods :reference, :updated_at

  validates_presence_of :publication, :state
  validates_acceptance_of :terms

  def validate_on_create
    if state == 'pending'
      if self.pending_action.blank?
        errors.add_to_base("A pending action must be provided in the pending state")
      end
      if self.pending.blank?
        errors.add_to_base("The pending column must be set in the pending state")
      end
    end
  end

  def validate
    unless self.user.blank?
      raise Exceptions::DuplicateSubscription if self.user.subscriptions.detect do |s|
        s.publication_id == self.publication_id && s.id != self.id
      end
    end
  end

  # Used to specify what the pending state is waiting on
  enum_attr :pending, %w(payment concession_verification student_verification)
  
  # Subscription States
  has_states :trial, :squatter, :active, :suspended, :pending, :renewal_pending, :renewal_due, :payment_failed, :unsubscribed, :init => :trial do
    on :new_trial do
      transition :squatter => :trial
      transition :unsubscribed => :trial
    end
    on :activate do
      transition :trial => :active
      transition :squatter => :active
      transition :unsubscribed => :active
    end
    on :renew do
      transition :active => :active # when the subscriber extends their subscription while its still active
    end
    on :postpone do
      transition :trial => :pending
      transition :squatter => :pending
      transition :active => :renewal_pending # Renewal but goes into pending state
      transition :unsubscribed => :pending
    end
    on :verify do
      transition :pending => :active
      transition :renewal_pending => :active
    end
    on :expire do
      transition :trial => :squatter
      transition :active => :squatter
      transition :renewal_pending => :pending
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
    on :unsubscribe do
      transition :trial => :unsubscribed
      transition :squatter => :unsubscribed
      transition :active => :unsubscribed
      transition :suspended => :unsubscribed
      transition :pending => :unsubscribed
    end
    
    # Expiries
    expires :trial => :squatter, :after => Publication::DEFAULT_TRIAL_EXPIRY.days
    expires :active => :squatter
    expires :suspended => :active
    expires :renewal_pending => :pending
  end

  def expired?
    Time.now > self.expires_at
  end

  # TODO: Rename to apply_action! (maybe even move to the association? And disable <<)
  def apply_action(action)
    self.class.transaction do
      action.subscription = self
      action.apply
      self.actions << action # TODO: Maybe apply is called as a callback on the association??
    end
  end

  # TODO: No longer need to have an argument to verify - so can move to an observer
  def verify_with_params!(object = nil)
    self.class.transaction do
      if pending.try(:to_sym) == :concession_verification
        self.user.valid_concession_holder = true
      end
      self.apply_action(self.pending_action) if self.pending_action
      self.pending_action = nil
      verify_without_params!
    end
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

  #def sync_to_campaign_master
  #  hash = {
  #    :email => self.user.email,
  #    :fields => {
  #      :subscription_id  => self.reference,
  #      :state            => self.state,
  #      :publication_id   => self.publication_id,
  #      :user_id          => self.user_id,
  #      :firstname        => self.user.firstname,
  #      :lastname         => self.user.lastname,
  #      :country          => self.user.country,
  #      :city             => self.user.city,
  #      :address_state    => self.user.state,
  #      :title            => self.user.title,
  #      :phone_number     => self.user.phone_number,
  #      :postcode         => self.user.postcode,
  #      :address_1        => self.user.address_1,
  #      :address_2        => self.user.address_2,
  #      :offer_id         => self.offer_id,
  #      :expires_at       => self.expires_at.try(:strftime, "%d/%m/%y"),
  #      :created_at       => self.created_at.try(:strftime, "%d/%m/%y"),
  #      :state_updated_at => self.state_updated_at.try(:strftime, "%d/%m/%y"),
  #      :solus            => self.solus
  #    }
  #  }

  #  if CM::Recipient.exists?(:fields => { 'subscription_id' => self.reference })
  #    CM::Recipient.update(hash)
  #  else
  #    CM::Recipient.create!(hash)
  #  end
  #end

  def increment_expires_at(term_length)
    unless term_length
      self.expires_at = nil
      return
    end
    if self.state_changed? || self.expires_at.blank? || self.expires_at < Time.now
      self.expires_at = Time.now
    end
    self.starts_at = self.expires_at
    self.expires_at = self.expires_at.advance(:months => term_length)
  end

  def default_payment_method
    self.payment_method = Billing::Charger::CREDIT_CARD
  end

  # TODO: I'm sure we could do this within has_states using state_expires_at ??
  def self.expire_active_subscribers
    self.active.expired.find_each(:batch_size => 100) do |subscription|
      subscription.expire!
    end
  end

  # TODO: Ditto above (has_states/state_expires_at)
  def self.unsuspend_expiring_suspensions
    #self.suspended.expired.find_each(
  end
end
