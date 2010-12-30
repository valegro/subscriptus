require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Factory.create(:subscription, :state => 'pending')
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    CM::Recipient.stubs(:create_or_update)
  end

  describe "upon verify!" do
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

end
