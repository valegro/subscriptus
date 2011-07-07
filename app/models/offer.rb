class Offer < ActiveRecord::Base
  belongs_to :publication
  has_many :subscriptions #, :after_add => Proc.new { |o, s| puts "Adding #{s.inspect} to offer" }
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

  named_scope :for_publication, lambda { |publication_id| { :conditions => { :publication_id => publication_id } } }
  default_scope :order => "name"

  def available_included_gifts
    result = gifts.in_stock.included
    # include the optional gift if there is only one!
    if gifts.in_stock.optional.size == 1
      result << gifts.in_stock.optional.first
    end
    result
  end
  
  # shows whether the current offer is a trial or a full paid offer
  def is_trial?
    self.trial
  end

  def make_primary!
    self.class.transaction do
      self.class.update_all "primary_offer = 'false'"
      self.update_attributes!(:primary_offer => true)
    end
  end

  def self.primary_offer
    self.find(:first, :conditions => { :primary_offer => true }) || self.first
  end
end
