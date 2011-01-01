require 'spec_helper'

describe Subscription do

  before(:each) do
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)

    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
  end

  describe "upon save when recipient exists in CM" do
    it "should update recipient in Campaign Master" do
      CM::Recipient.stubs(:exists?).returns(true)
      s = Factory.create(:subscription)
      CM::Recipient.expects(:update)
      s.sync_to_campaign_master
    end
  end

  describe "upon save when recipient does not exist in CM" do
    it "should create recipient in Campaign Master" do
      CM::Recipient.stubs(:exists?).returns(false)
      s = Factory.create(:subscription)
      CM::Recipient.expects(:create!)
      s.sync_to_campaign_master
    end
  end

  it "should log error if create fails" do
    pending
    #s = Factory.create(:subscription)
    #cm_return = stub(:success? => true)
    #cm_return.expects(:has_key?).with(:recipients).returns(false)
    #CM::Recipient.stubs(:find_all).returns(cm_return)
    #CM::Recipient.expects(:update).raises("spam")
    #CM::Proxy.expects(:log_cm_error)
    #s.sync_to_campaign_master
  end

end


