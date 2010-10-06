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
  validates_confirmation_of :email

  after_create :add_to_campaignmaster
  after_update :update_campaignmaster

  def add_to_campaignmaster
    update_cm(:create!)
  end

  def update_campaignmaster
    update_cm(:update)
  end

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

  def fullname
    name
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

end
