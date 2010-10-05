require File.dirname(__FILE__) + '/../spec_helper'

describe Subscription do
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
