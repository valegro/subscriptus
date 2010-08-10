class Gift < ActiveRecord::Base
  has_and_belongs_to_many :offers
  has_attached_file :gift_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  validates_presence_of :name, :description, :on_hand
  validates_uniqueness_of :name
  validates_numericality_of :on_hand

  default_scope :order => :name

  after_destroy do |gift|
    # TODO: Admin Audit Log
    # TODO: Remove gift from all offers (or does this happen anyway?)
  end
end
