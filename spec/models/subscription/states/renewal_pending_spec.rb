require 'spec_helper'

describe Subscription do

  before(:each) do
    Timecop.freeze("2011-01-10".to_time)
    stub_wordpress
    success = stub(:success? => true, :params => { "ponum" => '1234' })
    GATEWAY.stubs(:trigger_recurrent).returns(success)
    @subscription_action = Factory.create(:subscription_action, :payment => Factory.create(:token_payment))
    @subscription_action.gifts << Factory.create(:gift)
    @subscription = Factory.build(
      :pending_subscription,
      :state => 'renewal_pending',
      :expires_at => 25.days.from_now,
      :state_expires_at => 25.days.from_now,
      :pending => :payment,
      :pending_action => @subscription_action
    )
    @subscription_action.subscription = nil
    @subscription.save!
  end

  after(:each) do
    Timecop.return
  end

  it "should expire when the expiry data passes" do
    @subscription.state.should == 'renewal_pending'
    Timecop.travel(26.days.from_now) do
      @subscription.expired?.should be(true)
      @subscription.expire!
      @subscription.state.should == 'pending'
    end
  end

  describe "upon expire!" do
    it "should create a log entry"

    it "the state should be pending" do
      @subscription.expire!
      @subscription.state.should == 'pending'
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

  describe "upon verify!" do
    it "should be active" do
      @subscription.verify!
      @subscription.state.should == 'active'
    end

    it "should should set the expiry date appropriately" do
      @subscription.verify!
      @subscription.expires_at.utc.should == 25.days.from_now.utc.advance(:months => @subscription_action.term_length)
      @subscription.state_expires_at.utc.should == 25.days.from_now.utc.advance(:months => @subscription_action.term_length)
    end

    it "should should set the state_updated_at to now" do
      @subscription.verify!
      @subscription.state_updated_at.should == Time.now
    end

    it "should set pending to nil" do
      @subscription.verify!
      @subscription.pending.should be(nil)
    end

    it "should deliver an email" do
      stub_mailer(SubscriptionMailer).expects(:deliver_verified).with(@subscription)
      stub_mailer(SubscriptionMailer).expects(:deliver_activation).with(@subscription)
      @subscription.verify!
    end

    it "should apply an action" do
      @subscription.expects(:apply_action).with(@subscription.pending_action)
      @subscription.verify!
      @subscription.pending_action.should be(nil)
    end

    it "should create a gift order if gifts were present" do
      expect {
        @subscription.verify!
      }.to change { Order.count }.by(1)
    end
  end
end
