require 'test_helper'

class OfferTest < ActiveSupport::TestCase
  should_belong_to :publication
  should_have_many :subscriptions, :offer_terms
  should_have_many :gift_offers
end
