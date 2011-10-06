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

      # overlap on the left
      ss4 = ScheduledSuspension.new(:start_date => Date.today - 1, :duration => 3, :subscription_id => subscription.id)
      ss4.should_not be_valid

      # adjacent on the left
      ss5 = ScheduledSuspension.new(:start_date => Date.today - 3, :duration => 3, :subscription_id => subscription.id)
      ss5.should_not be_valid

      # adjacent on the right
      ss6 = ScheduledSuspension.new(:start_date => Date.today + 3, :duration => 5, :subscription_id => subscription.id)
      ss6.should_not be_valid

      # no overlap
      ss7 = ScheduledSuspension.new(:start_date => Date.today + 4, :duration => 5, :subscription_id => subscription.id)
      ss7.should be_valid

      # no overlap because it's for a different subscription
      subscription2 = Factory.create(:active_subscription)
      ss8 = ScheduledSuspension.new(:start_date => Date.today, :duration => 3, :subscription_id => subscription2.id)
      ss8.should be_valid
    end
  end

  it "should activate if it spans today" do
    Timecop.freeze(Date.today)
    ss = Factory.create(:scheduled_suspension, :start_date => Date.today, :duration => 1, :active => false)
    ss.subscription.should_not be_suspended
    ss.should_not be_active
    ScheduledSuspension.process!
    ss.reload
    ss.subscription.should be_suspended
    ss.should be_active
  end


  it "should deactivate if it's active and expired" do
    ss = nil
    Timecop.freeze(Date.today - 2) do
      ss = Factory.create(:scheduled_suspension, :start_date => Date.today, :duration => 2, :active => false)
      ScheduledSuspension.process!
      ss.reload
      ss.subscription.should be_suspended
      ss.should be_active
    end
    ScheduledSuspension.process!
    ss.reload
    ss.subscription.should_not be_suspended
    ss.should_not be_active
  end
end
