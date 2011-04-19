require 'spec_helper'

describe Subscription do

  before(:each) do
    today = Date.new(2010, 9, 27) # today is "Mon, 27 Sep 2010"
    Date.stubs(:today).returns(today)
    stub_wordpress
  end

  describe "upon save" do
    it "should create a recipient in Campaign Master" do
      s = Factory.create(:subscription)
      s.expects(:send_later).with(:sync_to_campaign_master)
      s.save!
    end
  end

  describe "upon verify!" do
    before(:each) do
      @subscription = Factory.create(:subscription, :state => 'pending', :pending => :concession_verification)
      @verify_note = "Verified student card"
    end

    it "should be active" do
      @subscription.verify!
      @subscription.state.should == 'active'
    end

    it "should deliver an email" do
      SubscriptionMailer.expects(:send_later).with(:deliver_activation, @subscription)
      @subscription.verify!
    end

    it "should create a log entry when pending concession" do
      @subscription.note = "A note about the sub"
      @subscription.log_entries.size.should == 1
      @subscription.verify!
      @subscription.log_entries.size.should == 2
      entry = @subscription.log_entries.last
      entry.old_state.should == 'pending'
      entry.new_state.should == 'active'
      entry.description.should == 'Concession: A note about the sub'
    end

    it "should create a log entry when pending student concession" do
      @subscription = Factory.create(:subscription, :state => 'pending', :pending => :student_verification)
      @subscription.note = "A note about the sub"
      @subscription.log_entries.size.should == 1
      @subscription.verify!
      @subscription.log_entries.size.should == 2
      entry = @subscription.log_entries.last
      entry.old_state.should == 'pending'
      entry.new_state.should == 'active'
      entry.description.should == 'Student Discount: A note about the sub'
    end

    describe "if pending payment" do
      before(:each) do
        @subscription.pending = 'payment'
      end

      it "should require a payment if pending payment" do
        lambda {
          @subscription.verify!('bogus str')
        }.should raise_exception
        @subscription.verify!(Payment.new(:payment_type => 'direct_debit', :amount => 100))
      end

      it "should create a log entry if pending payment when verified" do
        le_count = @subscription.log_entries.count
        @subscription.verify!(Payment.new(:payment_type => 'direct_debit', :amount => 100))
        @subscription.log_entries.count.should == (le_count + 1)
        @subscription.log_entries.last.old_state.should == 'pending'
        @subscription.log_entries.last.new_state.should == 'active'
        @subscription.log_entries.last.description.should == '$100.00 by Direct debit'
      end

      it "should create a paymemt if pending payment" do
        payment_count = @subscription.payments.count
        @subscription.verify!(Payment.new(:payment_type => 'direct_debit', :amount => 100))
        @subscription.payments.count.should == (payment_count + 1)
      end

      it "should be active" do
        @subscription.verify!(Payment.new(:payment_type => 'direct_debit', :amount => 100))
        @subscription.state.should == 'active'
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

  describe "upon expire!" do
    before(:each) do
      @subscription = Factory.create(:subscription, :state => 'active')
    end

    it "should create a log entry" do
      @subscription.log_entries.size.should == 1
      @subscription.expire!
      @subscription.log_entries.size.should == 2
      entry = @subscription.log_entries.last
      entry.new_state.should == 'squatter'
    end

    it "should deliver an email" do
      pending
    end
  end

end
