class Gift < ActiveRecord::Base
  has_many :gift_offers, :dependent => :destroy
  has_many :offers, :through => :gift_offers
  has_many :orders
  has_attached_file :gift_image,
    :styles => { :medium => "350x350>", :thumb => "100x100>" },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :path => ":attachment/:id/:style.:extension",
    :bucket => 'crikeystaging'

  validates_presence_of :name, :description, :on_hand
  validates_uniqueness_of :name
  validates_numericality_of :on_hand

  default_scope :order => :name
  named_scope :in_stock, :conditions => "on_hand > 0"
  # named_scope :optional, :conditions => "included = false"
  # named_scope :included, :conditions => "included = true"
  named_scope :optional, :conditions => { "gift_offers.included" => false }
  named_scope :included, :conditions => { "gift_offers.included" => true }

  after_destroy do |gi55|
    # TODO: Admin Audit Log
    # TODO: Remove gift from all offers (or does this happen anyway?)
  end
end
