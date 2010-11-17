class User < ActiveRecord::Base
  include Utilities
  
  acts_as_authentic do |c|
    c.validate_login_field = false
  end
  
  has_many :audit_log_entries
  has_many :subscriptions, :before_add => :only_one_trial_allowed
  attr_accessor :email_confirmation

  enum_attr :role, %w(admin subscriber)
  enum_attr :title, %w(Dr Hon Lady Miss Mr Mrs Ms Prof Rev Sen Sir)
  enum_attr :state, %w(ACT NSW NT QLD SA TAS VIC WA INTL) do
    labels :INTL => "Outside of Australia"
  end

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :firstname, :lastname, :email, :phone_number, :address_1, :city, :postcode, :state, :country, :role, :unless => Proc.new { |user| user.auto_created? }
  validates_uniqueness_of :email
  validates_uniqueness_of :login, :unless => Proc.new { |user| user.auto_created? }
  validates_confirmation_of :email, :on => :create

  # Used for search controller
  named_scope :firstname_or_lastname_like, lambda { |arg| { :conditions => ["lower(firstname) || ' ' || lower(lastname) LIKE ?", "%#{arg.try(:downcase)}%"]} }

  named_scope :admins, :conditions => { :role => 'admin' }
  named_scope :subscribers, :conditions => { :role => 'subscriber' }

  def after_initialize
    # Default to subscriber role
    self.role ||= 'subscriber'
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
    if self.subscriptions.trial.find(:first, :conditions => { :publication_id => subscription.publication_id })
      raise "User already has a trial for publication"
    end
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

  def update_cm(create_or_update)
    result = CM::Recipient.send(create_or_update,
        :created_at => created_at,
        :email => email,
        :fields => {
          :address_1 => address_1,
          :address_2 => address_2,
          :city => city,
          :country => country,
          :firstname => firstname,
          :lastname => lastname,
          :login => login,
          :phone_number => phone_number,
          :postcode => postcode,
          :state => state,
          :title => title,
          :user_id => id
        }
    )
    return result
  rescue RuntimeError => ex
    CM::Proxy.log_cm_error(ex)
  end
  
  # generates a random number that is saved after a successful recurrent profile creation and used later
  # to access the users recurrent profile in secure pay in order to make new payments or cancel the proile
  # this unique number (called Client ID in AU sequre pay gateway) should be less than 20 characters long
  # this method uses secure random number generator in combination with offset(unique) that makes the number unique
  # the generated number is 18 numbers long
  def generate_recurrent_profile_id
    generate_unique_random_number(19)
  end

  # creates or updates the user
  # returns user
  def self.save_new_user(user_attributes)
    returning user = User.new(user_attributes) do
      user.save!
    end
  rescue Exception => e
    raise Exceptions::UserInvalid.new(e.message)
  end

  # recurrent_id shows if the user has used their Credit Card before or not
  def has_recurrent_profile?
    !self.recurrent_id.blank?
  end
end
