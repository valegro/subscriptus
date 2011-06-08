
require 'spec_helper'

describe Subscription do
  before(:each) do
    Timecop.freeze("2011-01-10".to_time)
    stub_wordpress
    @subscription = Factory.create(:subscription, :state => 'suspended', :expires_at => 25.days.from_now, :state_expires_at => 25.days.from_now)
  end

  after(:each) do
    Timecop.return
  end

  it "should automatically unsuspend a subscription that has passed its state expiry date" do
    @subscription.state.should == 'suspended'
    @subscription.state_expires_at.should == 25.days.from_now
    Timecop.travel(26.days.from_now) do
      Subscription.expire_states
      @subscription.reload
      @subscription.state.should == 'active'
    end
  end

  describe "upon unsuspend" do
    before(:each) do
      @subscription.state_expires_at.should == 25.days.from_now
    end

    it "should create a log entry" do
      expect {
        @subscription.unsuspend!
      }.to change { @subscription.log_entries.count }.by(1)
      entry = @subscription.log_entries.last
      entry.new_state.should == 'active'
    end

    it "should set the state to active" do
      SubscriptionMailer.expects(:send_later).with(:deliver_unsuspended, @subscription)
      @subscription.unsuspend!
      @subscription.state.should == 'active'
    end
  end
end
