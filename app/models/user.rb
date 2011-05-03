class User < ActiveRecord::Base
  
  acts_as_authentic do |c|
    c.validate_login_field = false
  end
  
  has_many :audit_log_entries
  has_many :subscriptions, :before_add => :only_one_trial_allowed
  has_many :payments, :through => :subscriptions
  
  has_many :orders
  attr_accessor :email_confirmation

  enum_attr :role, %w(admin subscriber)
  enum_attr :title, %w(Mr Mrs Ms Miss)
  enum_attr :state, %w(act nsw nt qld sa tas vic wa intl) do
    labels :intl => "Outside of Australia"
    labels :act => 'ACT'
    labels :nsw => 'NSW'
    labels :nt  => 'NT'
    labels :qld => 'QLD'
    labels :sa  => 'SA'
    labels :tas => 'TAS'
    labels :vic => 'VIC'
    labels :wa  => 'WA'
  end

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :login, :firstname, :lastname, :email, :role, :unless => Proc.new { |user| user.auto_created? }, :if => Proc.new { |user| user.admin? }
  validates_presence_of :firstname, :lastname, :email, :phone_number, :address_1, :city, :postcode, :state, :country, :role, :unless => Proc.new { |user| user.auto_created? or user.admin? }
  validates_uniqueness_of :email
  validates_confirmation_of :email #, :on => :create, :unless => Proc.new { |user| user.admin? }

  validate_on_create do |user|
    user.errors.add(:login, "is already taken") if Wordpress.exists?(:login => user.login)
  end

  # Used for search controller
  named_scope :firstname_or_lastname_like, lambda { |arg| { :conditions => ["lower(firstname) || ' ' || lower(lastname) LIKE ?", "%#{arg.try(:downcase)}%"]} }

  named_scope :admins, :conditions => { :role => 'admin' }
  named_scope :subscribers, :conditions => { :role => 'subscriber' }

  def after_initialize
    # Default to subscriber role
    self.role ||= 'subscriber'
  end
  
  # Allow authlogic to find a user by login or email
  def self.find_by_login_or_email(login)
     find_by_login(login) || find_by_email(login)
  end

  # Used by the Unbounce Webhook
  def self.find_or_create_with_trial(publication, trial_period_in_days, referrer, user_attributes)
    user_attributes.symbolize_keys!
    user = self.find_by_email(user_attributes[:email].to_s)
    user ||= self.create_trial_user(user_attributes)
    # Weekender & Solus options
    solus = !user_attributes.fetch(:options, []).select { |s| /advertisers/i === s }.empty?
    weekender = !user_attributes.fetch(:options, []).select { |s| /weekender/i === s }.empty?
    # Add the subscription
    user.subscriptions.create!(
      :publication => publication,
      :expires_at => trial_period_in_days.days.from_now,
      :referrer => referrer,
      :weekender => weekender,
      :solus => solus
    )
  end

  # Used for creating new users from trial forms
  def self.create_trial_user(attributes)
    r_password = (0...7).map { ('a'..'z').to_a[rand(26)] }.join << rand(9).to_s
    self.create!(
      :firstname => attributes[:first_name].to_s,
      :lastname => attributes[:last_name].to_s,
      :email => attributes[:email].to_s,
      :email_confirmation => attributes[:email].to_s,
      :password => r_password,
      :password_confirmation => r_password,
      :login => 'trial_user',
      :auto_created => true
    )
  end

  def only_one_trial_allowed(subscription)
    return if subscription.active?
    if self.subscriptions.trial.find(:first, :conditions => { :publication_id => subscription.publication_id })
      raise "User already has a trial for publication"
    end
  end

  # Returns true if user has at least one active sub
  def has_active_subscriptions?
    subscriptions.any?(&:active?)
  end

  def name
    [ self.firstname, self.lastname ].join(" ")
  end
  
  def fullname
    name
  end

  def admin?
    self.role == :admin
  end

  # Used by ActiveMerchant
  def address_hash
    {
      :address1 => address_1,
      :address2 => address_2,
      :city => city,
      :country => country,
      :state => state,
      :zip => postcode,
    }
  end

  def sync_to_campaign_master
    self.subscriptions.each(&:sync_to_campaign_master)
  end
  
  def store_credit_card_on_gateway(credit_card)
    if self.payment_gateway_token.blank?
      token = Utilities.generate_unique_token(self.id, 10)
      response = GATEWAY.setup_recurrent(0, credit_card, token)
      unless response.success?
        raise Exceptions::CannotStoreCard.new(response.message)
      end
      update_attributes!(:payment_gateway_token => token)
      save!
    end
  end
end
