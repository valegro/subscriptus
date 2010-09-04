class Offer < ActiveRecord::Base
  belongs_to :publication
  has_many :subscriptions
  has_many :gift_offers, :dependent => :destroy
  has_many :gifts, :through => :gift_offers do
    def add(gift, optional = false)
      proxy_owner.gift_offers.create(:gift => gift, :included => !optional)
    end
  end

  has_many :offer_terms
  accepts_nested_attributes_for :offer_terms

  validates_presence_of :name, :publication
  validates_uniqueness_of :name

  def available_included_gifts
    result = gifts.in_stock.included
    if gifts.in_stock.optional.size == 1
      result << gifts.in_stock.optional.first
    end
    result
  end
end
