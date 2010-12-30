require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Factory.create(:subscription)
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    CM::Recipient.stubs(:create_or_update)
  end

  describe "upon activate!" do
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

end
