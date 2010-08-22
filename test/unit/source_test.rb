require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  should_have_many :subscription_log_entries
  should_validate_presence_of :code, :description
end
