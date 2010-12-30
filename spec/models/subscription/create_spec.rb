require 'spec_helper'

describe Subscription do

  before(:each) do
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create_or_update)
    CM::Recipient.stubs(:create!)
  end

  # TODO: Handle when first state is pending
  describe "upon creation" do
    it "should deliver a trial email for new trials" do
      @subscription = Factory.build(:subscription)
      SubscriptionMailer.expects(:send_later).with(:deliver_new_trial, @subscription)
      @subscription.save
    end

    it "should deliver an active email for new active subscriptions" do
      sub = Factory.build(:subscription, :state => 'active')
      SubscriptionMailer.expects(:send_later).with(:deliver_new_trial).never
      SubscriptionMailer.expects(:send_later).with(:deliver_activation, sub)
      @user = Factory.create(:subscriber)
      @user.subscriptions << sub
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
      @subscription.order_number.length.should == 8
    end

    it "should create a recipient in Campaign Master" do
      pending
=begin
      s = Factory.build(:subscription)
      CM::Recipient.expects(:create_or_update).with(
        :fields => {
          :"publication_#{s.publication_id}{state}" => s.state,
          :"publication_#{s.publication_id}{expiry}" => s.expires_at,
          :user_id => s.user.id
        }
      ).returns('called')
      s.save!
=end
    end

    it "should log error if create fails" do
      s = Factory.build(:subscription)
      CM::Recipient.expects(:create_or_update).raises("spam")
      CM::Proxy.expects(:log_cm_error)
      s.sync_to_campaign_master
    end
  end
end
