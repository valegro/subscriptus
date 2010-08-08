require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  should_have_many :subscription_log_entries
end
