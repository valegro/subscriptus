require 'spec_helper'

describe SubscriptionFactory do

  before(:each) do
    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)

    @offer = Factory.create(:offer)
    @term1 = Factory.create(:offer_term, :price => 100, :months => 1)
    @term2 = Factory.create(:offer_term, :price => 200, :months => 2)
    @offer.offer_terms << @term1
    @offer.offer_terms << @term2

    stub_wordpress

    @attributes = {
      'user_attributes' => Factory.attributes_for(:user),
    }
    @payment_attrs = Factory.attributes_for(:payment)
  end

  it "should create a subscription with attributes" do
    expect {
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription.save!
      subscription.offer_id.should == @offer.id
    }.to change { Subscription.count }.by(1)
  end

  it "should create a subscription from an instance of a factory" do
    expect {
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription = factory.build
      subscription.save!
    }.to change { Subscription.count }.by(1)
  end

  it "should create and set a subscription action" do
    t = Time.local(2011, 1, 1, 0, 0, 0)
    Timecop.freeze(t) do
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription = factory.build
      subscription.save!
      subscription.actions.count.should == 1
      subscription.actions.first.offer_name.should == @offer.name
      subscription.actions.first.payment.amount.should == @offer.offer_terms.first.price
      subscription.actions.first.term_length.should == @offer.offer_terms.first.months
      subscription.actions.first.applied_at.should == t
    end
  end

  it "should raise if payment attributes are not provided and offer term price is > 0" do
    lambda {
      SubscriptionFactory.build(@offer, :payment_attributes => nil, :attributes => @attributes)
    }.should raise_exception(Exceptions::Factory::InvalidException)
  end

  it "should raise if concession is false but an offer term of type concession is provided" do
    lambda {
      SubscriptionFactory.build(@offer, :term_id => @term1.id, :attributes => { :user => Factory.create(:user) }, :concession => :student, :payment_attributes => @payment_attrs)
    }.should raise_error(Exceptions::InvalidOfferTerm)
  end

  describe "offer basics" do
    it "should set term to first term if none set" do
      t = Time.local(2011, 1, 1, 0, 0, 0)
      Timecop.freeze(t) do
        subscription = SubscriptionFactory.build(@offer, :payment_attributes => @payment_attrs, :attributes => @attributes)
        subscription.actions.last.payment.amount.should == @term1.price
        subscription.expires_at.should == Time.local(2011, 2, 1, 0, 0, 0).in_time_zone("UTC")
      end
    end

    it "should set a specific term" do
      t = Time.local(2011, 1, 1, 0, 0, 0)
      Timecop.freeze(t) do
        subscription = SubscriptionFactory.build(@offer, :term_id => @term2.id, :payment_attributes => @payment_attrs, :attributes => @attributes)
        subscription.actions.last.payment.amount.should == @term2.price
        subscription.expires_at.should == Time.local(2011, 3, 1, 0, 0, 0).in_time_zone("UTC")
      end
    end

    it "should raise if provided an invalid term id" do
      t = Time.local(2011, 1, 1, 0, 0, 0)
      Timecop.travel(t) do
        subscription = SubscriptionFactory.build(@offer, :term_id => -1, :payment_attributes => @payment_attrs, :attributes => @attributes)
        subscription.actions.last.term_length.should == @offer.offer_terms.first.months
      end
    end

    it "should raise if the offer term does not match the offer" do
      @offer_term = Factory.create(:offer_term, :months => 3, :offer => Factory.create(:offer))
      lambda {
        SubscriptionFactory.build(@offer, :term_id => @offer_term.id, :payment_attributes => @payment_attrs, :attributes => @attributes)
      }.should raise_exception(Exceptions::InvalidOfferTerm)
    end

    it "should set the publication" do
      subscription = SubscriptionFactory.build(@offer, :payment_attributes => @payment_attrs, :attributes => @attributes)
      subscription.publication.should == @offer.publication
    end

    it "should deliver an activation email" do
      SubscriptionMailer.expects(:send_later).with(:deliver_activation, instance_of(Subscription))
      subscription = SubscriptionFactory.build(@offer, :payment_attributes => @payment_attrs, :attributes => @attributes)
    end
  end

  describe "gifts" do
    before(:each) do
      @gift1 = Factory.create(:gift, :name => "Gift 1")
      @gift2 = Factory.create(:gift, :name => "Gift 2")
      @gift3 = Factory.create(:gift, :name => "Gift 3")
      @gift4 = Factory.create(:gift, :name => "Gift 4")
    end

    it "should have no gifts if none provided" do
      subscription = SubscriptionFactory.build(@offer, :payment_attributes => @payment_attrs, :attributes => @attributes)
      subscription.actions.last.gifts.empty?.should be(true)
    end

    it "should have the included gifts from the offer" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription.actions.last.gifts.size.should == 2
      subscription.save!
      subscription.reload
      subscription.orders.count.should == 1
      subscription.orders.last.gifts.size.should == 2
    end

    it "should select just one optional gift from the offer" do
      @offer.gifts.add(@gift1, true)
      @offer.gifts.add(@gift2, true)
      subscription = SubscriptionFactory.build(@offer, :optional_gift => "#{@gift2.id}", :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription.actions.last.gifts.size.should == 1
      subscription.actions.last.gifts.first.name.should == 'Gift 2'
      subscription.save!
      subscription.orders.count.should == 1
      subscription.reload
      subscription.orders.last.gifts.size.should == 1
    end

    it "should subscribe with no optional gifts if none was selected even though the offer had them" do
      @offer.gifts.add(@gift1, true)
      @offer.gifts.add(@gift2, true)
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription.actions.last.gifts.empty?.should be(true)
      subscription.save!
      subscription.reload
      subscription.orders.count.should == 0
    end

    it "should raise if you select an optional gift that is not available on the offer" do
      @offer.gifts.add(@gift1, true)
      lambda {
        SubscriptionFactory.build(@offer, :optional_gift => @gift2.id, :payment_attributes => @payment_attrs, :attributes => @attributes)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift #{@gift2.name} is no longer available")
    end

    it "should treat one optional gift as an included gift" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2, true)
      subscription = SubscriptionFactory.build(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription.actions.last.gifts.size.should == 2
      subscription.save!
      subscription.orders.count.should == 1
      subscription.reload
      subscription.orders.last.gifts.size.should == 2
    end

    it "should add included gifts and allow selection of an optional gift simultaneously" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      @offer.gifts.add(@gift3, true)
      @offer.gifts.add(@gift4, true)
      subscription = SubscriptionFactory.build(@offer, :optional_gift => @gift4.id, :attributes => @attributes, :payment_attributes => @payment_attrs)
      subscription.save!
      subscription.actions.last.gifts.size.should == 3
      subscription.orders.count.should == 1
      subscription.orders(true).last.gifts.size.should == 3 
    end

    it "should raise if an optional gift becomes unavailable" do
      @offer.gifts.add(@gift1, true)
      @offer.gifts.add(@gift2, true)
      @gift2.update_attributes(:on_hand => 0)
      lambda {
        SubscriptionFactory.build(@offer, :optional_gift => @gift2.id, :payment_attributes => @payment_attrs, :attributes => @attributes)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift #{@gift2.name} is no longer available")
    end

    it "should accept a list of included gift ids as validation" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      @subscription = SubscriptionFactory.build(@offer, :included_gift_ids => [@gift1, @gift2].map(&:id), :attributes => @attributes, :payment_attributes => @payment_attrs)
      @subscription.actions.last.gifts.size.should == 2
      # TODO: Remove call to save here
      @subscription.save!
      @subscription.orders(true).last.gifts.size.should == 2 
      @subscription.orders.count.should == 1
    end

    it "should raise if an included gift becomes unavailable" do
      @offer.gifts.add(@gift1)
      @offer.gifts.add(@gift2)
      @gift1.update_attributes(:on_hand => 0)
      lambda {
        SubscriptionFactory.build(@offer, :included_gift_ids => [@gift1, @gift2].map(&:id).map(&:to_s), :payment_attributes => @payment_attrs, :attributes => @attributes)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift #{@gift1.name} is no longer available")
    end

    it "should raise if an included gift does not exist" do
      lambda {
        SubscriptionFactory.build(@offer, :included_gift_ids => [-1], :payment_attributes => @payment_attrs, :attributes => @attributes)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift is no longer available")
    end

    it "should raise if an optional gift does not exist" do
      lambda {
        SubscriptionFactory.build(@offer, :optional_gift => -1, :payment_attributes => @payment_attrs, :attributes => @attributes)
      }.should raise_error(Exceptions::GiftNotAvailable, "The Gift is no longer available")
    end
  end

  describe "Initial State" do
    it "should raise if not valid" do
      lambda {
        SubscriptionFactory.build(@offer, :payment_attributes => @payment_attrs, :attributes => {:user_attributes => { :email => "jwfhwekjfhwe" }})
      }.should raise_exception(Exceptions::Factory::InvalidException)
    end

    it "should set to active by default" do
      subscription = SubscriptionFactory.build(@offer, :payment_attributes => @payment_attrs, :attributes => @attributes)
      subscription.state.should == 'active'
    end

    it "should allow me to specify the initial state" do
      subscription = SubscriptionFactory.build(@offer, :init_state => 'trial', :payment_attributes => @payment_attrs, :attributes => @attributes)
      subscription.state.should == 'trial'
    end
  end

  describe "Source" do
    it "should set the source if provided" do
      source = Factory.create(:source)
      subscription = SubscriptionFactory.build(@offer, :source => source.id, :payment_attributes => @payment_attrs, :attributes => @attributes)
      subscription.actions.last.source.name == source.name
    end
  end

  describe "a payment" do
    it "should be created when a subscription is created" do
      gw_response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(gw_response)
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      expect {
        subscription = factory.build
        subscription.save!
        subscription.actions.last.payment.amount.should == @term1.price
        subscription.actions.last.payment.payment_type.should == :credit_card
        subscription.actions.last.payment.card_number.should == "XXXX-XXXX-XXXX-#{@payment_attrs[:card_number][-4..-1]}"
      }.to change { Payment.count }.by(1)
    end

    it "should not be created when a subscription is created if gateway authorization fails" do
      gw_response = stub(:success? => false, :message => "Test Failure")
      GATEWAY.expects(:purchase).returns(gw_response)
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
      expect {
        lambda {
          subscription = factory.build
          subscription.save!
        }.should raise_error(Exceptions::PaymentFailedException, "Test Failure")
      }.to change { Payment.count }.by(0)
    end

    it "should be created as a direct debit type when the subscription created if direct debit option is passed" do
      GATEWAY.expects(:purchase).never
      GATEWAY.expects(:setup_recurrent).never
      GATEWAY.expects(:trigger_recurrent).never
      factory = SubscriptionFactory.new(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs, :payment_option => 'direct_debit')
      subscription = factory.build
      subscription.actions.size.should == 0
      subscription.pending_action.should be_an_instance_of(SubscriptionAction)
      subscription.state.should == 'pending'
      subscription.pending.should == :payment
      subscription.pending_action.payment.should be_an_instance_of(Payment)
      subscription.pending_action.payment.payment_type.should == :direct_debit
      subscription.pending_action.payment.amount.should == @term1.price
    end
  end

  describe "subscribing with a concession should" do
    before(:each) do
      @payment = Factory.create(:payment, :payment_type => :token)
      @concession_term = Factory.create(:offer_term, :concession => true)
      @offer.offer_terms << @concession_term
      success = stub(:success? => true)
      GATEWAY.stubs(:setup_recurrent).returns(success)
    end

    it "should store the payment details on the gateway and set the user's gateway payment token" do
      @user = Factory.create(:subscriber)
      @user.expects(:store_credit_card_on_gateway)
      @subscription = SubscriptionFactory.build(
        @offer,
        :term_id => @concession_term,
        :attributes => { :user => @user },
        :concession => :student,
        :payment_attributes => @payment_attrs
      )
    end

    it "should not store the payment details on the gateway if the user already has a valid token" do
      GATEWAY.expects(:setup_recurrent).never
      @user = Factory.create(:user_with_token)
      @subscription = SubscriptionFactory.build(
        @offer,
        :term_id => @concession_term,
        :attributes => { :user => @user },
        :concession => :student,
        :payment_attributes => @payment_attrs
      )
    end

    it "should set state to pending" do
      factory = SubscriptionFactory.new(
        @offer,
        :term_id => @concession_term,
        :attributes => @attributes,
        :concession => :student,
        :payment_attributes => @payment_attrs
      )
      @subscription = factory.build
      @subscription.state.should == 'pending'
    end

    it "should set the pending value for student" do
      factory = SubscriptionFactory.new(
        @offer,
        :term_id => @concession_term,
        :attributes => @attributes,
        :concession => :student,
        :payment_attributes => @payment_attrs
      )
      @subscription = factory.build
      @subscription.pending.should == :student_verification
    end

    it "should set the pending value for concession" do
      factory = SubscriptionFactory.new(
        @offer,
        :term_id => @concession_term,
        :attributes => @attributes,
        :concession => :concession,
        :payment_attributes => @payment_attrs
      )
      @subscription = factory.build
      @subscription.pending.should == :concession_verification
      @subscription.state.should == 'pending'
    end

    it "should set the state to active if the user already has a verified concession" do
      @attributes['user_attributes'] = Factory.attributes_for(:user, :valid_concession_holder => true)
      factory = SubscriptionFactory.new(
        @offer,
        :term_id => @concession_term,
        :attributes => @attributes,
        :concession => :concession,
        :payment_attributes => @payment_attrs
      )
      @subscription = factory.build
      @subscription.pending.should be(nil)
      @subscription.state.should == 'active'
      @subscription.expires_at.should_not be(nil)
    end

    it "should not set the expiry date" do
      factory = SubscriptionFactory.new(
        @offer,
        :term_id => @concession_term,
        :attributes => @attributes,
        :concession => :concession,
        :payment_attributes => @payment_attrs
      )
      @subscription = factory.build
      @subscription.expires_at.should == nil
    end

    it "should set the action to be applied" do
      factory = SubscriptionFactory.new(
        @offer,
        :term_id => @concession_term,
        :attributes => @attributes,
        :concession => :concession,
        :payment_attributes => @payment_attrs
      )
      @subscription = factory.build
      @subscription.reload
      @subscription.pending_action.should be_instance_of(SubscriptionAction)
      @subscription.pending_action.payment.payment_type.should == :token
      s = Subscription.find(@subscription.id)
      s.pending_action.should_not be(nil)
      s.pending_action.payment.should_not be(nil)
    end

    it "should set the action to be applied but not create an order if gifts are requested" do
      @offer.gifts.add(Factory.create(:gift))
      expect {
        factory = SubscriptionFactory.new(
          @offer,
          :term_id => @concession_term,
          :attributes => @attributes,
          :concession => :concession,
          :payment_attributes => @payment_attrs
        )
        @subscription = factory.build
        @subscription.pending_action.gifts.size.should == 1
      }.to_not change { Order.count }.by(1)
    end

    it "should deliver a pending email" do
      SubscriptionMailer.expects(:send_later).with(:deliver_pending_concession_verification, instance_of(Subscription))
      factory = SubscriptionFactory.new(
        @offer,
        :term_id => @concession_term,
        :attributes => @attributes,
        :concession => :concession,
        :payment_attributes => @payment_attrs
      )
      @subscription = factory.build
    end
  end

  it "should call save! on the subscription" do
    Subscription.any_instance.expects(:save!).at_least_once
    SubscriptionFactory.build(@offer, :attributes => @attributes, :payment_attributes => @payment_attrs)
  end
end
