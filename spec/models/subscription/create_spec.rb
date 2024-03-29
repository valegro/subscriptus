require 'spec_helper'

describe Subscription do

  before(:each) do
    cm_return = stub(:success? => true)
    #cm_return.expects(:has_key?).with(:recipients).returns(false)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
    stub_wordpress
  end

  # TODO: Break this up into all of the initial states
  describe "upon creation" do
    it "should deliver a trial email for new trials" do
      @json_hash = {
        "last_name"=> "Draper",
        "first_name"=> "Daniel",
        "email"=> "example@example.com",
        "ip_address"=>"150.101.226.181",
        :options => { :solus => false }
      }
      @publication = Factory.create(:publication)
      stub_mailer(SubscriptionMailer).expects(:deliver_new_trial).with(instance_of(Subscription))
      Subscription.any_instance.expects(:temp_password=)
      User.find_or_create_with_trial(@publication, Publication::DEFAULT_TRIAL_EXPIRY, 'referrer', @json_hash)
    end

    it "should set both expires_at and state_expires_at for new trials" do
      @time = "2011-03-03".to_time(:utc)
      Timecop.freeze(@time) do
        @subscription = Factory.create(:subscription, :state => 'trial', :expires_at => 10.days.from_now)
        @subscription.created_at.time.should == @time
        @subscription.expires_at.time.should == 10.days.from_now
        @subscription.state_expires_at.time.should == 10.days.from_now
      end
    end

    it "should set both expires_at and state_expires_at for new active subscriptions" do
      @time = "2011-03-03".to_time(:utc)
      Timecop.freeze(@time) do
        @subscription = Factory.create(:subscription, :state => 'active', :expires_at => 10.days.from_now)
        @subscription.created_at.time.should == @time
        @subscription.expires_at.time.should == 10.days.from_now
        @subscription.state_expires_at.time.should == 10.days.from_now
      end
    end

    it "should deliver a pending email for new pending student subscriptions" do
      @subscription = Factory.build(:pending_subscription, :pending => 'student_verification')
      stub_mailer(SubscriptionMailer).expects(:deliver_pending_student_verification).with(@subscription)
      @subscription.save!
    end

    it "should deliver a pending email for new pending ceoncession subscriptions" do
      @subscription = Factory.build(:pending_subscription, :pending => 'concession_verification')
      stub_mailer(SubscriptionMailer).expects(:deliver_pending_concession_verification).with(@subscription)
      @subscription.save!
    end

    it "should deliver a pending email for new pending payment subscriptions" do
      @subscription = Factory.build(:pending_subscription, :pending => 'payment')
      stub_mailer(SubscriptionMailer).expects(:deliver_pending_payment).with(@subscription)
      @subscription.save!
    end

    it "should create a log entry" do
      @subscription = Factory.create(:subscription)
      @subscription.log_entries.size.should == 1
      # Check the Entry
      log_entry = @subscription.log_entries.first
      log_entry.old_state.should == nil
      log_entry.new_state.should == 'trial'
    end

    it "should set an order number based on id" do
      @subscription = Factory.create(:subscription)
      @subscription.reference.length.should == 8
      @subscription.reference.should =~ /#{@subscription.id}/
    end

    it "should create a recipient in Campaign Master" do
      s = Factory.build(:subscription)
      s.delay.expects(:sync_to_campaign_master)
      s.save!
    end

    describe "in the pending state" do
      it "should raise if no pending action is provided" do
        lambda {
          Factory.create(:subscription, :state => 'pending', :pending => :student_verification)
        }.should raise_error
      end

      it "should raise if no pending action is provided" do
        lambda {
          Factory.create(:subscription, :state => 'pending', :pending_action => Factory.create(:subscription_action))
        }.should raise_error
      end

      it "should not raise if both pending action and pending are provided" do
        lambda {
          Factory.create(:subscription, :pending => :student_verification, :state => 'pending', :pending_action => Factory.create(:subscription_action))
        }.should_not raise_error
      end
    end
  end
end
