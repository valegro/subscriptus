require File.dirname(__FILE__) + '/../spec_helper'

describe Subscription do
  describe "class def" do
    it "should return per page" do
      Subscription.per_page.should == 20
    end
  end
end
