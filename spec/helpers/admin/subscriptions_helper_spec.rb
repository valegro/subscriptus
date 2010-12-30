require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscriptionsHelper do
  include Admin::SubscriptionsHelper

  describe "state change" do
    it "should show state transitions" do
      @subscription = Factory.create(:subscription)
      state_change('trial', 'active', @subscription).should == 'Trial -> Active'
      state_change('active', 'squatter', @subscription).should == 'Active -> Squatter'
    end

    it "should show new states on creation" do
      @subscription = Factory.create(:subscription)
      state_change(nil, 'active', @subscription).should == 'New Active'
    end

    it "should show no change when no state has changed" do
      @subscription = Factory.create(:subscription)
      state_change(nil, nil, @subscription).should == 'No Change (Trial)'
    end

    it "should show renewal when no change and state is active" do
      @subscription = Factory.create(:subscription, :state => 'active')
      state_change(nil, nil, @subscription).should == 'Renewal'
    end

  end
end
