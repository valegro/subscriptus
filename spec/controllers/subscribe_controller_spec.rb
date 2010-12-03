require 'spec_helper'

describe SubscribeController do

  integrate_views
  
  before(:each) do
    @source = Factory(:source)

    @offer = Factory(:offer)
    @ot1 = Factory(:offer_term, :months => 1)
    @ot2 = Factory(:offer_term, :months => 3)
    @offer.offer_terms << @ot1
    @offer.offer_terms << @ot2
    @offer.gifts << @g1 = Factory(:gift, :on_hand => 10)
    @offer.gifts << @g2 = Factory(:gift, :on_hand => 10)
    @offer.gifts << @g3 = Factory(:gift, :on_hand => 0)
    @offer.gifts << @g4 = Factory(:gift, :on_hand => 10)

    @user_attributes = Factory.attributes_for(:user)
    @payment_attributes = Factory.attributes_for(:payment)
  end

  # --------------------------------------------- OFFER SENARIOs #
  it "should show gifts for offer" do
    get 'new', { :offer_id => @offer.id, :source_id => @source.id }
  end
  
  it "should show errors if data is missing" do
    GATEWAY.expects(:purchase).never
    post 'create', { :subscription => {} } 
    assigns[:subscription].valid?.should == false
    # TODO: Test offer id is correct
    response.should render_template('new')
  end

  # TODO: Handle different gift and offer combinations?

  describe "when creating a subscription" do
    before(:each) do
      # Payment Gateway
      gw_response = stub(:success? => true)
      GATEWAY.expects(:purchase).returns(gw_response)

      # Campaign Master
      Subscription.any_instance.expects(:send_later).with(:update_campaignmaster)
      
      # Mailer
      SubscriptionMailer.expects(:deliver_activation)

      post 'create', {
        :offer_id => @offer.id, :source_id => @source.id,
        :offer_term => @ot2.id,
        :subscription => {
          :user_attributes => @user_attributes,
          :payments_attributes => { "0" => @payment_attributes }
        }
      } 
    end

    # TODO: Perhaps these should go in the model?
    # TODO: Maybe (as per Yuji) we move the post to after(:all) and make these expectations instead
    # TODO: Handle gift selection and offer term
    it "should set the offer" do
      assigns[:subscription].state.should == 'active'
      assigns[:subscription].valid?.should == true
      assigns[:subscription].offer.valid?.should == true
      assigns[:subscription].offer.id.should == @offer.id
    end

    it "should set expiry and price" do
      assigns[:subscription].expires_at.localtime.month.should == Date.today.advance(:months => @ot2.months).month
      assigns[:subscription].expires_at.localtime.day.should == Date.today.advance(:months => @ot2.months).day
      assigns[:subscription].price.to_i.should == @ot2.price.to_i
      response.should redirect_to :action => :thanks
    end

    it "should create a payment" do
      # TODO: Test the order ID
      assigns[:subscription].payments.count.should == 1
      assigns[:subscription].payments.first.first_name.should == @payment_attributes[:first_name]
      assigns[:subscription].payments.first.last_name.should == @payment_attributes[:last_name]
      assigns[:subscription].payments.first.amount.to_i.should == @ot2.price.to_i
    end

    it "should create a gift order" do
      # TODO
      pending
    end
  end

end
