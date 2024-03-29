require 'spec_helper'

describe Webhooks::UnbouncesController do

  before(:each) do
    @publication = Factory(:publication)
    cm_return = stub(:success? => true)
    CM::Recipient.stubs(:exists?).returns(true)
    CM::Recipient.stubs(:find_all).returns(cm_return)
    CM::Recipient.stubs(:update)
    CM::Recipient.stubs(:create!)
    stub_wordpress
    https!
  end

  shared_examples_for "an unbounce webhook" do
    it "should create a new trial subscription" do
      User.expects(:find_or_create_with_trial).with(
        instance_of(Publication),
        Publication::DEFAULT_TRIAL_EXPIRY,
        "http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591",
        { :first_name => 'Daniel', :last_name => 'Draper', :email => 'example@example.com', :ip_address => '150.101.226.181',
          :options => { :solus => nil, :weekender => nil }
        }
      )
      self.send(@_method, 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id })
      response.body.should == "{\"success\":true}"
    end

    it "should create a new trial subscription with weekender" do
      User.expects(:find_or_create_with_trial).with(
        instance_of(Publication),
        Publication::DEFAULT_TRIAL_EXPIRY,
        "http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591",
        { :first_name => 'Daniel', :last_name => 'Draper', :email => 'example@example.com', :ip_address => '150.101.226.181',
          :options => { :solus => false, :weekender => true }
        }
      )

      post('create', {
        "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"],\"options\":[\"Yes - send me Your Weekender\"]}",
        "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591",
        "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591",
        "variant"=>"a",
        "publication_id" => @publication.id 
      })
      response.body.should == "{\"success\":true}"
    end

    it "should create a new trial subscription with solus" do
      User.expects(:find_or_create_with_trial).with(
        instance_of(Publication),
        Publication::DEFAULT_TRIAL_EXPIRY,
        "http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591",
        { :first_name => 'Daniel', :last_name => 'Draper', :email => 'example@example.com', :ip_address => '150.101.226.181',
          :options => { :solus => true, :weekender => false }
        }
      )

      post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"],\"options\":[\"Tick this box if you want to receive carefully selected offers by email from advertisers screened by Crikey\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
      response.body.should == "{\"success\":true}"
    end

    describe "if no data is provided" do
      it "should respond with an error" do
        post "create",  {}
        body_json = JSON.parse(response.body)
        body_json.should == { "success" => false, "message" => "Please provide a data.json parameter" }
      end
    end

    describe "if the user exists with a trial subscription" do
      before(:each) do
        @user = Factory.create(:user, :email => 'example@example.com')
        @subscription = Factory.create(:subscription, :state => 'trial', :user => @user, :publication => @publication)
      end

      it "should return an error" do
        post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
        body_json = JSON.parse(response.body)
        body_json.should == { "success" => false, "message" => "Trial within last 12 months" }
      end
    end

    describe "if the user exists with a squatter subscription that has been that way for less than 12 months" do
      before(:each) do
        @user = Factory.create(:user, :email => 'example@example.com')
        @subscription = Factory.create(:subscription, :state => 'squatter', :user => @user, :publication => @publication)
      end

      it "should return an error" do
        post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
        body_json = JSON.parse(response.body)
        body_json.should == { "success" => false, "message" => "Trial within last 12 months" }
      end
    end

    describe "if the user exists with a squatter subscription that has been that way for MORE than 12 months" do
      before(:each) do
        @user = Factory.create(:user, :email => 'example@example.com')
        @subscription = Factory.create(:subscription, :state => 'squatter', :user => @user, :publication => @publication)
      end

      it "should make the subscription a trial again" do
        Timecop.travel(13.months.from_now) do
          post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
          Subscription.find(@subscription.id).trial?.should be(true)
        end
      end
    end

    describe "if the subscription exists but is invalid and the password is blank" do
      before(:each) do
        @user = Factory.create(:user, :email => 'example@example.com')
        @user.phone_number = nil # Force to be invalid
        @user.password = nil
        @user.password_confirmation = nil
        @user.save_with_validation(false)
      end

      # I'm not sure if this is the correct behaviour!
      it "should succeed anyway" do
        post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
        body_json = JSON.parse(response.body)
        user = User.find(@user.id)
        user.email.should == 'example@example.com'
        user.lastname.should == 'Draper'
        body_json.should == { "success" => true }
      end
    end
  end

  describe "when the method is post" do
    before(:each) do
      @_method = :post
    end
    it_should_behave_like "an unbounce webhook"
  end

  describe "when the method is get" do
    before(:each) do
      @_method = :get
    end
    it_should_behave_like "an unbounce webhook"
  end
end
