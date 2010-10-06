require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscriptionsController, "as admin" do
  before(:each) do
    admin_login
  end
  it "should have subscriptions layout"
  it "should have index"
  it "should have activity"
  it "should have pending"
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
end

describe Admin::SubscriptionsController, "as user" do
  before(:each) do
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

