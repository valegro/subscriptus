require 'test_helper'

class SubscriptionLogEntryTest < ActiveSupport::TestCase
  should_belong_to :source
  should_belong_to :subscription
  should_belong_to :publication
end
