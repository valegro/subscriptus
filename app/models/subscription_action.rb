class SubscriptionAction < ActiveRecord::Base
  belongs_to :source
  belongs_to :subscription

  has_many :subscription_gifts, :dependent => :destroy
  has_one  :payment, :autosave => true
  has_many :gifts,
           :through => :subscription_gifts,
           :uniq => true,
           :before_add => Proc.new { |a, gift| raise "Gift is out of stock" unless gift.in_stock? }

  validates_presence_of :offer_name, :term_length

  named_scope :recent, :order => "applied_at desc"

  define_callbacks :after_apply

  def apply
    raise "No Subscription Set" if self.subscription.blank?
    self.class.transaction do
      self.subscription.increment_expires_at(self.term_length)
      payment.process!(:token => subscription.user.try(:payment_gateway_token))
      subscription.save!
      callback(:after_apply)
    end
  end
end
