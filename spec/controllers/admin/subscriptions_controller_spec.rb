require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscriptionsController, "as admin" do

  integrate_views

  before(:each) do
    stub_wordpress
    admin_login
    https!
  end

  it "should have search" do
    get :search
    response.should be_success
  end

  describe "create new subscription" do
    before(:each) do
      @user = Factory.create(:subscriber)
      @pub_a = Factory.create(:publication)
      @pub_b = Factory.create(:publication)
      @attrs = { :subscriber_id => @user.id, :subscription => { :state => 'active', :expires_at => 2.weeks.from_now.to_s, :publication_id => @pub_a.id }}
    end

    describe "visit the form" do
      it "should show me the publications in a drop down"
    end

    describe "provide all correct data" do
      it "should add the subscription to the user" do
        expect {
          post :create, @attrs
        }.to change { @user.subscriptions(true).count }.by(1)
      end

      it "should NOT send an email" do
        stub_mailer(SubscriptionMailer).expects(:deliver!).never
      end
    end

    describe "try to add a publication for which there is already a subscription" do
      before(:each) do
        @user.subscriptions.create(:publication => @pub_a, :expires_at => 2.weeks.from_now, :state => 'active')
      end

      it "should show me an error" do
        # See http://rhnh.net/2008/04/19/testing-flash-now-with-rspec
        @controller.instance_eval { flash.extend(DisableFlashSweeping) }
        post :create, @attrs
        flash.now[:error].should == 'The subscriber already has a subscription to that publication'
      end

      it "should not add the subscription" do
        expect {
          post :create, @attrs
        }.to change { @user.subscriptions(true).count }.by(0)
      end
    end

    describe "invalid or missing data" do
      it "should show me the new page again" do
        post :create, {:subscriber_id => @user.id}
        response.should render_template("new")
      end
    end
  end

  describe "searching" do
    it "should create an appropriate search object" do
      @s = Subscription.search
      Subscription.expects(:search).with( 'spam' => 'lots' ).returns( @s )
      get :search, :page => 2, :search => { :spam => 'lots' }
      assigns[:search].should == @s
    end

    it "should assign results and count" do
      Subscription.expects(:per_page).returns( 20 )
      get :search, :page => 2, :search => { :publication_id => 1 }
      assigns[:results].should_not be_nil
      assigns[:count].should_not be_nil
    end
  end

  describe "on unsubscribe" do
    describe "a subscription that has NOT already been unsubscribed" do
      before(:each) do
        @subscription = Factory.create(:active_subscription)
        get('unsubscribe', :id => @subscription.id)
      end

      it "should now be unsubscribed" do
        s = Subscription.find(@subscription.id)
        s.state.should == 'unsubscribed'
      end

      it "should show me the subscription page" do
        response.should redirect_to(:action => :show, :id => @subscription.id)
      end
    end

    describe "a subscription that has already been unsubscribed" do
      before(:each) do
        @subscription = Factory.create(:unsubscribed_subscription)
        get('unsubscribe', :id => @subscription.id)
      end

      it "should show me a flash error" do
        flash[:error].should == 'Already Unsubscribed'
      end

      it "should show me the subscription page" do
        response.should redirect_to(:action => :show, :id => @subscription.id)
      end
    end
  end

  describe "pending" do
    before(:each) do
      @subscription = Factory.create(:pending_subscription)
    end

    it "should list all pending subscriptions" do
      get :pending
      assigns[:subscriptions].empty?.should be_false
    end

    it "should create log entry on verify with payment" do
      @subscription.pending = 'payment'
      @subscription.save!
      Subscription.any_instance.expects(:verify!)
      post :verify, :id => @subscription.id, :payment => { "reference" => "1234", "payment_type" => "direct_debit" }
      response.should redirect_to :action => :pending
    end

    it "should verify if payment is successful" do
      success = stub(:success? => true, :params => { 'ponum' => '1234' })
      GATEWAY.expects(:trigger_recurrent).returns(success)
      post :verify, :id => @subscription.id, :subscription => { :note => "A note about verification" }
      flash[:notice].should == "Verified Subscription"
      response.should redirect_to :action => :pending
    end

    it "should not verify if the subscription has already been verified" do
      @subscription = Factory.create(:active_subscription)
      post :verify, :id => @subscription.id, :payment => { "reference" => "1234", "payment_type" => "direct_debit" }
      flash[:error].should == "Subscription has already been verified"
      response.should redirect_to :action => :pending
    end

    it "should handle a failed payment" do
      failure = stub(:success? => false, :message => "Test Failure")
      GATEWAY.expects(:trigger_recurrent).returns(failure)
      post :verify, :id => @subscription.id, :subscription => { :note => "A note about verification" }
      flash[:error].should == "The Subscriber's Card was declined. You may need to contact them."
      response.should render_template("admin/subscriptions/verify")
    end

    it "should handle a missing payment token" do
      @subscription.user.update_attributes(:payment_gateway_token => nil)
      post :verify, :id => @subscription.id, :subscription => { :note => "A note about verification" }
      flash[:error].should == "The User has no payment gateway token - the payment will need to processed manually"
      response.should render_template("admin/subscriptions/verify")
    end
  end
end

describe Admin::SubscriptionsController, "as user" do
  before(:each) do
    stub_wordpress
    user_login
    https!
  end
  it "should not show index" do
    get :index
    response.should redirect_to login_url
  end
  it "should not show search"  do
    get :search
    response.should redirect_to login_url
  end
  it "should not show pending" do
    get :pending
    response.should redirect_to login_url
  end
end

describe Admin::SubscriptionsController, "not logged in" do
  before(:each) do
    https!
  end

  it "should not show index" do
    get :index
    response.should redirect_to login_url
  end
  it "should not show search"  do
    get :search
    response.should redirect_to login_url
  end
  it "should not show pending" do
    get :pending
    response.should redirect_to login_url
  end
end

