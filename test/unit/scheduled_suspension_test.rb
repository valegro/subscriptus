require 'test_helper'

class ScheduledSuspensionTest < ActiveSupport::TestCase
  should_belong_to :subscription
  should_validate_presence_of :start_date, :duration
end
