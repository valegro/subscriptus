class Offer < ActiveRecord::Base
  belongs_to :publication
  has_many :subscriptions
  has_and_belongs_to_many :gifts
end
