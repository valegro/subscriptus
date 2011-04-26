require 'spec_helper'

describe Subscription do
  before(:each) do
    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
    stub_wordpress
    Timecop.freeze("2011-01-10".to_time(:local))
  end

  after(:each) do
    Timecop.return
  end
 
  # TODO: Reminders for pending emails at regular intervals - how??
  describe "in the pending state" do
    before(:each) do
      SubscriptionMailer.stubs(:deliver_pending)
      @subscription_action = Factory.create(:subscription_action)
      @subscription = Factory.create(:subscription,
        :state => "pending",
        :pending => :concession_verification,
        :pending_action => @subscription_action
      )
    end

    describe "upon cancel" do
      it "should be in the squatter state" do
        @subscription.cancel!
        @subscription.state.should == 'squatter'
      end

      it "should deliver an email" do
        SubscriptionMailer.expects(:send_later).with(:deliver_pending_expired, @subscription)
        @subscription.cancel!
      end
    end

    describe "upon verify" do
      before(:each) do
        SubscriptionMailer.stubs(:deliver_verified).returns(true)
      end

      it "should be active" do
        @subscription.verify!
        @subscription.state.should == 'active'
      end

      it "should should set the expiry date appropriately" do
        @subscription.verify!
        @subscription.expires_at.utc.should == Time.now.utc.advance(:months => @subscription_action.term_length)
      end

      it "should should set the state_updated_at to now" do
        @subscription.verify!
        @subscription.state_updated_at.should == Time.now
      end

      it "should set pending to nil" do
        @subscription.verify!
        @subscription.pending.should be(nil)
      end

      it "should deliver an email" do
        SubscriptionMailer.expects(:send_later).with(:deliver_verified, @subscription)
        @subscription.verify!
      end

      it "should apply an action" do
        @subscription.expects(:apply_action).with(@subscription.pending_action)
        @subscription.verify!
        @subscription.pending_action.should be(nil)
      end

      describe "if pending student verification" do
        it "should apply an action" do
          @subscription.pending = :student_verification
          @subscription.expects(:apply_action).with(@subscription.pending_action)
          @subscription.verify!
          @subscription.pending_action.should be(nil)
        end

        it "should trigger a payment" do
          # TODO: Where do we get @amount and @token from??
          GATEWAY.expects(:trigger_recurrent).with(@amount, @token).returns(success)
          @subscription.pending = :student_verification
          @subscription.verify!
        end

        it "should create a log entry" do
          @subscription = Factory.create(
            :subscription,
            :state => 'pending',
            :pending => :student_verification,
            :pending_action => Factory.create(:subscription_action)
          )
          @subscription.note = "A note about the sub"
          expect {
            @subscription.verify!
          }.to change { @subscription.log_entries.size }.by(1)
          entry = @subscription.log_entries.last
          entry.old_state.should == 'pending'
          entry.new_state.should == 'active'
          entry.description.should == 'Student Discount: A note about the sub; Expiry Date set to 09/04/11'
        end
      end

      describe "if pending concession verification" do
        it "should apply an action and set the concession holder as valid" do
          @subscription.pending = :concession_verification
          @subscription.expects(:apply_action).with(@subscription.pending_action)
          @subscription.verify!
          @subscription.pending_action.should be(nil)
          @subscription.user.valid_concession_holder.should be(true)
        end

        it "should create a log entry" do
          @subscription.note = "A note about the sub"
          @subscription.log_entries.size.should == 1
          expect {
            @subscription.verify!
          }.to change { @subscription.log_entries.size }.by(1)
          entry = @subscription.log_entries.last
          entry.old_state.should == 'pending'
          entry.new_state.should == 'active'
          entry.description.should == 'Concession: A note about the sub; Expiry Date set to 09/04/11'
        end
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
          @subscription.log_entries.last.description.should == '$100.00 by Direct debit; Expiry Date set to 09/04/11'
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
  end
end
