class OfferTerm < ActiveRecord::Base
  TERM_OPTIONS = [1, 3, 6, 12]
  belongs_to :offer

  validates_presence_of :price, :months
  validates_numericality_of :price, :months
  validates_uniqueness_of :months, :scope => :offer_id
end
