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
end
