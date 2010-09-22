class User < ActiveRecord::Base
  acts_as_authentic

  has_many :audit_log_entries
  has_many :subscriptions
  attr_accessor :email_confirmation

  enum_attr :title, %w(Dr Hon Lady Miss Mr Mrs Ms Prof Rev Sen Sir)
  enum_attr :state, %w(ACT NSW NT QLD SA TAS VIC WA INTL) do
    labels :INTL => "Outside of Australia"
  end

  validates_presence_of :firstname, :lastname, :email, :phone_number, :address_1, :city, :postcode, :state, :country
  validates_format_of   :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def validate
    if self.email_confirmation.blank?
      errors.add_to_base("Must provide email confirmation")
    end
    unless self.email == self.email_confirmation
      errors.add_to_base("Email does not match confirmation")
    end
  end
  
  # generates a random number that is saved after a successful recurrent profile creation and used later 
  # to access the users recurrent profile in secure pay in order to make new payments or cancel the proile
  # this unique number (called Client ID in AU sequre pay gateway) should be less than 20 characters long
  def self.generate_recurrent_profile_id
    #FIXME: keys should be unique as well
    rand(10000000000000000000)
  end
end
