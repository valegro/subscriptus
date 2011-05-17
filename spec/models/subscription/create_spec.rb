require 'spec_helper'

describe Subscription do

  before(:each) do
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
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
      @subscription = Factory.build(:subscription)
      SubscriptionMailer.expects(:send_later).with(:deliver_new_trial, @subscription)
      @subscription.save
    end

    it "should set both expires_at and state_expires_at for new trials"

    it "should NOT deliver and email for new subscriptions that did not take payment"

    it "should deliver a pending email for new pending student subscriptions" do
      @subscription = Factory.build(:pending_subscription, :pending => 'student_verification')
      SubscriptionMailer.expects(:send_later).with(:deliver_pending_student_verification, @subscription)
      @subscription.save!
    end

    it "should deliver a pending email for new pending ceoncession subscriptions" do
      @subscription = Factory.build(:pending_subscription, :pending => 'concession_verification')
      SubscriptionMailer.expects(:send_later).with(:deliver_pending_concession_verification, @subscription)
      @subscription.save!
    end

    it "should deliver a pending email for new pending payment subscriptions" do
      @subscription = Factory.build(:pending_subscription, :pending => 'payment')
      SubscriptionMailer.expects(:send_later).with(:deliver_pending_payment, @subscription)
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
      s.expects(:send_later).with(:sync_to_campaign_master)
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
