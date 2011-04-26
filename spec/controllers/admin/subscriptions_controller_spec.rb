require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscriptionsController, "as admin" do
  before(:each) do
    stub_wordpress
    admin_login
  end

  it "should have search" do
    get :search
    response.should be_success
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
      puts response.body
      assigns[:results].should_not be_nil
      assigns[:count].should_not be_nil
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
  end
end

describe Admin::SubscriptionsController, "as user" do
  before(:each) do
    stub_wordpress
    user_login
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

