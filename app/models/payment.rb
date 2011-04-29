
class Payment < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  belongs_to :subscription_action

  validates_presence_of :card_number, :card_expiry_date, :first_name, :last_name, :if => Proc.new { |payment| payment.credit_card? }
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than_or_equal_to => 0

  attr_accessor :card_verification

  enum_attr :card_type, %w(visa master american_express diners_club jcb)
  enum_attr :payment_type, %w(credit_card token direct_debit cheque), :init => :credit_card

  default_scope :order => "created_at desc"

  def validate_on_create
    if credit_card? && !credit_card.valid?
      errors.add_to_base("Credit Card is not valid - check the details and try again")
    end
  end

  before_save do |payment|
    if payment.credit_card? || payment.payment_type.nil?
      # Save a reference
      payment.card_number = "XXXX-XXXX-XXXX-#{payment.card_number[-4..-1]}"
    end
  end

  # Process and save the payment
  # Only valid option is :token (to be used for token payments)
  def process!(options = {})
    raise ActiveRecord::RecordInvalid.new(self) unless self.valid?
    if (self.credit_card? || self.payment_type.nil?) && !new_record?
      raise Exceptions::PaymentAlreadyProcessed.new("You are trying to process a Credit Card payment that has already been saved - consider using a token payment")
    end
    raise Exceptions::PaymentAlreadyProcessed if processed_at
    if self.credit_card? || self.payment_type.nil?
      # Charge the card
      response = GATEWAY.purchase((amount * 100).to_i, self.credit_card,
        :order_id => "123", # FIXME
        :address => (self.subscription_action.try(:subscription).try(:user).try(:address_hash) || {}),
        :description => 'Crikey Subscription Payment',
        :email => self.subscription_action.try(:subscription).try(:user).try(:email)
      )
      unless response.success?
        raise Exceptions::PaymentFailedException.new(response.message)
      end
    end
    if self.token?
      raise Exceptions::PaymentTokenMissing if options[:token].blank?
      response = GATEWAY.trigger_recurrent((amount * 100).to_i, options[:token])
      # TODO: Not DRY
      unless response.success?
        raise Exceptions::PaymentFailedException.new(response.message)
      end
    end
    processed_at = Time.now
    self.save!
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

  def description
    returning str = [ number_to_currency(amount), payment_type.to_s.humanize ].join(" by ") do
      str << " (Ref: #{reference})" if reference
    end
  end
end

