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
  end

  describe "creating a subscription" do
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

      @attributes = {
        'user_attributes' => @user_attributes
      }
    end

    it "should create a subscription" do
      expect {
        post('create', {
          :offer_id => @offer.id,
          :source_id => @source.id,
          :offer_term => @ot1.id,
          :subscription => @attributes
        })
      }.to change { Subscription.count }.by(1)
      Subscription.last.payments.size.should == 1
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
          :subscription => @attributes
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
          :attributes => @attributes,
          :payment_attributes => @payment_attributes
        }
      ).returns(factory)
      subscription.expects(:save!).returns(true)
      post('create', {
        :offer_id => @offer.id,
        :source_id => @source.id,
        :offer_term => @ot1.id,
        :subscription => @attributes,
        :payment => @payment_attributes
      })
      response.should redirect_to(:action => 'thanks')
    end

    it "should build a subscription with included and an optional gift" do
      subscription = stub(:user => Factory.stub(:user))
      subscription.expects(:save!).returns(true)
      factory = stub(:build => subscription)
      SubscriptionFactory.expects(:new).with(
        instance_of(Offer), {
          :term_id => @ot1.id.to_s,
          :optional_gift => nil,
          :included_gift_ids => [@g1.id, @g2.id],
          :optional_gift => @g4.id.to_s,
          :attributes => @attributes,
          :payment_attributes => @payment_attributes
        }
      ).returns(factory)
      post 'create', {
        :offer_id => @offer.id,
        :source_id => @source.id,
        :included_gifts => [@g1.id, @g2.id],
        :optional_gift => @g4.id,
        :offer_term => @ot1.id,
        :subscription => @attributes,
        :payment => @payment_attributes
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
          :payment => @payment_attributes
        })
      }.to_not change { Subscription.count }.by(1)
      response.should render_template("new")
      flash[:error].should == "The Gift #{@g4.name} is no longer available"
    end

    # TODO
    # Invalid gift
    # check error messages
    # set the source
    # Concession
    # Direct Debit
    # Existing User, wordpress etc
  end
end
