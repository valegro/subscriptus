class User < ActiveRecord::Base
  include Utilities
  
  acts_as_authentic
  
  has_many :audit_log_entries
  has_many :subscriptions
  attr_accessor :email_confirmation

  enum_attr :role, %w(admin subscriber)
  enum_attr :title, %w(Dr Hon Lady Miss Mr Mrs Ms Prof Rev Sen Sir)
  enum_attr :state, %w(ACT NSW NT QLD SA TAS VIC WA INTL) do
    labels :INTL => "Outside of Australia"
  end

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :firstname, :lastname, :email, :phone_number, :address_1, :city, :postcode, :state, :country, :role
  validates_uniqueness_of :email
  validates_confirmation_of :email

  after_create { |user| user.update_cm(:create!) }
  after_update { |user| user.update_cm(:update) }

  def validate_on_create
    if self.email_confirmation.blank?
      errors.add_to_base("Must provide email confirmation")
    end
    unless self.email == self.email_confirmation
      errors.add_to_base("Email does not match confirmation")
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
end
