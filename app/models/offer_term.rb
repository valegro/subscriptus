class OfferTerm < ActiveRecord::Base
  # Use 0 to indicate forever
  TERM_OPTIONS = 0..60 #[0, 1, 3, 6, 12, 24]
  belongs_to :offer

  validates_presence_of :price, :months
  validates_numericality_of :price, :months
  validates_uniqueness_of :months, :scope => :offer_id
  validates_inclusion_of :months, :in => TERM_OPTIONS, :on => :create, :message => "must be between #{TERM_OPTIONS.first} and #{TERM_OPTIONS.last} months."
  default_scope :order => :months

  def expires?
    self.months > 0
  end
end
