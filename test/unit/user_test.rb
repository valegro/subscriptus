require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should_have_many :subscriptions
  should_have_many :audit_log_entries
end
