require 'spec_helper'

describe Subscription do

  before(:each) do
    stub_wordpress
  end

  describe "a trial subscription" do
    before(:each) do
      @json_hash = {
        "last_name"=> "Draper",
        "first_name"=> "Daniel",
        "email"=> "example@example.com",
        "ip_address"=>"150.101.226.181",
        :options => { :solus => false }
      }
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
        @subscription.solus.should == false
        @subscription.state.should == 'trial'
        @subscription.expires_at.to_s.should == (t + Publication::DEFAULT_TRIAL_EXPIRY.days).to_s
      end
    end

    it "should expire after 21 days" do
      t = "2011-01-01 9:00".to_time(:utc).in_time_zone('UTC')
      Timecop.travel(t) do
        @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @json_hash)
        Subscription.any_instance.expects(:send).with('trial_state_expire!').once
        Timecop.travel(t + Publication::DEFAULT_TRIAL_EXPIRY.days + 1.minute) do
          Subscription.expire_states
        end
      end
    end

    describe "upon expire!" do
      before(:each) do
        @subscription = User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, @referrer, @json_hash)
      end

      it "should create a log entry" do
        expect {
          User.validate_as(:system) do
            @subscription.expire!
          end
        }.to change { @subscription.log_entries.count }.by(1)
        entry = @subscription.log_entries.last
        entry.new_state.should == 'squatter'
      end

      it "the state should be squatter" do
        User.validate_as(:system) do
          @subscription.expire!
        end
        @subscription.state.should == 'squatter'
      end

      it "should set state_expires_at to nil" do
        User.validate_as(:system) do
          @subscription.expire!
        end
        @subscription.state_expires_at.should be(nil)
      end

      it "should not change expires_at" do
        expect {
          User.validate_as(:system) do
            @subscription.expire!
          end
        }.to_not change { @subscription.expires_at }
      end
    end

    describe "upon activate!" do
      before(:each) do
        @subscription = Factory.create(:subscription, :state => 'trial')
      end

      it "should create a log entry" do
        expect {
          @subscription.activate!
        }.to change { @subscription.log_entries.size }.by(1)
      end

      it "should set both expires_at and state_expires_at" do
        @time = "2011-03-03".to_time(:utc)
        Timecop.freeze(@time) do
          @subscription = Factory.create(:subscription, :state => 'trial')
          @subscription.increment_expires_at(10)
          @subscription.expires_at.time.should == @time.advance(:months => 10)
          @subscription.activate!
          @subscription.state_expires_at.time.should == @subscription.expires_at.time
        end
      end
    end
  end
end
