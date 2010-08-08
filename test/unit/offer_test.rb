require 'test_helper'

class OfferTest < ActiveSupport::TestCase
  should_belong_to :publication
  should_have_many :subscriptions
  should_have_and_belong_to_many :gifts
end
