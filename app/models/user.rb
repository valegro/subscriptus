class User < ActiveRecord::Base
  acts_as_authentic

  has_many :audit_log_entries
  has_many :subscriptions
  attr_accessor :email_confirmation

  enum_attr :role, %w(admin subscriber)
  enum_attr :title, %w(Dr Hon Lady Miss Mr Mrs Ms Prof Rev Sen Sir)
  enum_attr :state, %w(ACT NSW NT QLD SA TAS VIC WA INTL) do
    labels :INTL => "Outside of Australia"
  end

  validates_presence_of :firstname, :lastname, :email, :email_confirmation, :phone_number, :address_1, :city, :postcode, :state, :country
  validates_format_of   :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email
  validates_confirmation_of :email_confirmation

  # def validate
  #   if self.email_confirmation.blank?
  #     errors.add_to_base("Must provide email confirmation")
  #   end
  #   unless self.email == self.email_confirmation
  #     errors.add_to_base("Email does not match confirmation")
  #   end
  # end

  def name
    [ self.firstname, self.lastname ].join(" ")
  end

  # generates a random number that is saved after a successful recurrent profile creation and used later 
  # to access the users recurrent profile in secure pay in order to make new payments or cancel the proile
  # this unique number (called Client ID in AU sequre pay gateway) should be less than 20 characters long
  # this method uses secure random number generator in combination with offset(unique) that makes the number unique
  # the generated number is 18 numbers long
  def generate_recurrent_profile_id
    time_offset = Time.now.to_i
    len = time_offset.size
    diff = 19 - len # size of the random number
    num = SecureRandom.random_number(10 ** diff).to_s + time_offset.to_s # time stamp makes the number unique
    num.to_i
  end
end
