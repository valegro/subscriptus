class User < ActiveRecord::Base
  
  MAIL_SYSTEM_SYNC_COLUMNS = %w(email firstname lastname country city state title phone_number postcode address_1 address_2)
  acts_as_authentic do |c|
    c.validate_login_field = false
  end
  
  has_many :audit_log_entries
  has_many :subscriptions, :before_add => :only_one_trial_allowed, :dependent => :destroy
  has_many :payments, :through => :subscriptions
  
  has_many :orders
  attr_accessor :email_confirmation

  enum_attr :role, %w(admin subscriber)
  #enum_attr :title, %w(Mr Sir Fr Mrs Ms Miss Lady)
  
  enum_attr :gender, %w(male female) do
    labels :male => 'Male'
    labels :female => 'Female'
  end

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
  validates_presence_of :firstname, :lastname, :email, :phone_number, :address_1, :city, :postcode, :state, :country, :role, :unless => Proc.new { |user| (user.auto_created? && user.new_record?) or user.admin? }
  validates_uniqueness_of :email
  validates_confirmation_of :email #, :on => :create, :unless => Proc.new { |user| user.admin? }

  validate_on_create do |user|
    unless user.admin?
      user.errors.add(:login, "is already taken") if Wordpress.exists?(:login => user.login)
      user.errors.add(:email, "is already taken") if Wordpress.exists?(:email => user.email)
    end
  end

  validate_on_update do |user|
    if user.email_changed? && Wordpress.exists?(:email => user.email)
      user.errors.add(:email, "is already taken")
    end
    if user.login_changed?
      user.errors.add(:login, "cannot be changed after initial creation")
    end
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
    solus = user_attributes.fetch(:options, {})[:solus]
    #solus = !user_attributes.fetch(:options, []).select { |s| /advertisers/i === s }.empty?
    weekender = user_attributes.fetch(:options, {})[:weekender]
    #weekender = !user_attributes.fetch(:options, []).select { |s| /weekender/i === s }.empty?
    # Add weekender
    user.add_weekender_to_subs if weekender
    # Add the subscription
    user.subscriptions.create!(
      :publication => publication,
      :expires_at => trial_period_in_days.days.from_now,
      :referrer => referrer,
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

  # TODO: I suspect this is no longer relevant
  def only_one_trial_allowed(subscription)
    return if subscription.active?
    if self.subscriptions.detect { |s| s.publication_id == subscription.publication_id }
      raise Exceptions::DuplicateSubscription
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

  def sync_to_wordpress(password = nil)
    options = {
      :login       => self.login,
      :firstname   => self.firstname,
      :lastname    => self.lastname,
      :email       => self.email,
      :premium     => self.premium?
    }
    if Wordpress.exists?(:login => self.login)
      Wordpress.send_later(:update, options)
    else
      options[:pword] = password unless password.blank?
      Wordpress.send_later(:create, options)
    end
  end

  def premium?
    # TODO Crikey Weekender here is a Hack for Crikey!
    self.subscriptions.any? do |sub|
      sub.active? && sub.publication.name != 'Crikey Weekender'
    end
  end

  # TODO: Custom for Crikey
  def has_weekender?
    self.subscriptions.any? do |sub|
      sub.publication.name == 'Crikey Weekender'
    end
  end

  def add_weekender_to_subs
    unless has_weekender?
      weekender = Publication.find_by_name("Crikey Weekender")
      return unless weekender
      self.subscriptions.create!(
        :publication => weekender,
        :expires_at => nil,
        :state => 'active'
      )
    end
  end
  
  def store_credit_card_on_gateway(credit_card)
    if self.payment_gateway_token.blank?
      # TODO: user module ActiveMerchant::module Utils
      token = Utilities.generate_unique_token(self.id, 10)
      response = GATEWAY.setup_recurrent(0, credit_card, token)
      unless response.success?
        raise Exceptions::CannotStoreCard.new(response.message)
      end
      update_attributes!(:payment_gateway_token => token)
      save!
    end
  end

  def valid_password?(password)
    if role == :admin
      super
    else
      Wordpress.authenticate(:email => email, :pword => password)
    end
  end
end
