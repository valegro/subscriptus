class User < ActiveRecord::Base
  acts_as_authentic

  has_many :audit_log_entries
  has_many :subscriptions
  attr_accessor :email_confirmation

  enum_attr :title, %w(Dr Hon Lady Miss Mr Mrs Ms Prof Rev Sen Sir)
  enum_attr :state, %w(ACT NSW NT QLD SA TAS VIC WA INTL) do
    labels :INTL => "Outside of Australia"
  end

  validates_presence_of :firstname, :lastname, :email, :email_confirmation, :phone_number, :address_1, :city, :postcode, :state, :country
  validates_format_of   :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_confirmation_of :email_confirmation

  # generates a random number that is saved after a successful recurrent profile creation and used later 
  # to access the users recurrent profile in secure pay in order to make new payments or cancel the proile
  # this unique number (called Client ID in AU sequre pay gateway) should be less than 20 characters long
  # format: userId-offerId-random so that it is unique for each user and each offer
  def generate_recurrent_profile_id(offer_id)
    #FIXME: better way?!?!
    # rand(10000000000000000000)
    len = (self.id.to_s + offer_id.to_s).size
    if len > 19
      raise Exception::UnableToGenerateRecurrentId
    else
      diff = 20 - len # size of the random number
      max = "1"
      for i in 1...diff
        max += "0"
      end
      num = rand(max.to_f).to_s + self.id.to_s + offer.id.to_s
      num.to_i
    end
  end
end
