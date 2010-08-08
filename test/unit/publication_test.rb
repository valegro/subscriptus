require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  should_have_many :offers
  should_have_many :subscriptions
  should_have_many :subscription_log_entries
end
