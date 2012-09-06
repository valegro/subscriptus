class GiftOffer < ActiveRecord::Base
  belongs_to :gift
  belongs_to :offer
end
