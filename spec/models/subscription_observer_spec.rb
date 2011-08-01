require 'spec_helper'

describe SubscriptionObserver do
  before(:each) do
    stub_wordpress
    @start_time = "2011-01-01".to_time
    Timecop.freeze(@start_time)
    @subscriber = Factory.create(:subscriber)
    @subscription = Factory.create(:expiring_subscription, :user => @subscriber)

    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
  end
  describe 'using delayed job' do
    before(:each) do
      @subscription.user.stubs(:delay).returns(@delay = mock('delay'))
    end

    it 'should call sync_to_wordpress on the user when a @subscription state changes' do
      @delay.expects(:sync_to_wordpress).twice
      @subscription.activate!
      @subscription.suspend!(10)
    end

    it 'should not call sync_to_wordpress on the user when a @subscription is updated without state change' do
      @delay.expects(:sync_to_wordpress).never
      @subscription.update_attributes(:state_expires_at => 3.weeks.from_now)
    end
  end
end