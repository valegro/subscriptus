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
 
  describe "in the pending state" do
    before(:each) do
      success = stub(:success? => true, :params => { "ponum" => '1234' })
      GATEWAY.stubs(:trigger_recurrent).returns(success)
      SubscriptionMailer.stubs(:deliver_pending)
      @subscription_action = Factory.create(:subscription_action, :payment => Factory.create(:token_payment))
      @subscription_action.gifts << Factory.create(:gift)
      @subscription = Factory.create(:pending_subscription, :pending_action => @subscription_action)
      @subscription_action.subscription = nil
    end

    describe "upon cancel" do
      it "should be in the squatter state" do
        @subscription.cancel!
        @subscription.state.should == 'squatter'
      end

      it "should deliver an email" do
        stub_mailer(SubscriptionMailer).expects(:send_later).with(:deliver_pending_expired, @subscription)
        @subscription.cancel!
      end
    end

    describe "upon verify" do
      before(:each) do
        # SubscriptionMailer.stubs(:deliver_verified).returns(true)
      end

      it "should be active" do
        @subscription.verify!
        @subscription.state.should == 'active'
      end

      it "should should set the expiry date appropriately" do
        @subscription.verify!
        @subscription.expires_at.utc.should == Time.now.utc.advance(:months => @subscription_action.term_length)
        @subscription.state_expires_at.utc.should == Time.now.utc.advance(:months => @subscription_action.term_length)
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
        stub_mailer(SubscriptionMailer).expects(:send_later).with(:deliver_verified, @subscription)
        stub_mailer(SubscriptionMailer).expects(:send_later).with(:deliver_activation, @subscription)
        @subscription.verify!
      end

      it "should apply an action" do
        @subscription.expects(:apply_action).with(@subscription.pending_action)
        @subscription.verify!
        @subscription.pending_action.should be(nil)
      end

      it "should create a gift order if gifts were present" do
        expect {
          @subscription.verify!
        }.to change { Order.count }.by(1)
      end

      describe "and the payment is declined" do
        it "should raise an exception" do
          failure = stub(:success? => false, :message => 'Test Failure')
          GATEWAY.stubs(:trigger_recurrent).returns(failure)
          lambda {
            @subscription.verify!
          }.should raise_exception(Exceptions::PaymentFailedException)
        end

        it "should raise because a token is missing" do
          @subscription.user.update_attributes(:payment_gateway_token => nil)
          lambda {
            @subscription.verify!
          }.should raise_exception(Exceptions::PaymentTokenMissing)
        end
      end

      describe "if pending student verification" do
        it "should apply an action" do
          @subscription.pending = :student_verification
          @subscription.expects(:apply_action).with(@subscription.pending_action)
          @subscription.verify!
          @subscription.pending_action.should be(nil)
        end

        it "should trigger a payment" do
          GATEWAY.unstub(:trigger_recurrent)
          success = stub(:success? => true, :params => { 'ponum' => '1234' })
          GATEWAY.expects(:trigger_recurrent).with(@subscription_action.payment.amount.to_i * 100, @subscription.user.payment_gateway_token).returns(success)
          @subscription.pending = :student_verification
          @subscription.verify!
        end

        it "should create a log entry" do
          @subscription = Factory.create(:pending_subscription, :pending => :student_verification)
          @subscription.note = "A note about the sub"
          expect {
            @subscription.verify!
          }.to change { @subscription.log_entries.size }.by(2)
          entry = @subscription.log_entries.last
          entry.old_state.should == 'pending'
          entry.new_state.should == 'active'
          entry.description.should == 'Student Discount: A note about the sub'
          @subscription.log_entries[-2].description.should == 'Expiry Date set to 09/04/11'
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
          }.to change { @subscription.log_entries.size }.by(2)
          entry = @subscription.log_entries.last
          entry.old_state.should == 'pending'
          entry.new_state.should == 'active'
          entry.description.should == 'Concession: A note about the sub'
          @subscription.log_entries[-2].description.should == 'Expiry Date set to 09/04/11'
        end
      end

      describe "if pending payment" do
        before(:each) do
          @subscription = Factory.create(:pending_payment_subscription)
        end

        it "should create a log entry if pending payment when verified" do
          expect {
            @subscription.verify!
            @subscription.reload
          }.to change { @subscription.log_entries.count }.by(2)
          @subscription.log_entries.last.old_state.should == 'pending'
          @subscription.log_entries.last.new_state.should == 'active'
          @subscription.log_entries[-1].description.should == '$100.00 by Direct debit'
          @subscription.log_entries[-2].description.should == 'Expiry Date set to 09/04/11'
        end

        it "should process and add the payment" do
          Timecop.freeze(Time.now) do
            expect {
              @subscription.verify!
            }.to change { @subscription.reload; @subscription.actions(true).count }.by(1)
            @subscription.actions.last.payment.should_not be(nil)
            @subscription.actions.last.payment.payment_type.should == :direct_debit
            @subscription.actions.last.payment.amount.should == 100
            @subscription.actions.last.payment.processed_at.should == Time.now
          end
        end

        it "should be active" do
          @subscription.verify!
          @subscription.state.should == 'active'
        end
      end
    end
  end
end
