require 'spec_helper'

# TODO: Timed state changes using expire_states!
# TODO: Test invalid state transitions - probably in subscription_spec.rb as its generic
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

  it "should expire when the expiry data passes" do
    @subscription.state.should == 'active'
    Timecop.travel(26.days.from_now) do
      @subscription.expired?.should be(true)
      @subscription.expire!
      @subscription.state.should == 'squatter'
    end
  end

  it "should expire all active subs that have passed their expiry date" do
    5.times { Factory.create(:subscription, :state => 'active', :expires_at => 1.day.ago) }
    Subscription.active.count.should == 6 # (Including the one in the before block)
    Subscription.expire_active_subscribers
    Subscription.active.count.should == 1
  end

  describe "upon expire!" do
    before(:each) do
      SubscriptionMailer.expects(:send_later).with(:deliver_expired, @subscription)
    end

    it "should create a log entry" do
      expect {
        @subscription.expire!
      }.to change { @subscription.log_entries.count }.by(1)
      entry = @subscription.log_entries.last
      entry.new_state.should == 'squatter'
    end

    it "the state should be squatter" do
      @subscription.expire!
      @subscription.state.should == 'squatter'
    end
  end

  describe "upon suspend!" do
    before(:each) do
      SubscriptionMailer.expects(:send_later).with(:deliver_suspended, @subscription)
    end

    it "should create a log entry" do
      expect {
        @subscription.suspend!(10)
      }.to change { @subscription.log_entries.count }.by(1)
      entry = @subscription.log_entries.last
      entry.new_state.should == 'suspended'
    end

    it "should set the state to suspended" do
      @subscription.suspend!(10)
      @subscription.state.should == 'suspended'
    end

    it "should increase the expiry date" do
      expect {
        @subscription.suspend!(10)
      }.to change { @subscription.expires_at }.by(10.days)
    end
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
