class PaymentFailedException < StandardError; end

class Payment < ActiveRecord::Base
  belongs_to :subscription

  validates_presence_of :card_number, :card_expiry_date, :first_name, :last_name, :amount
  validates_numericality_of :amount, :greater_than_or_equal_to => 0

  attr_accessor :card_verification
  enum_attr :card_type, %w(visa master american_express diners_club jcb) #, :init=>visa

  def validate_on_create
    errors.add_to_base("Credit Card is not valid - check the details and try again") unless credit_card.valid?
  end

  before_save do |payment|
    # Set the price
    payment.amount = payment.subscription.price

    # Charge the card
    response = GATEWAY.purchase((payment.amount * 100).to_i, payment.credit_card,
      :order_id => "123", # FIXME
      :address => (payment.subscription.try(:user).try(:address_hash) || {}),
      :description => 'Crikey Subscription Payment',
      :email => payment.subscription.try(:user).try(:email)
    )
    unless response.success?
      raise PaymentFailedException.new(response.message)
    end
    # Save a reference
    payment.card_number = "XXXX-XXXX-XXXX-#{payment.card_number[-4..-1]}"
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      :type       => card_type.to_s,
      :number     => self.card_number,
      :month      => self.card_expiry_date.try(:month),
      :year       => self.card_expiry_date.try(:year),
      :first_name => self.first_name,
      :last_name  => self.last_name,
      :verification_value  => self.card_verification
    )
  end
end
