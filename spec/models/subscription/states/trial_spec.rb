require 'spec_helper'

describe Subscription do

  before(:each) do
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    stub_wordpress
  end

  describe "a trial subscription" do
    before(:each) do
      @json_hash = { "last_name"=>["Draper"], "first_name"=>["Daniel"], "email"=>["example@example.com"], "ip_address"=>"150.101.226.181" }
      @referrer = "http://www.example.com/referral"
      @publication = Factory.create(:publication)
    end

    it "should be created and setup correctly" do
      t = "2011-01-01 9:00".to_time(:utc).in_time_zone('UTC')
      Timecop.travel(t) do
        # TODO: This a User create but returns a subscription! Eeek! Maybe move to the association? Or return the user? Or rename the method? Or move to subscription?
        @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @json_hash)
        @subscription.user.subscriptions.size.should == 1
        @subscription.user.lastname.should == 'Draper'
        @subscription.user.firstname.should == 'Daniel'
        @subscription.user.email.should == 'example@example.com'
        # TODO: Should solus be on the user or the subscription?
        @subscription.solus.should == false
        @subscription.state.should == 'trial'
        @subscription.expires_at.to_s.should == (t + Publication::DEFAULT_TRIAL_EXPIRY.days).to_s
      end
    end

    it "should expire after 21 days" do
      t = "2011-01-01 9:00".to_time(:utc).in_time_zone('UTC')
      Timecop.travel(t) do
        @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @json_hash)
        Timecop.travel(t + Publication::DEFAULT_TRIAL_EXPIRY.days + 1.minute) do
          Subscription.expire_states
          @subscription.reload
          @subscription.state.should == 'squatter'
        end
      end
    end

    describe "upon activate!" do
      before(:each) do
        @subscription = Factory.create(:subscription, :state => 'trial')
      end

      it "should create a log entry" do
        @subscription.log_entries.size.should == 1
        @subscription.activate!
        @subscription.log_entries.size.should == 2
        # TODO: Check the values inside the logs
      end

      it "should deliver an email" do
        SubscriptionMailer.expects(:send_later).with(:deliver_activation, @subscription)
        @subscription.activate!
      end

      # TODO: Process a payment - when calling activate, a payment should be processed somehow
      # TODO: Set expires_at
    end
  end
end
