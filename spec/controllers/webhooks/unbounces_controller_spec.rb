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
  end

  it "should create a new trial subscription" do
    cnt = User.count
    post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
    # Check JSON
    assigns[:json][:email].should == ['example@example.com']
    # Check user
    assigns[:subscription].user.email.should == 'example@example.com'
    assigns[:subscription].user.firstname.should == 'Daniel'
    assigns[:subscription].user.lastname.should == 'Draper'
    assigns[:subscription].user.subscriptions.count.should == 1
    # Check Subscription
    expiry = Publication::DEFAULT_TRIAL_EXPIRY.days.from_now
    assigns[:subscription].state.should == 'trial'
    assigns[:subscription].expires_at.day.should == expiry.day
    assigns[:subscription].expires_at.month.should == expiry.month
    assigns[:subscription].expires_at.year.should == expiry.year
    assigns[:subscription].publication_id.should == @publication.id
    assigns[:subscription].referrer.should == "http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591"
    assigns[:subscription].weekender.should_not == true
    assigns[:subscription].solus.should_not == true

    User.count.should == cnt + 1

    # Post again - should raise
    lambda {
      post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
    }.should raise_exception
    User.count.should == cnt + 1
  end

  #TODO: Most of these checks belong in the model - we should just check that the right call is being made and that the subscription count increases
  it "should create a new trial subscription with weekender" do
    post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"],\"options\":[\"Yes - send me Your Weekender\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
    assigns[:subscription].user.email.should == 'example@example.com'
    assigns[:subscription].user.firstname.should == 'Daniel'
    assigns[:subscription].user.lastname.should == 'Draper'
    assigns[:subscription].user.subscriptions.count.should == 1
    # Check Subscription
    assigns[:subscription].weekender.should == true
    assigns[:subscription].solus.should_not == true
  end

  it "should create a new trial subscription with solus" do
    post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"],\"options\":[\"Tick this box if you want to receive carefully selected offers by email from advertisers screened by Crikey\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
    assigns[:subscription].user.email.should == 'example@example.com'
    assigns[:subscription].user.firstname.should == 'Daniel'
    assigns[:subscription].user.lastname.should == 'Draper'
    assigns[:subscription].user.subscriptions.count.should == 1
    # Check Subscription
    assigns[:subscription].weekender.should_not == true
    assigns[:subscription].solus.should == true
  end

end
