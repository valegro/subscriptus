
require 'spec_helper'

describe Subscription do
  before(:each) do
    Timecop.freeze("2011-01-10".to_time)
    stub_wordpress
    @subscription = Factory.build(:subscription, :state => 'active', :expires_at => 25.days.from_now)
    @subscription.save!
  end

  after(:each) do
    Timecop.return
  end

  describe "upon unsuspend" do
    before(:each) do
      SubscriptionMailer.expects(:send_later).with(:deliver_suspended, @subscription)
      @subscription.state = "suspended"
      @subscription.save!
      SubscriptionMailer.expects(:send_later).with(:deliver_unsuspended, @subscription)
    end

    it "should create a log entry" do
      expect {
        @subscription.unsuspend!
        p @subscription.log_entries
      }.to change { @subscription.log_entries.count }.by(1)
      entry = @subscription.log_entries.last
      entry.new_state.should == 'active'
    end

    it "should set the state to active" do
      @subscription.unsuspend!
      @subscription.state.should == 'active'
    end
  end
end
