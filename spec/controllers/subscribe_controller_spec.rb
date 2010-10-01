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

    @subscription = Subscription.new()
    @subscription.offer = @offer

    TransactionLog.delete_all
    GiftOffer.delete_all
    GiftOffer.create({:offer => @offer, :gift => @g1, :included => true})   # included and instock
    GiftOffer.create({:offer => @offer, :gift => @g2, :included => false})  # not included but instock
    GiftOffer.create({:offer => @offer, :gift => @g3, :included => true})   # included but not instock
    GiftOffer.create({:offer => @offer, :gift => @g4, :included => false})  # not included but instock
  end

  # --------------------------------------------- OFFER SENARIOs #
  it "should successfully call on_get method on offer and set the subscription's offer" do
    get 'offer', { :offer_id => @offer.id, :source_id => @source.id }
    assigns[:offer].gifts.size.should         == 4  # g1, g2, g3 and g4
    assigns[:optional_gifts].size.should      == 2  # optional gifts = (instock but not included) -> g2, g4
    assigns[:included_gifts].size.should      == 1  # included gifts = (instock and included)     -> g1
    assigns[:subscription].offer.id.should    == @offer.id
  end
  
  it "should successfully call on_next method on offer and set the subscription's price, expiry date and optional gifts that the user has chosen - subscription is not expired yet" do
    @subscription.expires_at = Date.strptime("2010-10-31", '%Y-%m-%d')  # in this case, subscription has a previous expiry date
    @ot2.months = 3 # 3 months
    new_expires_at = Date.strptime("2011-1-31", '%Y-%m-%d') # old expires_at plus offer term's months (3 months)
  
    post :offer, {:commit=>'Next', :offer_term => @ot2, :subscription => {:subscription_gifts_attributes => {"0" => {:gift_id => @g2}}}}, nil, {:subscribe_dat => @subscription.attributes}
    assigns[:subscription].offer.id.should    == @offer.id
    assigns[:subscription].price.should       == @ot2.price
    assigns[:subscription].expires_at.year.should  == new_expires_at.year
    assigns[:subscription].expires_at.month.should  == new_expires_at.month
    assigns[:subscription].expires_at.day.should  == new_expires_at.day
    assigns[:subscription].gifts.size.should  == 2 # included and selected gift
  end
  
  it "should successfully call on_next method on offer and set the subscription's price, expiry date and optional gifts that the user has chosen - no offer_term" do
    @subscription.expires_at = Date.strptime("2010-10-31", '%Y-%m-%d')  # in this case, subscription has a previous expiry date
    @ot2.months = 3 # 3 months
    new_expires_at = Date.strptime("2011-1-31", '%Y-%m-%d') # old expires_at plus offer term's months (3 months)
    
    post :offer, {:commit=>'Next', :offer_term => nil, :subscription => {:subscription_gifts_attributes => {"0" => {:gift_id => @g2}}}}, nil, {:subscribe_dat => @subscription.attributes}
    assigns[:subscription].offer.id.should    == @offer.id
    assigns[:subscription].price.should       == @ot1.price # the first offer
    assigns[:subscription].expires_at.year.should  == new_expires_at.year
    assigns[:subscription].expires_at.month.should  == new_expires_at.month
    assigns[:subscription].expires_at.day.should  == new_expires_at.day
    assigns[:subscription].gifts.size.should  == 2 # included and selected gift
  end
  
  it "should successfully call on_next method on offer and set the subscription's price, expiry date and optional gifts that the user has chosen - new subscription" do
    @ot2.months = 3 # 3 months
    new_expires_at = Date.today.months_since(3)  # 3 months from now
  
    post :offer, {:commit=>'Next', :offer_term => @ot2, :subscription => {:subscription_gifts_attributes => {"0" => {:gift_id => @g2}}}}, nil, {:subscribe_dat => @subscription.attributes}
    assigns[:subscription].offer.id.should    == @offer.id
    assigns[:subscription].price.should       == @ot2.price
    assigns[:subscription].expires_at.year.should  == new_expires_at.year
    assigns[:subscription].expires_at.month.should  == new_expires_at.month
    assigns[:subscription].expires_at.day.should  == new_expires_at.day
    assigns[:subscription].gifts.size.should  == 2 # included and selected gift
  end
  
  it "should successfully call on_next method on offer and set the subscription's price, expiry date and optional gifts that the user has chosen - expired subscription" do
    @subscription.expires_at = Date.strptime("2008-10-31", '%Y-%m-%d')  # expired subscription
    @ot2.months = 3 # 3 months
    new_expires_at = Date.today.months_since(3)  # 3 months from now
  
    post :offer, {:commit=>'Next', :offer_term => @ot2, :subscription => {:subscription_gifts_attributes => {"0" => {:gift_id => @g4}}}}, nil, {:subscribe_dat => @subscription.attributes}
    assigns[:subscription].offer.id.should    == @offer.id
    assigns[:subscription].price.should       == @ot2.price
    assigns[:subscription].expires_at.year.should  == new_expires_at.year
    assigns[:subscription].expires_at.month.should  == new_expires_at.month
    assigns[:subscription].expires_at.day.should  == new_expires_at.day
    assigns[:subscription].gifts.size.should  == 2 # included and selected gift
    assigns[:subscription].gifts.should == [@g4, @g1]
  end
  
  it "should successfully call on_next method on offer and set the subscription's price, expiry date and optional gifts that the user has chosen - no gift params" do
    @subscription.expires_at = Date.strptime("2010-10-31", '%Y-%m-%d')  # in this case, subscription has a previous expiry date
    @ot2.months = 3 # 3 months
    new_expires_at = Date.strptime("2011-1-31", '%Y-%m-%d') # old expires_at plus offer term's months (3 months)
    
    post :offer, {:commit=>'Next', :offer_term => nil, :subscription => {}}, nil, {:subscribe_dat => @subscription.attributes}
    assigns[:subscription].offer.id.should          == @offer.id
    assigns[:subscription].price.should             == @ot1.price # the first offer
    assigns[:subscription].expires_at.year.should   == new_expires_at.year
    assigns[:subscription].expires_at.month.should  == new_expires_at.month
    assigns[:subscription].expires_at.day.should    == new_expires_at.day
    assigns[:subscription].gifts.size.should  == 1 # included and selected gift
  end
  
  # --------------------------------------------- USER DETAILS SENARIOs #
  ## GET
  it "should successfully call on_get method on details and set the user - first time user" do
    get 'details', nil, {:user_dat => nil}
    assigns[:user].should_not     be_nil  # user should be newed but with empty values
    assigns[:user].country.should == "Australia"
    assigns[:user].login.should    == nil
  end
  
  it "should successfully call on_get method on details and set the user - valid user session" do
    get 'details', nil, {:user_dat => Factory.attributes_for(:user)}
    assigns[:user].should_not     be_nil  # user should be newed but with empty values
    assigns[:user].country.should == "Australia"
    assigns[:subscription].user.should_not  be_nil
  end
  
  ## POST
  it "should successfully call on_next method on details and set the user session - any type of offer(trial/full subscription), invalid new user" do
    user = @subscription.build_user # user details are empty
    post :details, {:commit => 'Next', :new_or_existing => 'new'}, nil, {:subscribe_dat => {:user => user, :offer_id => @offer.id}}
    
    session[:new_user].should           be_true
    session[:user_dat]["login"].should  == nil
    flash[:error].should_not            be_nil
    flash[:notice].should               be_nil
    response.should render_template('details')
  end

  it "should successfully call on_next method on details and set the user session - any type of offer(trial/full subscription), invalid existing user" do
    user = Factory(:user) # user exists in database
    empty_user = @subscription.build_user({:login => user.login}) # user details are empty

    post :details, {:commit => 'Next', :new_or_existing => 'existing', :subscription => {:user_attributes => {:login => user.login, :password => nil}}}, # input parameters filled in with user
                    nil, {:subscribe_dat => {:user => empty_user, :offer_id => @offer.id}} # flash attributes to setup the wizard to its current status
    
    session[:new_user].should_not           be_true
    assigns[:subscription].user.id.should   be_nil
    flash[:error].should                    == "Invalid login name or password"
    flash[:notice].should                   be_nil
    response.should                         render_template('details')
  end

  it "should successfully call on_next method on details and set the user session - valid new user, non-trial subscription" do
    user = User.new(Factory.attributes_for(:user))
    
    post :details, {:commit => 'Next', :new_or_existing => 'new'}, nil, {:subscribe_dat => {:user => user, :offer_id => @offer.id}}
    
    session[:new_user].should                   be_true
    # session[:user_dat] should be correctly set as it will be used later in finalizing the wizard and saving the new user.
    session[:user_dat]["login"].should          == user.login
    session[:user_dat]["firstname"].should      == user.firstname
    session[:user_dat]["lastname"].should       == user.lastname
    session[:user_dat]["email"].should          == user.email
    session[:user_dat]["email_confirmation"].should  == user.email
    session[:user_dat]["phone_number"].should   == user.phone_number
    session[:user_dat]["address_1"].should      == user.address_1
    session[:user_dat]["postcode"].should       == user.postcode
    session[:user_dat]["city"].should           == user.city
    session[:user_dat]["state"].should          == user.state
    session[:user_dat]["country"].should        == user.country
    flash[:error].should                              be_nil
    flash[:notice].should                             be_nil
    response.should                                   redirect_to :action => :payment
  end
  
  it "should successfully call on_next method on details, save the subscription and end the wizard - valid new user, trial subscription" do
    trial_offer = Factory(:offer, :trial => true)
    user = User.new(Factory.attributes_for(:user))

    post :details, {:commit => 'Next', :new_or_existing => 'new'}, nil, {:subscribe_dat => {:user => user, :offer_id => trial_offer.id}}
    
    session[:new_user].should                         be_true
    assigns[:subscription].offer.is_trial?.should     be_true
    assigns[:subscription].user.should_not            be_nil
    assigns[:subscription].user.login.should          == user.login
    assigns[:subscription].user.firstname.should      == user.firstname
    assigns[:subscription].user.lastname.should       == user.lastname
    assigns[:subscription].user.email.should          == user.email
    assigns[:subscription].user.phone_number.should   == user.phone_number
    assigns[:subscription].user.address_1.should      == user.address_1
    assigns[:subscription].user.postcode.should       == user.postcode
    assigns[:subscription].user.city.should           == user.city
    assigns[:subscription].user.state.should          == user.state
    assigns[:subscription].user.country.should        == user.country
    assigns[:subscription].user.recurrent_id.should   == nil  # because the subscription is a trial, so the user does not have a recurrent profile yet.
    assigns[:subscription].state.should              == 'trial'
    flash[:error].should                              be_nil
    flash[:notice].should                             == "Congratulations! Your trial subscribtion was successful."
    response.should                                   redirect_to :action => :offer
  end

  it "should successfully call on_next method on details, save the subscription and end the wizard - valid existing user, non-trial subscription" do
    user = Factory(:user)

    post :details, {:commit => 'Next', :new_or_existing => 'existing', :subscription => {:user_attributes => {:login => user.login, :password => user.password}}}, # input parameters filled in with user
                    nil, {:subscribe_dat => {:user => user, :offer_id => @offer.id}} # flash attributes to setup the wizard to its current status
    
    session[:new_user].should                         be_false
    session[:user_dat].should                         be_nil
    assigns[:subscription].offer.is_trial?.should     be_false
    assigns[:subscription].user.should_not            be_nil
    assigns[:subscription].user.login.should          == user.login
    assigns[:subscription].user.firstname.should      == user.firstname
    assigns[:subscription].user.lastname.should       == user.lastname
    assigns[:subscription].user.email.should          == user.email
    assigns[:subscription].user.phone_number.should   == user.phone_number
    assigns[:subscription].user.address_1.should      == user.address_1
    assigns[:subscription].user.postcode.should       == user.postcode
    assigns[:subscription].user.city.should           == user.city
    assigns[:subscription].user.state.should          == user.state
    assigns[:subscription].user.country.should        == user.country
    assigns[:subscription].user.recurrent_id.should   == nil  # because the subscription is a trial, so the user does not have a recurrent profile yet.
    flash[:error].should                              be_nil
    flash[:notice].should                             be_nil
    response.should                                   redirect_to :action => :payment
  end

  it "should successfully call on_next method on details and set the user session - valid existing user, trial subscription" do
    trial_offer = Factory(:offer, :trial => true)
    user = Factory(:user) # user exists

    post :details, {:commit => 'Next', :new_or_existing => 'existing', :subscription => {:user_attributes => {:login => user.login, :password => user.password}}}, # input parameters filled in with user
                    nil, {:subscribe_dat => {:user => user, :offer_id => trial_offer.id}} # flash attributes to setup the wizard to its current status
    
    session[:new_user].should                         be_false
    session[:user_dat].should                         be_nil
    assigns[:subscription].offer.is_trial?.should     be_true
    assigns[:subscription].user.should_not            be_nil
    assigns[:subscription].user.login.should          == user.login
    assigns[:subscription].user.firstname.should      == user.firstname
    assigns[:subscription].user.lastname.should       == user.lastname
    assigns[:subscription].user.email.should          == user.email
    assigns[:subscription].user.phone_number.should   == user.phone_number
    assigns[:subscription].user.address_1.should      == user.address_1
    assigns[:subscription].user.postcode.should       == user.postcode
    assigns[:subscription].user.city.should           == user.city
    assigns[:subscription].user.state.should          == user.state
    assigns[:subscription].user.country.should        == user.country
    assigns[:subscription].user.recurrent_id.should        == nil  # because the subscription is a trial, so the user does not have a recurrent profile yet.
    assigns[:subscription].state.should              == 'trial'
    flash[:error].should                              be_nil
    flash[:notice].should                             == "Congratulations! Your trial subscribtion was successful."
    response.should                                   redirect_to :action => :offer
  end
  
  # --------------------------------------------- PAYMENT SENARIOs #
  ## GET
  it "should successfully call on_get method on payment and set the payment" do
    get :payment
    assigns[:payment].should_not     be_nil  # payment should be newed but with empty values
  end

  ## POST
  # testcase scenario:
  # all inputs of setup_recurrent are correctly set(price, credit_card details, client_id)
  # setup_recurrent is called for the first time for this user
  # the responce should be success
  # trigger_recurrent is called for payment of the full subscription fee
  # the respnce should be success
  # subscription is updated (ex. (state = active), expiry_date, state_updated_at, ...)
  # redirected to (offer page?) with a notice on successful subscription
  it "should successfully call on_post method on payment and successfully change from trial to full-subscription- new user" do
    user = User.new(Factory.attributes_for(:user))

    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:new_user => true, :user_dat => Factory.attributes_for(:user) },    # the session that is used by the wizardly gem
                    {:subscribe_dat => {:user => user, :offer_id => @offer.id, :price => 15, :expires_at => Date.new(2010, 10, 5)}} # flash attributes to setup the wizard to its current status
  
  
    assigns[:subscription].should_not             be_new_record       # subscription wizard active record should be saved
    assigns[:subscription].state.should           == 'active'
    assigns[:subscription].price.should           == 15
    assigns[:subscription].expires_at.should_not  be_nil
    assigns[:subscription].offer.id.should        == @offer.id
    assigns[:subscription].publication.should_not be_nil
    assigns[:subscription].user.should_not        be_nil
    assigns[:subscription].user.id.should_not     be_nil
    assigns[:subscription].user.recurrent_id.should_not == "0"
    assigns[:subscription].user.recurrent_id.to_i.should < 10000000000000000000 # less than 20 numbers
    TransactionLog.find_by_recurrent_id(assigns[:subscription].user.recurrent_id.to_s).should_not be_nil
    TransactionLog.find_by_recurrent_id_and_action(assigns[:subscription].user.recurrent_id.to_s, "setup new recurrent profile").should_not be_nil
    TransactionLog.find_by_recurrent_id_and_action(assigns[:subscription].user.recurrent_id.to_s, "trigger existing recurrent profile").should_not be_nil
    flash[:notice].should == "Congratulations! Your subscribtion was successful."
    flash[:error].should  be_nil
    response.should redirect_to(:action => :offer)
  end
  
  it "should successfully call on_post method on payment and successfully change from trial to full-subscription- existing user with non-existing recurrent profile" do #FIXME
    user = Factory(:user) # user exists
    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:new_user => false, :user_dat => Factory.attributes_for(:user) },    # the session that is used by the wizardly gem
                    {:subscribe_dat => {:user => user, :offer_id => @offer.id, :price => 15, :expires_at => Date.new(2010, 10, 5)}} # flash attributes to setup the wizard to its current status
  
  
    assigns[:subscription].should_not             be_new_record       # subscription wizard active record should be saved
    assigns[:subscription].state.should           == 'active'
    assigns[:subscription].price.should           == 15
    assigns[:subscription].expires_at.should_not  be_nil
    assigns[:subscription].offer.id.should        == @offer.id
    assigns[:subscription].publication.should_not be_nil
    assigns[:subscription].user.should_not        be_nil
    assigns[:subscription].user.id.should         == user.id
    assigns[:subscription].user.recurrent_id.to_i.should_not == 0
    assigns[:subscription].user.recurrent_id.to_i.should < 10000000000000000000 # less than 20 numbers
    TransactionLog.find_by_recurrent_id(assigns[:subscription].user.recurrent_id.to_s).should_not be_nil
    TransactionLog.find_by_recurrent_id_and_action(assigns[:subscription].user.recurrent_id.to_s, "setup new recurrent profile").success.should be_true
    TransactionLog.find_by_recurrent_id_and_action(assigns[:subscription].user.recurrent_id.to_s, "trigger existing recurrent profile").success.should be_true
    flash[:notice].should == "Congratulations! Your subscribtion was successful."
    flash[:error].should  be_nil
    response.should redirect_to(:action => :offer)
  end

  it "should successfully call on_post method on payment and successfully change from trial to full-subscription- new user with existing recurrent profile" do
  end
  
  it "should successfully call on_post method on payment and successfully change from trial to full-subscription- existing user with existing recurrent profile" do
    user = Factory(:user, :recurrent_id => "4332118890") # user exists

    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:new_user => false, :user_dat => nil },    # the session that is used by the wizardly gem
                    {:subscribe_dat => {:user_id => user.id, :offer_id => @offer.id, :price => 15, :expires_at => Date.new(2010, 10, 5)}} # flash attributes to setup the wizard to its current status
  
    assigns[:subscription].should_not             be_new_record       # subscription wizard active record should be saved
    assigns[:subscription].state.should           == 'active'
    assigns[:subscription].price.should           == 15
    assigns[:subscription].expires_at.should_not  be_nil
    assigns[:subscription].offer.id.should        == @offer.id
    assigns[:subscription].publication.should_not be_nil
    assigns[:subscription].user.should_not        be_nil
    assigns[:subscription].user.id.should         == user.id
    assigns[:subscription].user.recurrent_id.to_i.should == 4332118890
    TransactionLog.find_by_recurrent_id(assigns[:subscription].user.recurrent_id.to_s).should_not be_nil
    TransactionLog.find_by_recurrent_id_and_action(assigns[:subscription].user.recurrent_id.to_s, "trigger existing recurrent profile").success.should be_true
    flash[:notice].should == "Congratulations! Your subscribtion was successful."
    flash[:error].should  be_nil
    response.should redirect_to(:action => :offer)
  end

  it "should redirect to the first page of wizard with errors when trying to finish the wizard with invalid credit card" do
    user = User.new(Factory.attributes_for(:user))

    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => '0', # invalid creditcard
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:new_user => true, :user_dat => Factory.attributes_for(:user) },    # the session that is used by the wizardly gem
                    {:subscribe_dat => {:user => user, :offer_id => @offer.id, :price => 15, :expires_at => Date.new(2010, 10, 5)}} # flash attributes to setup the wizard to its current status
  
  
    assigns[:subscription].should_not       be_new_record # subscription wizard active record should be saved(with trial)
    assigns[:subscription].state.should     == 'trial'    # because the wizard hasnt been completed
    TransactionLog.find_by_action("setup new recurrent profile").success.should be_false
    TransactionLog.find_by_action("trigger existing recurrent profile").should be_nil
    flash[:error].should                    == "Unfortunately your payment was not successfull. Please check your credit card details and try again."
    response.should render_template(:payment)
  end
  
  it "should redirect to the first page of wizard with errors when trying to finish the wizard with invalid subscription price" do
    user = User.new(Factory.attributes_for(:user))
  
    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:new_user => true, :user_dat => Factory.attributes_for(:user) },    # the session that is used by the wizardly gem
                    {:subscribe_dat => {:user => user, :offer_id => @offer.id, :price => nil, :expires_at => Date.new(2010, 10, 5)}} # flash attributes to setup the wizard to its current status
  
  
    assigns[:subscription].should_not       be_new_record # subscription wizard active record should be saved(with trial)
    assigns[:subscription].state.should     == 'trial'    # because the wizard hasnt been completed
    TransactionLog.find_by_action("setup new recurrent profile").should be_nil
    TransactionLog.find_by_action("trigger existing recurrent profile").should be_nil
    flash[:error].should                    == "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
    response.should redirect_to(:action => :offer)
  end
  
  it "should redirect to the first page of wizard with errors when trying to finish the wizard with no subscription price" do
    user = User.new(Factory.attributes_for(:user))
  
    post :payment, {:commit=>'Finish',  :payment => { 
                                              :card_type          => "visa",
                                              :card_number        => "4444333322221111",
                                              :card_verification  => '444',
                                              "card_expires_on(1i)" => Date.today.year.next,
                                              "card_expires_on(2i)" => '1',
                                              "card_expires_on(3i)" => '1'}},
                    {:new_user => true, :user_dat => Factory.attributes_for(:user) },    # the session that is used by the wizardly gem
                    {:subscribe_dat => {:user => user, :offer_id => @offer.id, :price => 0, :expires_at => Date.new(2010, 10, 5)}} # flash attributes to setup the wizard to its current status
  
  
    assigns[:subscription].should_not       be_new_record # subscription wizard active record should be saved(with trial)
    assigns[:subscription].state.should     == 'trial'    # because the wizard hasnt been completed
    TransactionLog.find_by_action("setup new recurrent profile").should be_nil
    TransactionLog.find_by_action("trigger existing recurrent profile").should be_nil
    flash[:error].should                    == "Unfortunately your payment was not successfull. Please check that your account has the amount and try again later."
    response.should redirect_to(:action => :offer)
  end
end
