require 'spec_helper'

describe SubscribeController do

  integrate_views
  
  before(:each) do
    @source = Factory(:source)

    @offer = Factory(:offer)
    @offer.offer_terms << @ot1 = Factory(:offer_term)
    @offer.offer_terms << @ot2 = Factory(:offer_term)
    @offer.gifts << @g1 = Factory(:gift, :on_hand => 10)
    @offer.gifts << @g2 = Factory(:gift, :on_hand => 10)
    @offer.gifts << @g3 = Factory(:gift, :on_hand => 0)
    @offer.gifts << @g4 = Factory(:gift, :on_hand => 10)
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

  # TODO: Handle gift selection and offer term
  it "should create a paid subscription" do
    gw_response = stub(:success? => true)
    GATEWAY.expects(:purchase).returns(gw_response)
    post 'create', {
      :offer_id => @offer.id, :source_id => @source.id,
      :offer_term => @ot2.id,
      :subscription => {
        :user_attributes => Factory.attributes_for(:user),
        :payments_attributes => { "0" => Factory.attributes_for(:payment) }
      }
    } 
    assigns[:subscription].valid?.should == true
    assigns[:subscription].offer.valid?.should == true
    assigns[:subscription].offer.id.should == @offer.id
    # Offer term foo
    assigns[:subscription].expires_at.should == @ot2.months.months.from_now
    assigns[:subscription].price.to_i.should == @ot2.price.to_i
    response.should redirect_to :action => :thanks
  end
end
