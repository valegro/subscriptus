require 'spec_helper'

describe Subscription do

  before(:each) do
    @subscription = Subscription.new()
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.any_instance.stubs(:today).returns(today)
  end

  # tests on get_new_expiry_date method ----------------
  it "should set expiry_date to 3 months from now if the expiry date has aleady been passed" do
    months = 3
    expiry_date = Date.new(2010, 1, 1)
    expected = Date.new(2010, 12, 27)
    @subscription.get_new_expiry_date(months).should == expected
  end

  it "should set expiry_date to 3 months from the end of current expiry date" do
    months = 3
    @subscription.expires_at = Date.new(2010, 10, 4)
    expected = Date.new(2011, 1, 4)
    @subscription.get_new_expiry_date(months).year.should == expected.year
    @subscription.get_new_expiry_date(months).month.should == expected.month
    @subscription.get_new_expiry_date(months).day.should == expected.day
  end

  it "should set expiry_date to 3 months from now if no expiry date has been set yet" do
    months = 3
    expected = Date.new(2010, 12, 27)
    @subscription.get_new_expiry_date(months).should == expected
  end

  describe "class def" do
    it "should return per page" do
      Subscription.per_page.should == 20
    end
  end
  describe "with named scopes" do
    before(:each) do
      Factory.create(:subscription)
      Factory.create(:subscription)
    end
    it "should have named_scope ascend_by_name" do
      subs = Subscription.ascend_by_name
      # XXX: the DBMS's sorting and ruby's sorting might use different algorithms!
      subs[0].user.fullname.should <= subs[1].user.fullname
    end
    it "should have named_scope descend_by_name" do
      subs = Subscription.descend_by_name
      # XXX: the DBMS's sorting and ruby's sorting might use different algorithms!
      subs[0].user.fullname.should >= subs[1].user.fullname
    end
  end
end