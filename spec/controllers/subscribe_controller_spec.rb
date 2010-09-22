require 'spec_helper'

describe SubscribeController do

  integrate_views
  
  before(:each) do
  end

  # --------------------------------------------- SUCCESS SENARIO #
  it "should successfully call on_get/on_next methods on offer" do
    offer = Factory(:offer)
    offer.offer_terms = [Factory(:offer_term)]
    source = Factory(:source)
  
    # on_get(:offer)
    get 'offer', { :offer_id => offer.id, :source_id => source.id }
  
    assigns[:subscription].offer.id.should == offer.id
    #FIXME assigns[:subscription]..subscription_gifts.size.should == offer.gifts.in_stock.optional.size
  
    # on_next(:offer)
    post 'offer', { :subscription => {:offer_id => offer.id} }
    
    assigns[:subscription].offer.id.should == offer.id
    #FIXME add more
  end
  
  it "should successfully call on_get/on_next methods on details - valid new user" do
    user = Factory(:user)
  
    # on_get(:details)
    get 'details', { }, {:user_dat => user.attributes }
    
    assigns[:subscription].user.id.should       == user.id
    assigns[:subscription].user.country.should  == 'Australia'
    assigns[:user].id.should                    == user.id
    assigns[:user].firstname.should             == user.firstname
  
    # to on_next(:details)
    post 'details', {:new_or_existing => 'new'}
    
    assigns[:new_or_existing].should            == 'new'
    session[:user_dat]["login"].should          == user.login
    session[:user_dat]["firstname"].should      == user.firstname
    session[:user_dat]["lastname"].should       == user.lastname
    session[:user_dat]["email"].should          == user.email
    # session[:user_dat]["email_confirmation"].should == user.email_confirmation
    session[:user_dat]["phone_number"].should   == user.phone_number
    session[:user_dat]["address_1"].should      == user.address_1
    session[:user_dat]["postcode"].should       == user.postcode
    session[:user_dat]["city"].should           == user.city
    session[:user_dat]["state"].should          == user.state
    session[:user_dat]["country"].should        == user.country
  end
  
  it "should successfully call on_get/on_next methods on details - invalid new user" do
  end
  
  it "should successfully call on_get/on_next methods on details - valid existing user" do
    User.delete_all # just in case
    user = Factory(:user) # create and save the user
    User.all.size.should == 1
    
    # on_get(:details)
    get 'details', { }, {:user_dat => user.attributes }
    
    assigns[:subscription].user.id.should       == user.id
    assigns[:subscription].user.country.should  == 'Australia'
    assigns[:user].id.should                    == user.id
    assigns[:user].firstname.should             == user.firstname
  
    # to on_next(:details)
    post 'details', {:new_or_existing => 'existing', :subscription => { :user_attributes => {:login => user.login, :password => user.password} }}
  
    assigns[:new_or_existing].should            == 'existing'
    session[:user_dat].should be_nil
    User.first.login.should == 'login'
    flash[:notice].should     be_nil
    flash[:error].should     be_nil
    response.should redirect_to(:action => :payment)
  end
  
  it "should .....when calling on_get/on_next methods on details - invalid existing user(wrong login/password)" do
  end

  # testcase scenario:
  # all inputs of setup_recurrent are correctly set(price, credit_card details, client_id)
  # setup_recurrent is called
  # the respnce should be success
  # trigger_recurrent is called for payment of the full subscription fee
  # the respnce should be success
  # subscription is updated (ex. (state = active), expiry_date, state_updated_at, ...)
  # redirected to (offer page?) with a notice on successful subscription
  it "should successfully make payment, save the updated subscription and finish the wizard" do
    # User.delete_all # just in case
    offer = Factory(:offer)
    publication = Factory(:publication)
    subscription = Subscription.new()
    subscription.offer = offer
    subscription.price = "15"

    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:user_dat => Factory.attributes_for(:user) },              # the session that is used by the wizardly gem
                    {:subscribe_dat => subscription.attributes}  # the flash that is used by the wizardly gem


    assigns[:subscription].should_not             be_new_record       # subscription wizard active record should be saved
    assigns[:subscription].state.should           == 'active'
    assigns[:subscription].price.should           == subscription.price
    assigns[:subscription].offer.id.should        == subscription.offer.id
    assigns[:subscription].publication.should_not be_nil
    assigns[:subscription].user.should_not        be_nil
    assigns[:subscription].user.recurrent_id.to_f.should_not == 0
    assigns[:subscription].user.recurrent_id.to_f.should < 10000000000000000000 # less than 20 numbers
    
    flash[:notice].should == "Congratulations! Your subscribtion was successful."
    response.should redirect_to(:action => :offer)
  end

  it "should redirect to the first page of wizard with errors when trying to finish the wizard with invalid credit card" do
    # User.delete_all # just in case
    offer = Factory(:offer)
    publication = Factory(:publication)
    subscription = Subscription.new()
    subscription.offer = offer
    subscription.price = "15"

    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => nil,
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" =>  'mm', #Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:user_dat => Factory.attributes_for(:user) },              # the session that is used by the wizardly gem
                    {:subscribe_dat => subscription.attributes}  # the flash that is used by the wizardly gem


    assigns[:subscription].should_not       be_new_record # subscription wizard active record should be saved(with trial)
    assigns[:subscription].state.should     == 'trial'    # because the wizard hasnt been completed
    flash[:error].should                    == "Unfortunately your payment was not successfull. Something went wrong during your subscription."
    response.should redirect_to(:action => :offer)
  end
  
  it "should redirect to the first page of wizard with errors when trying to finish the wizard with invalid subscription price" do
    # User.delete_all # just in case
    offer = Factory(:offer)
    publication = Factory(:publication)
    subscription = Subscription.new()
    subscription.offer = offer
    subscription.price = nil # invalid

    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:user_dat => Factory.attributes_for(:user) },              # the session that is used by the wizardly gem
                    {:subscribe_dat => subscription.attributes}  # the flash that is used by the wizardly gem


    assigns[:subscription].should_not       be_new_record # subscription wizard active record should be saved(with trial)
    assigns[:subscription].state.should     == 'trial'    # because the wizard hasnt been completed
    flash[:error].should                    == "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
    response.should redirect_to(:action => :offer)
  end

  it "should redirect to the first page of wizard with errors when trying to finish the wizard with no subscription price" do
    # User.delete_all # just in case
    offer = Factory(:offer)
    publication = Factory(:publication)
    subscription = Subscription.new()
    subscription.offer = offer
    subscription.price = 0

    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:user_dat => Factory.attributes_for(:user) },              # the session that is used by the wizardly gem
                    {:subscribe_dat => subscription.attributes}  # the flash that is used by the wizardly gem


    assigns[:subscription].should_not       be_new_record # subscription wizard active record should be saved(with trial)
    assigns[:subscription].state.should     == 'trial'    # because the wizard hasnt been completed
    flash[:error].should                    == "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
    response.should redirect_to(:action => :offer)
  end

end
