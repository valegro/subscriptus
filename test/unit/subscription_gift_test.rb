require 'test_helper'

class SubscriptionGiftTest < ActiveSupport::TestCase
  should_belong_to :gift
  should_belong_to :subscription
end
