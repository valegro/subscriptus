class User < ActiveRecord::Base
  
  MAIL_SYSTEM_SYNC_COLUMNS = %w(email firstname lastname country city state title phone_number postcode address_1 address_2)
  CMS_SYNC_COLUMNS = %w(firstname lastname email password)

  acts_as_authentic do |c|
    c.validate_login_field = false
  end
  
  liquid_methods :firstname, :lastname, :email, :address_1, :address_2, :city, :postcode, :state, :country, :fullname

  has_many :audit_log_entries
  has_many :subscriptions, :before_add => :check_duplicate_subscription, :dependent => :destroy
  has_many :payments, :through => :subscriptions
  
  has_many :orders
  attr_accessor :email_confirmation

  # If true, any account in WP will be ignored on create or update
  # thus clobbering any matching accounts in WP (use with caution)
  attr_accessor :overide_wordpress

  enum_attr :role, %w(admin subscriber)
  enum_attr :title, %w(Mr Sir Fr Mrs Ms Miss Lady)
  
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
  validates_presence_of :login, :if => Proc.new { |user| User.validate_as == :admin }
  validates_presence_of :phone_number, :address_1, :city, :postcode, :state, :country, :if => Proc.new { |user| p User.validate_as; User.validate_as == :subscriber }
  validates_presence_of :firstname, :lastname, :email, :role


  validates_uniqueness_of :email
  validates_confirmation_of :email #, :on => :create, :unless => Proc.new { |user| user.admin? }

  validate_on_create do |user|
    unless user.admin? || user.overide_wordpress
      user.errors.add(:login, "is already taken") if Wordpress.exists?(:login => user.login)
      user.errors.add(:email, "is already taken") if Wordpress.exists?(:email => user.email)
    end
  end

  validate_on_update do |user|
    if user.email_changed? && Wordpress.exists?(:email => user.email)
      user.errors.add(:email, "is already taken")
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

  # TODO: Put these in a module
  def self.validate_as=(sym)
    Thread.current[:validate_as] = sym
  end

  def self.validate_as(as = nil)
    if block_given?
      self.validate_as = as
      begin
        yield
      rescue
        raise $!
      ensure
        self.validate_as = nil
      end
    else
      Thread.current[:validate_as] || :subscriber
    end
  end

  # Used by the Unbounce Webhook
  def self.find_or_create_with_trial(publication, trial_period_in_days, referrer, user_attributes)
    user_attributes.symbolize_keys!
    user = self.find_by_email(user_attributes[:email].to_s)
    user ||= self.create_trial_user(user_attributes)
    p user
    # Reset the password
    if user.password.blank?
      user.password = random_password
      user.password_confirmation = user.password
      user.save!
    end
    # Weekender & Solus options
    solus = user_attributes.fetch(:options, {})[:solus]
    #solus = !user_attributes.fetch(:options, []).select { |s| /advertisers/i === s }.empty?
    weekender = user_attributes.fetch(:options, {})[:weekender]
    # Add weekender
    user.add_weekender_to_subs if weekender
    # Add or reset trial
    sub = user.add_or_reset_trial(publication, trial_period_in_days, referrer, solus)
    # Reset the password
    sub.temp_password = user.password
    SubscriptionMailer.deliver_new_trial(sub)
    return sub
  end

  # Used for creating new users from trial forms
  def self.create_trial_user(attributes)
    self.validate_as(:system) do
      attributes.symbolize_keys!
      p attributes
      r_password = random_password
      self.create!(
        :firstname => (attributes[:first_name] || attributes[:firstname]).to_s,
        :lastname => (attributes[:last_name] || attributes[:lastname]).to_s,
        :email => attributes[:email].to_s,
        :email_confirmation => attributes[:email].to_s,
        :password => r_password,
        :password_confirmation => r_password,
        :auto_created => true,
        :overide_wordpress => attributes[:overide_wordpress]
      )
    end
  end
 
  # TODO: Could make this an association extension
  def add_or_reset_trial(publication, trial_period_in_days, referrer, solus)
    # Does the user have a sub to the pub?
    if subscription = self.subscriptions.find(:first, :conditions => { :publication_id => publication.id })
      if subscription.trial? || (subscription.squatter? && subscription.state_updated_at > 12.months.ago)
        raise Exceptions::AlreadyHadTrial
      else
        returning(subscription) do |s|
          s.new_trial!
          s.update_attributes!(:solus => solus, :referrer => referrer)
        end
      end
    else
      self.subscriptions.create!(
        :publication => publication,
        :expires_at => trial_period_in_days.days.from_now,
        :referrer => referrer,
        :solus => solus
      )
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token
    save_with_validation(false)
    UserMailer.deliver_password_reset_instructions(self)
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
    options[:pword] = password unless password.blank?
    if Wordpress.exists?(:login => self.login)
      Wordpress.update(options)
    elsif Wordpress.exists?(:email => self.email)
      raise Wordpress::PrimaryKeyMismatch.new("The login stored in subscriptus does not match that stored in Wordpress. You will need to manually update the user's details in Subscriptus so that the logins match.")
    else
      # Can't create a WP user if we don't have a password - so we will create a random one!
      options[:pword] = User.random_password if options[:pword].blank?
      Wordpress.create(options)
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
    unless credit_card.valid?
      raise Exceptions::CannotStoreCard.new(credit_card.errors.full_messages.join(",&nbsp;"))
    end
    # TODO: user module ActiveMerchant::module Utils
    token = Utilities.generate_unique_token(self.id, 10)
    # The amount is 1 cent to keep SecurePay happy but nothing is charged at this point
    response = GATEWAY.setup_recurrent(1, credit_card, token)
    unless response.success?
      raise Exceptions::CannotStoreCard.new(response.message)
    end
    update_attributes!(:payment_gateway_token => token)
    save!
  end

  def valid_password?(password)
    if role == :admin
      super
    else
      Wordpress.authenticate(:email => email, :pword => password)
    end
  end

  private
    def self.random_password
      (0...7).map { ('a'..'z').to_a[rand(26)] }.join << rand(9).to_s
    end

    def check_duplicate_subscription(subscription)
      raise Exceptions::DuplicateSubscription if self.subscriptions.detect do |s|
        s.publication_id == subscription.publication_id
      end
    end
end
