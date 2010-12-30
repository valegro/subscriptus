require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Factory.create(:subscription)
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    CM::Recipient.stubs(:create_or_update)
  end

  describe "upon expire!" do
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
