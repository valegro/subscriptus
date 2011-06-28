require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscribersController, "as admin" do
  before(:each) do
    stub_wordpress
    admin_login
    https!
  end

  describe "on create" do
    describe "if post with valid data" do
      before(:each) do
        @attrs = Factory.attributes_for(:subscriber)
      end

      it "should create a subscriber" do
        expect {
          post(:create, :user => @attrs)
        }.to change { User.subscribers.count }.by(1)
      end

      it "should redirect to the subscriber show page" do
        post(:create, :user => @attrs)
        response.should redirect_to(:action => :show, :id => User.subscribers.last.id)
      end
    end

    describe "if post with missing or invalid data" do
      it "should show the form again" do
        post(:create, :user => {})
        response.should render_template("new")
      end
    end

    describe "if email already exists in WP but not in subscriptus" do
      before(:each) do
        @attrs = Factory.attributes_for(:subscriber, :email => 'daniel@netfox.com')
        Wordpress.stubs(:exists?).with(:email => 'daniel@netfox.com').returns(true)
      end

      it "should create the user anyway" do
        expect {
          post(:create, :user => @attrs)
        }.to change { User.subscribers.count }.by(1)
      end
    end
  end

  describe "on update" do
    before(:each) do
      @subscriber = Factory.create(:subscriber)
    end

    describe "given that wordpress will raise an error" do
      before(:each) do
        Wordpress.expects(:make_request).raises(Wordpress::Error, "Test Error")
        Admin::SubscribersController.any_instance.expects(:notify_hoptoad).with(instance_of(Wordpress::Error))
      end

      it "should show the edit page with the error in the flash" do
        post(:update, :id => @subscriber.id)
        response.should render_template("edit")
        flash[:error].should == "Wordpress Error: Test Error"
      end
    end
  end

  describe "on sync" do
    before(:each) do
      @user = stub(:id => 100)
      subscribers_proxy = mock()
      subscribers_proxy.stubs(:find).with('100').returns(@user)
      User.stubs(:subscribers).returns(subscribers_proxy)
    end

    it "should sync to Campaign Master and Wordpress" do
      @user.expects(:sync_to_wordpress)
      @user.expects(:sync_to_campaign_master)
      post(:sync, :id => 100)
    end

    it "should redirect to the show page" do
      @user.expects(:sync_to_wordpress)
      @user.expects(:sync_to_campaign_master)
      post(:sync, :id => 100)
      response.should redirect_to :action => :show
    end
  end
end
