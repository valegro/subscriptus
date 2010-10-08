require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Subscription.new()
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
  end

  # tests on get_new_expiry_date method ----------------
  it "should set expiry_date to 3 months from now if the expiry date has aleady been passed" do
    months = 3
    @subscription.expires_at = Date.new(2010, 1, 1)
    expected = Date.new(2010, 12, 27)
    @subscription.set_expires_at(months)
    @subscription.expires_at.year.should == expected.year
    @subscription.expires_at.month.should == expected.month
    @subscription.expires_at.day.should == expected.day
  end

  it "should set expiry_date to 3 months from the end of current expiry date" do
    months = 3
    @subscription.expires_at = Date.new(2010, 10, 4)
    expected = Date.new(2011, 1, 4)
    @subscription.set_expires_at(months)
    @subscription.expires_at.year.should == expected.year
    @subscription.expires_at.month.should == expected.month
    @subscription.expires_at.day.should == expected.day
  end

  it "should set expiry_date to 3 months from now if no expiry date has been set yet" do
    months = 3
    expected = Date.new(2010, 12, 27)
    @subscription.set_expires_at(months)
    @subscription.expires_at.year.should == expected.year
    @subscription.expires_at.month.should == expected.month
    @subscription.expires_at.day.should == expected.day
  end
end