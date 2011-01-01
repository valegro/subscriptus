require 'spec_helper'

describe Subscription do

  before(:each) do
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
  end

  describe "upon save" do
    it "should create a recipient in Campaign Master" do
      s = Factory.create(:subscription)
      s.expects(:send_later).with(:sync_to_campaign_master)
      s.save!
    end
  end

  describe "upon verify!" do
    before(:each) do
      @subscription = Factory.create(:subscription, :state => 'pending')
    end

    it "should create a log entry" do
      @subscription.log_entries.size.should == 1
      @subscription.verify!
      @subscription.log_entries.size.should == 2
      entry = @subscription.log_entries.last
      entry.new_state.should == 'active'
    end

    it "should deliver an email" do
      SubscriptionMailer.expects(:send_later).with(:deliver_activation, @subscription)
      @subscription.verify!
    end
  end

  describe "upon activate!" do
    before(:each) do
      @subscription = Factory.create(:subscription, :state => 'trial')
    end

    it "should create a log entry" do
      @subscription.log_entries.size.should == 1
      @subscription.activate!
      @subscription.log_entries.size.should == 2
      # TODO: Check the values inside the logs
    end

    it "should deliver an email" do
      SubscriptionMailer.expects(:send_later).with(:deliver_activation, @subscription)
      @subscription.activate!
    end

    # TODO: Process a payment - when calling activate, a payment should be processed somehow
    # TODO: Set expires_at
  end

  describe "upon expire!" do
    before(:each) do
      @subscription = Factory.create(:subscription, :state => 'active')
    end

    it "should create a log entry" do
      @subscription.log_entries.size.should == 1
      @subscription.expire!
      @subscription.log_entries.size.should == 2
      entry = @subscription.log_entries.last
      entry.new_state.should == 'squatter'
    end

    it "should deliver an email" do
      pending
    end
  end

end
