require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  should_belong_to :offer
  should_belong_to :user
  should_belong_to :publication
  should_have_many :subscription_log_entries
  should_have_many :subscription_gifts
end
