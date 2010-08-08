require 'test_helper'

class AuditLogEntryTest < ActiveSupport::TestCase
  should_belong_to :user
end
