require 'test_helper'

class GiftTest < ActiveSupport::TestCase
  should_have_and_belong_to_many :offers
end
