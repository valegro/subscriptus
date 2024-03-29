require 'spec_helper'

describe ScheduledSuspension do
  before(:each) do
    stub_wordpress
  end

  describe "class definition" do
    it { should belong_to :subscription }
    it { should validate_presence_of :start_date }
    it { should validate_presence_of :duration }
    it { should validate_numericality_of :duration }
    it "should not allow overlapping scheduled suspensions for the same subscription" do
      Timecop.freeze(Date.today)

      subscription = Factory.create(:active_subscription)

      ss1 = ScheduledSuspension.new(:start_date => Date.today, :duration => 3, :subscription_id => subscription.id)
      ss1.should be_valid
      ss1.save!
      ss1.reload
      ss1.should be_valid # shouldn't overlap with itself

      # overlap on the right
      ss2 = ScheduledSuspension.new(:start_date => Date.today + 1, :duration => 3, :subscription_id => subscription.id)
      ss2.should_not be_valid

      # overlap within
      ss3 = ScheduledSuspension.new(:start_date => Date.today + 1, :duration => 1, :subscription_id => subscription.id)
      ss3.should_not be_valid

      # overlap outside
      ss4 = ScheduledSuspension.new(:start_date => Date.today - 1, :duration => 5, :subscription_id => subscription.id)
      ss4.should_not be_valid

      # overlap on the left
      ss5 = ScheduledSuspension.new(:start_date => Date.today - 1, :duration => 3, :subscription_id => subscription.id)
      ss5.should_not be_valid

      # adjacent on the left
      ss6 = ScheduledSuspension.new(:start_date => Date.today - 3, :duration => 3, :subscription_id => subscription.id)
      ss6.should_not be_valid

      # adjacent on the right
      ss7 = ScheduledSuspension.new(:start_date => Date.today + 3, :duration => 5, :subscription_id => subscription.id)
      ss7.should_not be_valid

      # no overlap
      ss8 = ScheduledSuspension.new(:start_date => Date.today + 4, :duration => 5, :subscription_id => subscription.id)
      ss8.should be_valid

      # no overlap because it's for a different subscription
      subscription2 = Factory.create(:active_subscription)
      ss9 = ScheduledSuspension.new(:start_date => Date.today, :duration => 3, :subscription_id => subscription2.id)
      ss9.should be_valid
    end
  end

  it "should activate and suspend if it spans today and the subscription is active" do
    Timecop.freeze(Date.today)
    ss = Factory.create(:scheduled_suspension, :start_date => Date.today, :duration => 1)
    ss.should be_queued
    ss.subscription.should_not be_suspended
    ScheduledSuspension.process!
    ss.reload
    ss.should be_active
    ss.subscription.should be_suspended
  end

  it "should activate but not suspend if it spans today and the subscription is already suspended" do
    Timecop.freeze(Date.today)
    ss = Factory.create(:scheduled_suspension, :start_date => Date.today, :duration => 1)
    ss.should be_queued
    ss.subscription.should_not be_suspended
    ss.subscription.suspend!(10)
    ss.subscription.should be_suspended
    ScheduledSuspension.process!
    ss.reload
    ss.should be_active
    ss.subscription.should be_suspended
    ss.subscription.state_expires_at.should be > (Date.today + 1)
    Timecop.freeze(Date.today + 3) do
      Subscription.expire_states
      ScheduledSuspension.expire_states
      ScheduledSuspension.process!
      ss.reload
      ss.should be_complete
      ss.subscription.should be_suspended
    end
  end

  it "should deactivate if it's active and expired" do
    ss = nil
    Timecop.freeze(Date.today - 3) do
      ss = Factory.create(:scheduled_suspension, :start_date => Date.today, :duration => 2)
      ss.should be_queued
      ScheduledSuspension.process!
      ss.reload
      ss.subscription.should be_suspended
      ss.should be_active
    end

    Subscription.expire_states
    ScheduledSuspension.expire_states
    ss.reload
    ss.subscription.should_not be_suspended
    ss.should be_complete
  end

  it "should deactivate if it's queued and obsolete" do
    ss = nil
    Timecop.freeze(Date.today - 10) do
      ss = Factory.create(:scheduled_suspension, :start_date => Date.today, :duration => 2)
      ss.should be_queued
      ss.subscription.should_not be_suspended
    end
    Subscription.expire_states
    ScheduledSuspension.expire_states
    ScheduledSuspension.process!
    ss.reload
    ss.subscription.should_not be_suspended
    ss.should be_complete
  end

end
