require 'spec_helper'

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

  it "should automatically expire a subscription that has passed its expiry date" do
    @subscription.state.should == 'active'
    @subscription.state_expires_at.should == 25.days.from_now
    Timecop.travel(26.days.from_now) do
      Subscription.expire_states
      @subscription.reload
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

    it "should set state_expires_at to nil" do
      @subscription.expire!
      @subscription.state_expires_at.should be(nil) 
    end

    it "should not change expires_at" do
      expect {
        @subscription.expire!
      }.to_not change { @subscription.expires_at }
    end
  end

  describe "upon suspend!" do
    before(:each) do
      stub_mailer(SubscriptionMailer).expects(:deliver_suspended).with(@subscription)
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

    it "should set state_expires_at" do
      @subscription.suspend!(10)
      @subscription.state_expires_at.time.should == 10.days.from_now
      @subscription.state_expires_at.time.should_not == @subscription.expires_at
    end
  end

  # Goes into a pending state on renewal
  describe "on postpone" do
    before(:each) do
      @subscription.pending = :payment
      stub_mailer(SubscriptionMailer).expects(:deliver_pending_payment).with(@subscription)
    end

    it "should set the state to suspended" do
      @subscription.postpone!
      @subscription.state.should == 'renewal_pending'
    end

    it "should not change state_expires_at" do
      expect {
        @subscription.postpone!
      }.to_not change { @subscription.state_expires_at }
    end

    it "should not change expires_at" do
      expect {
        @subscription.postpone!
      }.to_not change { @subscription.expires_at }
    end

    it "should have a pending action"
  end
end
