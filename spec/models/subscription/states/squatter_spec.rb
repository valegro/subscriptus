require 'spec_helper'

describe Subscription do

  before(:each) do
    stub_wordpress
  end

  describe "upon activate!" do
    before(:each) do
      @subscription = Factory.create(:subscription, :state => 'squatter')
    end

    it "should create a log entry" do
      expect {
        @subscription.activate!
      }.to change { @subscription.log_entries.size }.by(1)
    end

    it "should set both expires_at and state_expires_at" do
      @time = "2011-03-03".to_time(:utc)
      Timecop.freeze(@time) do
        @subscription.increment_expires_at(10)
        @subscription.expires_at.time.should == @time.advance(:months => 10)
        @subscription.activate!
        @subscription = Subscription.find(@subscription.id)
        @subscription.state_expires_at.time.should == @subscription.expires_at.time
      end
    end
  end
end
