require File.dirname(__FILE__) + '/../spec_helper'

describe SubscriptionObserver do
  before(:each) do
    @sub = mock('@sub')
    @subob = SubscriptionObserver.instance
  end
  it "should send_later update_campaignmaster in after update" do
    @sub.expects(:send_later).with(:update_campaignmaster)
    @subob.after_update(@sub)
  end
  it "should send_later update_campaignmaster in after create" do
    @sub.expects(:send_later).with(:update_campaignmaster)
    @subob.after_create(@sub)
  end
end
