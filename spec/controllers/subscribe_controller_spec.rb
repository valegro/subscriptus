require 'spec_helper'

describe SubscribeController do

  integrate_views

  before(:each) do
    Timecop.freeze('2011-01-01 0:00')
    @source = Factory(:source)

    @user_attributes = Factory.attributes_for(:user).stringify_keys
    @payment_attributes = Factory.attributes_for(:payment).stringify_keys

    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
    stub_wordpress
    https!
    SubscribeController.any_instance.stubs(:current_domain).returns('example.com')
  end

  describe "on create" do
    before(:each) do
      @offer = Factory(:offer)
      @ot1 = Factory(:offer_term, :months => 1)
      @ot2 = Factory(:offer_term, :months => 3)
      @offer.offer_terms << @ot1
      @offer.offer_terms << @ot2
      @offer.gifts.add(@g1 = Factory(:gift, :on_hand => 10))
      @offer.gifts.add(@g2 = Factory(:gift, :on_hand => 10))
      @offer.gifts.add(@g3 = Factory(:gift, :on_hand => 0))
      @offer.gifts.add(@g4 = Factory(:gift, :on_hand => 10), true)

      @attributes = {}
      @expected_attributes = { 'user' => instance_of(User) }
    end

    it "should create a subscription" do
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :user => @user_attributes
        })
      }.to change { Subscription.count }.by(1)
      Subscription.last.actions.size.should == 1
      Subscription.last.actions.last.payment.should be_an_instance_of(Payment)
      response.should redirect_to(:action => 'thanks')
    end

    it "should not create a subscription if payment fails" do
      gw_response = stub(:success? => false, :message => "Testing Failure")
      GATEWAY.expects(:purchase).returns(gw_response)
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :user => @user_attributes
        })
      }.to_not change { Subscription.count }.by(1)
      response.should render_template("new")
      flash[:error].should == "Testing Failure"
    end

    it "should not create a subscription if record invalid" do
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => {:user_attributes => {}}
        })
      }.to_not change { Subscription.count }.by(1)
      response.should render_template("new")
    end

    it "should build a subscription when no gifts are selected" do
      subscription = stub(:user => Factory.stub(:user))
      factory = stub(:build => subscription)
      SubscriptionFactory.expects(:new).with(
        instance_of(Offer), {
          :term_id => @ot1.id.to_s,
          :optional_gift => nil,
          :included_gift_ids => nil,
          :attributes => @expected_attributes,
          :source => @source.id,
          :payment_attributes => @payment_attributes,
          :concession => nil,
          :source => @source.id.to_s,
          :payment_option => 'credit_card'
        }
      ).returns(factory)
      post('create', {
        :offer_id => @offer.id,
        :source_id => @source.id,
        :offer_term => @ot1.id,
        :subscription => @attributes,
        :payment => @payment_attributes,
        :payment_option => 'credit_card',
        :user => @user_attributes
      })
      response.should redirect_to(:action => 'thanks')
    end

    it "should build a subscription with included and an optional gift" do
      subscription = stub(:user => Factory.stub(:user))
      factory = stub(:build => subscription)
      SubscriptionFactory.expects(:new).with(
        instance_of(Offer), {
          :term_id => @ot1.id.to_s,
          :optional_gift => nil,
          :included_gift_ids => [@g1.id, @g2.id],
          :optional_gift => @g4.id.to_s,
          :attributes => @expected_attributes,
          :payment_attributes => @payment_attributes,
          :concession => nil,
          :payment_option => 'credit_card',
          :source => @source.id.to_s
        }
      ).returns(factory)
      post 'create', {
        :offer_id => @offer.id,
        :source_id => @source.id,
        :included_gifts => [@g1.id, @g2.id],
        :optional_gift => @g4.id,
        :offer_term => @ot1.id,
        :subscription => @attributes,
        :payment => @payment_attributes,
        :payment_option => 'credit_card',
        :user => @user_attributes
      }
      response.should redirect_to(:action => 'thanks')
    end

    it "should not create a subscription if an optional gift is out of stock" do
      @g4.on_hand = 0
      @g4.save
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :optional_gift => @g4.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :user => @user_attributes
        })
      }.to_not change { Subscription.count }.by(1)
      response.should render_template("new")
      flash[:error].should == "The Gift #{@g4.name} is no longer available"
    end

    describe "when choosing student concession" do
      before(:each) do
        GATEWAY.stubs(:trigger_recurrent)
        GATEWAY.expects(:purchase).never
        success = stub(:success? => true)
        GATEWAY.stubs(:setup_recurrent).returns(success)
        @concession_term = Factory.create(:offer_term, :concession => true)
        @offer.offer_terms << @concession_term
      end

      it "should store the credit card on the gateway" do
        User.any_instance.expects(:store_credit_card_on_gateway).with(instance_of(ActiveMerchant::Billing::CreditCard))
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @concession_term.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'student',
          :user => @user_attributes
        })
      end

      it "should create a pending action with a payment" do
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @concession_term.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'student',
          :user => @user_attributes
        })
        Subscription.last.pending_action.should be_an_instance_of(SubscriptionAction)
        Subscription.last.pending_action.payment.should be_an_instance_of(Payment)
      end

      it "should set the subscription to pending" do
        subscription = stub(:save! => true)
        factory = stub(:build => subscription)
        SubscriptionFactory.expects(:new).with(
          instance_of(Offer), {
            :term_id => @concession_term.id.to_s,
            :attributes => @expected_attributes,
            :payment_attributes => @payment_attributes,
            :concession => 'student',
            :optional_gift => nil,
            :included_gift_ids => nil,
            :source => @source.id.to_s,
            :payment_option => 'direct_debit'
          }
        ).returns(factory)
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @concession_term.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'student',
          :payment_option => 'direct_debit',
          :user => @user_attributes
        })
      end
    end

    describe "when choosing senior concession" do
      before(:each) do
        GATEWAY.stubs(:trigger_recurrent)
        GATEWAY.expects(:purchase).never
        success = stub(:success? => true)
        GATEWAY.stubs(:setup_recurrent).returns(success)
        @concession_term = Factory.create(:offer_term, :concession => true)
        @offer.offer_terms << @concession_term
      end

      it "should store the credit card on the gateway" do
        User.any_instance.expects(:store_credit_card_on_gateway).with(instance_of(ActiveMerchant::Billing::CreditCard))
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @concession_term.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'concession',
          :user => @user_attributes
        })
      end

      it "should create a pending action with a payment" do
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @concession_term.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'concession',
          :user => @user_attributes
        })
        Subscription.last.pending_action.should be_an_instance_of(SubscriptionAction)
        Subscription.last.pending_action.payment.should be_an_instance_of(Payment)
      end

      it "should set the subscription to pending" do
        subscription = stub(:save! => true)
        factory = stub(:build => subscription)
        SubscriptionFactory.expects(:new).with(
          instance_of(Offer), {
            :term_id => @ot1.id.to_s,
            :attributes => @expected_attributes,
            :payment_attributes => @payment_attributes,
            :concession => 'concession',
            :optional_gift => nil,
            :included_gift_ids => nil,
            :source => @source.id.to_s,
            :payment_option => 'credit_card'
          }
        ).returns(factory)
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :concession => 'concession',
          :payment_option => 'credit_card',
          :user => @user_attributes
        })
      end
    end

    describe "when choosing direct debit" do
      before(:each) do
        GATEWAY.expects(:trigger_recurrent).never
        GATEWAY.expects(:purchase).never
        GATEWAY.expects(:setup_recurrent).never
      end

      it "should create a pending action with a payment" do
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :payment_option => 'direct_debit',
          :user => @user_attributes
        })
        Subscription.last.pending_action.should be_an_instance_of(SubscriptionAction)
        Subscription.last.pending_action.payment.should be_an_instance_of(Payment)
        Subscription.last.pending_action.payment.payment_type.should == :direct_debit
      end

      it "should set the subscription to pending" do
        subscription = stub(:save! => true)
        factory = stub(:build => subscription)
        SubscriptionFactory.expects(:new).with(
          instance_of(Offer), {
            :term_id => @ot1.id.to_s,
            :attributes => @expected_attributes,
            :payment_attributes => @payment_attributes,
            :payment_option => 'direct_debit',
            :optional_gift => nil,
            :included_gift_ids => nil,
            :source => @source.id.to_s,
            :concession => nil
          }
        ).returns(factory)
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes,
          :payment => @payment_attributes,
          :payment_option => 'direct_debit',
          :user => @user_attributes
        })
      end
    end


    # This scenario should only occur if for some reason there exists a wordpress user with the given
    # email but there is no subscriptus user with that email
    describe "when a wordpress user exists with the same email" do
      before(:each) do
        Wordpress.stubs(:exists?).with({:email => "daniel@codefire.com.au"}).returns(true)
        @user_attributes['email'] = 'daniel@codefire.com.au'
        @user_attributes['email_confirmation'] = 'daniel@codefire.com.au'
      end

      it "should return to the new page and ask for a username and password" do
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :optional_gift => @g4.id,
          :subscription => @attributes,
          :payment => @payment_attributes
        })
        response.should render_template("subscribe/new")
      end

      # TODO: Once again, should we also check to see if there is a user who has the email address too?
    end

    # TODO
    # Invalid gift
    # check error messages
    # Direct Debit
  end

  describe "when the session contains a completed subscription id" do
    before(:each) do
      @publication = Factory.create(:publication)
      @offer = Factory.create(:offer, :publication => @publication)
      @subscription = Factory.create(:active_subscription, :offer => @offer, :publication => @publication)
      @subscription_action = Factory.create(:subscription_action, :subscription => @subscription)

      controller.session[:subscription_id] = @subscription.id
      session[:subscription_id].should_not be_nil
    end

    it "should render the thanks page" do
      get :thanks
      response.should render_template("thanks")
    end
    
    it "should render the complete page" do
      get :complete
      response.should render_template("complete")
    end
    
    it "should render the invoice page" do
      get :invoice
      response.should render_template("invoice")
    end
  end

  describe "when the session does not contain the subscription id" do
    it "the thanks page should redirect to login" do
      get :thanks
      response.should redirect_to(login_url)
    end
    
    it "the complete page should redirect to login" do
      get :complete
      response.should redirect_to(login_url)
    end
    
    it "the invoice page should redirect to login" do
      get :invoice
      response.should redirect_to(login_url)
    end
  end
end
