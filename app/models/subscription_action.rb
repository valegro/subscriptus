class SubscriptionAction < ActiveRecord::Base
  belongs_to :source
  belongs_to :subscription

  has_many :subscription_gifts, :dependent => :destroy
  has_one  :payment
  has_many :gifts,
           :through => :subscription_gifts,
           :uniq => true,
           :before_add => Proc.new { |a, gift| raise "Gift is out of stock" unless gift.in_stock? }

  validates_presence_of :offer_name, :term_length

  named_scope :recent, :order => "applied_at desc"
end
