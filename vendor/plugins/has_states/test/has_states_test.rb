require 'test/unit'

require 'rubygems'
require 'active_record'

$:.unshift File.dirname(__FILE__) + '/../lib'
require 'active_record/has_states'

require File.dirname(__FILE__) + '/../init'

class Test::Unit::TestCase
  def assert_in_state(record, attr_name, state, message = nil)
    assert record.send("#{state}?"), message || "state should be #{state} instead of #{record.send(attr_name)}"
  end
  
  def assert_not_in_state(record, attr_name, *states)
    assert ! states.any? { |state| record.send("#{state}?") }, "state should not be #{record.send(attr_name)}"
  end
  
  def assert_transition(record, attr_name, from, to)
    assert_in_state(record, attr_name, from)
    yield
    assert_in_state(record, attr_name, to, "state should have transitioned to #{to} instead of #{record.send(attr_name)}")
  end
  
  def assert_no_transition(record, attr_name)
    from = record.send(attr_name)
    yield
    assert_in_state(record.reload, attr_name, from, "state should not have transitioned from #{from} to #{record.send(attr_name)}")
  end
  
  def assert_includes(enum, value)
    assert enum.include?(value), "should include #{value}"
  end
  
  # def assert_queries(num = 1)
  #   $query_count = 0
  #   yield
  # ensure
  #   assert_equal num, $query_count, "#{$query_count} instead of #{num} queries were executed."
  # end
  # 
  # def assert_no_queries(&block)
  #   assert_queries(0, &block)
  # end
  
protected
  def setup_db
    stdout = $stdout

    # ActiveRecord::Base.logger
#    ActiveRecord::Base.logger = Logger.new(STDOUT)

    # AR keeps printing annoying schema statements
    $stdout = StringIO.new

    ActiveRecord::Schema.define(:version => 1) do
      create_table :tickets do |t|
        t.column :type, :string
        t.column :state, :string, :default => 'open'
        t.column :state_updated_at, :timestamp
        t.column :other_state, :string
        t.column :other_state_updated_at, :timestamp
        t.column :problem, :string
        t.column :resolution, :string
        t.column :assigned_to, :string
      end
    end
  ensure  
    $stdout = stdout
  end

  def teardown_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def create(klass, options = {})
    klass.create({ :problem => 'this is a problem' }.merge(options))
  end
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

class Ticket < ActiveRecord::Base
  validates_presence_of :problem
end

class TicketWithState < Ticket
  has_states :open, :ignored, :active, :abandoned, :resolved do
    on :ignore do
      transition :open => :ignored
    end
    on :activate do
      transition :open => :active
    end
    on :abandon do
      transition :active => :abandoned
    end
    on :resolve do
      transition :active => :resolved
    end
    on :reactivate do
      transition :resolved => :active, :abandoned => :active
    end
  end
end

class TicketWithOtherState < Ticket
  has_states :unassigned, :assigned, :in => :other_state do
    on :assign do
      transition :unassigned => :assigned
    end
    on :unassign do
      transition :assigned => :unassigned
    end
  end
end

class TicketWithConcurrentStates < Ticket
  has_states :open, :ignored, :active, :abandoned, :resolved do
    on :ignore do
      transition :open => :ignored
    end
    on :activate do
      transition :open => :active
    end
    on :abandon do
      transition :active => :abandoned
    end
    on :resolve do
      transition :active => :resolved
    end
    on :reactivate do
      transition :resolved => :active, :abandoned => :active
    end
  end

  has_states :unassigned, :assigned, :in => :other_state do
    on :assign do
      transition :unassigned => :assigned
    end
    on :unassign do
      transition :assigned => :unassigned
    end
  end
end

class TicketWithGuardedState < Ticket
  attr_accessor :first, :second, :third
  has_states :zero, :one, :two, :three do
    on :test do
      transition :zero => :one, :if => Proc.new { |record| record.first? }
      transition :zero => :two, :if => :second?
      transition :zero => :three, :if => "third?"
    end
  end
  def first?
    first
  end
  def second?
    second
  end
  def third?
    third
  end
end

class TicketWithCallbacks < Ticket
  attr_reader :callbacks_made
  
  has_states :open, :ignored, :active, :abandoned, :resolved do
    on :ignore do
      transition :open => :ignored
    end
    on :activate do
      transition :open => :active
    end
    on :abandon do
      transition :active => :abandoned
    end
    on :resolve do
      transition :active => :resolved
    end
    on :reactivate do
      transition :resolved => :active, :abandoned => :active
    end
  end

  after_enter_open :is_open
  before_exit_abandoned :will_not_be_abandoned
  before_enter_ignored :will_be_ignored
  after_exit_resolved :is_not_resolved
  after_enter_resolved :is_resolved

protected
  def remember_callback(which)
    @callbacks_made ||= {}
    @callbacks_made.merge!(which => self.dup)
  end

  def is_open
    remember_callback(:is_open)
  end
  
  def will_not_be_abandoned
    remember_callback(:will_not_be_abandoned)
  end

  def will_be_ignored
    remember_callback(:will_be_ignored)
  end

  def is_not_resolved
    remember_callback(:is_not_resolved)
  end

  def is_resolved
    remember_callback(:is_resolved)
  end
end

class TicketWithStateExpiration < Ticket
  has_states :open, :active, :stale, :abandoned do
    expires :open => :stale, :after => 30.days
    expires :stale => :abandoned, :after => 10.days
    on :activate do
      transition :open => :active
    end
    on :stale do
      transition :active => :stale
    end
  end
end

class BaseTest < Test::Unit::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_should_create
    ticket = create(Ticket)
    assert_not_nil ticket
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
  end
end

class StateTest < Test::Unit::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_should_require_unique_states
    assert_raises(ArgumentError) do
      Class.new(ActiveRecord::Base) do
        has_states :duplicate, :duplicate
      end
    end
  end

  def test_should_require_unique_events
    assert_raises(ArgumentError) do
      Class.new(ActiveRecord::Base) do
        has_states :one, :two, :three do
          on :duplicate
          on :duplicate
        end
      end
    end
  end
  
  def test_should_create_with_state
    ticket = create(TicketWithState)
    assert_not_nil ticket
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
    assert_in_state(ticket, :state, :open)
    assert_not_in_state(ticket, :state, :ignored, :active, :abandoned, :resolved)
  end
  
  def test_should_not_create_with_incorrect_state
    ticket = create(TicketWithState, :state => :resolved)
    assert_not_nil ticket
    assert ticket.new_record?
    assert_not_nil ticket.errors.on(:state)
    assert_not_in_state(ticket, :state, :resolved)
  end
  
  def test_should_not_create_with_invalid_state
    ticket = create(TicketWithState, :state => :invalid)
    assert_not_nil ticket
    assert ticket.new_record?
    assert_not_nil ticket.errors.on(:state)
  end
  
  def test_should_transition
    ticket = create(TicketWithState)
    assert_transition(ticket, :state, :open, :ignored) do
      assert ticket.ignore, ticket.errors.full_messages.to_sentence
    end
  end
  
  def test_should_transition_other_state
    ticket = create(TicketWithOtherState)
    assert_transition(ticket, :other_state, :unassigned, :assigned) do
      assert ticket.assign, ticket.errors.full_messages.to_sentence
    end
  end
  
  def test_should_prevent_invalid_transition
    ticket = create(TicketWithState)
    assert_no_transition(ticket, :state) do
      assert ! ticket.resolve
    end
    assert_not_nil ticket.errors.on(:state)
  end
  
  def test_should_prevent_invalid_transition_and_raise_error
    ticket = create(TicketWithState)
    assert_no_transition(ticket, :state) do
      assert_raises(ActiveRecord::RecordInvalid) do
        ticket.resolve!
      end
    end
    assert_not_nil ticket.errors.on(:state)
  end

  def test_should_detect_event_conflict
    ticket = create(TicketWithState)
    assert_no_transition(ticket, :state) do
      ticket.state = 'active'
      assert ! ticket.ignore
    end
    assert_not_nil ticket.errors.on(:state)
  end

  def test_should_use_first_transition
    ticket = create(TicketWithGuardedState, :state => 'zero', :first => true)
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
    assert_transition(ticket, :state, :zero, :one) do
      assert ticket.test, ticket.errors.full_messages.to_sentence
    end
  end
  
  def test_should_use_second_transition
    ticket = create(TicketWithGuardedState, :state => 'zero', :second => true, :third => true)
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
    assert_transition(ticket, :state, :zero, :two) do
      assert ticket.test, ticket.errors.full_messages.to_sentence
    end
  end
  
  def test_should_use_third_transition
    ticket = create(TicketWithGuardedState, :state => 'zero', :third => true)
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
    assert_transition(ticket, :state, :zero, :three) do
      assert ticket.test, ticket.errors.full_messages.to_sentence
    end
  end
  
  def test_should_fail_to_transition
    ticket = create(TicketWithGuardedState, :state => 'zero')
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
    assert_no_transition(ticket, :state) do
      assert ! ticket.test
    end
    assert_not_nil ticket.errors.on(:state)
  end
  
  def test_should_detect_transition
    ticket = create(TicketWithState)
    assert_transition(ticket, :state, :open, :active) do
      assert ticket.update_attributes(:state => 'active')
    end
  end
  
  def test_should_detect_invalid_transition
    ticket = create(TicketWithState)
    assert_no_transition(ticket, :state) do
      assert ! ticket.update_attributes(:state => 'abandoned')
    end
    assert_not_nil ticket.errors.on(:state)
  end
  
  def test_should_detect_invalid_transition_and_raise_error
    ticket = create(TicketWithState)
    assert_no_transition(ticket, :state) do
      assert_raises(ActiveRecord::RecordInvalid) do
        ticket.update_attributes!(:state => 'abandoned')
      end
    end
    assert_not_nil ticket.errors.on(:state)
  end
  
  def test_should_callback_before_exit
    ticket = create(TicketWithCallbacks)
    assert ! ticket.callbacks_made.blank?
    assert_equal 1, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :is_open
    assert ticket.activate, ticket.errors.full_messages.to_sentence
    assert_equal 1, ticket.callbacks_made.size
    assert ticket.abandon, ticket.errors.full_messages.to_sentence
    assert_equal 1, ticket.callbacks_made.size
    assert ticket.reactivate, ticket.errors.full_messages.to_sentence
    assert_equal 2, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :will_not_be_abandoned
  end
  
  def test_should_callback_before_enter
    ticket = create(TicketWithCallbacks)
    assert ! ticket.callbacks_made.blank?
    assert_equal 1, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :is_open
    assert ticket.ignore, ticket.errors.full_messages.to_sentence
    assert_equal 2, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :will_be_ignored
  end
  
  def test_should_callback_after_exit
    ticket = create(TicketWithCallbacks)
    assert ! ticket.callbacks_made.blank?
    assert_equal 1, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :is_open
    assert ticket.activate, ticket.errors.full_messages.to_sentence
    assert_equal 1, ticket.callbacks_made.size
    assert ticket.resolve, ticket.errors.full_messages.to_sentence
    assert_equal 2, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :is_resolved
    assert ticket.reactivate, ticket.errors.full_messages.to_sentence
    assert_equal 3, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :is_not_resolved
    assert_includes ticket.callbacks_made, :is_resolved
  end
  
  def test_should_callback_after_enter
    ticket = create(TicketWithCallbacks)
    assert ! ticket.callbacks_made.blank?
    assert_equal 1, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :is_open
    assert ticket.activate, ticket.errors.full_messages.to_sentence
    assert_equal 1, ticket.callbacks_made.size
    assert ticket.resolve, ticket.errors.full_messages.to_sentence
    assert_equal 2, ticket.callbacks_made.size
    assert_includes ticket.callbacks_made, :is_resolved
  end
end

class OtherStateTest < Test::Unit::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_should_create_with_other_state
    ticket = create(TicketWithOtherState)
    assert_not_nil ticket
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
    assert ticket.unassigned?
    assert ! ticket.assigned?
  end
end

class ConcurrentStatesTest < Test::Unit::TestCase
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_should_create_with_concurrent_states
    ticket = create(TicketWithConcurrentStates)
    assert_not_nil ticket
    assert ! ticket.new_record?, ticket.errors.full_messages.to_sentence
    assert ticket.open?
    assert ! (ticket.ignored? || ticket.active? || ticket.abandoned? || ticket.resolved?)
    assert ticket.unassigned?
    assert ! ticket.assigned?
  end
end

class ExpiredStatesTest < Test::Unit::TestCase

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_should_populate_state_changed_at_on_create
    ticket = TicketWithStateExpiration.create(:problem => "test")
    assert_not_nil ticket.state_updated_at
    assert ticket.state_updated_at < Time.now.utc
  end

  def test_correctly_define_expiration
    expiration_event = TicketWithStateExpiration.state_expiration_events[:state][:open]
    assert_not_nil expiration_event
    assert 30.days, expiration_event.expiry
    assert :open, expiration_event.from
    assert_not_nil expiration_event.transition
  end

  def test_should_correctly_save_updated_at
    ticket = create(TicketWithState)
    ticket.ignore
    assert_not_nil ticket.state_updated_at
    assert ticket.state_updated_at < Time.now.utc
  end

  def test_should_overwrite_updated_at
    ticket = create(TicketWithState)
    ticket.activate
    current_updated_at = ticket.state_updated_at
    ticket.abandon
    assert_not_equal current_updated_at, ticket.state_updated_at
  end

  def test_should_correctly_calculate_expiry
    ticket = create(TicketWithStateExpiration)
    ticket.activate
    ticket.update_attribute :state_updated_at, 31.days.ago
    assert ticket.open_state_expired?
    ticket.update_attribute :state_updated_at, 10.days.ago
    assert !ticket.open_state_expired?
  end

  def test_state_expired_name_should_should_return_results
    ticket = create(TicketWithStateExpiration)

    ticket.update_attribute :state_updated_at, 31.days.ago

    expired_records = TicketWithStateExpiration.with_expired_open_state.find(:all)
    assert expired_records.include?(ticket)

    ticket.update_attribute :state_updated_at, 29.days.ago
    expired_records = TicketWithStateExpiration.with_expired_open_state.find(:all)
    assert !expired_records.include?(ticket)
  end

  def test_should_automatically_expire_states
    ticket = create(TicketWithStateExpiration)
    ticket.update_attribute :state_updated_at, 31.days.ago
    assert ticket.open_state_expired?
    TicketWithStateExpiration.expire_states
    ticket.reload
    assert_equal "stale", ticket.state
  end


  def test_should_automatically_expire_states_with_multiple_expires
    ticket = create(TicketWithStateExpiration)
    ticket.activate
    ticket.stale
    ticket.update_attribute :state_updated_at, 11.days.ago
    assert ticket.stale_state_expired?
    TicketWithStateExpiration.expire_states
    ticket.reload
    assert_equal "abandoned", ticket.state
  end

  def test_should_not_automatically_expire_states_with_multiple_expires
    ticket = create(TicketWithStateExpiration)
    ticket.activate
    ticket.stale
    ticket.update_attribute :state_updated_at, 9.days.ago
    assert !ticket.stale_state_expired?
    TicketWithStateExpiration.expire_states
    ticket.reload
    assert_equal "stale", ticket.state
  end

end
