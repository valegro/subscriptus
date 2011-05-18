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
    User.expects(:find_or_create_with_trial).with(
      instance_of(Publication),
      Publication::DEFAULT_TRIAL_EXPIRY,
      "http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591",
      { :first_name => 'Daniel', :last_name => 'Draper', :email => 'example@example.com', :ip_address => '150.101.226.181',
        :options => { :solus => nil, :weekender => nil }
      }
    )
    post 'create', { "data.json"=>"{\"ip_address\":\"150.101.226.181\",\"email\":[\"example@example.com\"],\"last_name\":[\"Draper\"],\"first_name\":[\"Daniel\"]}", "page_url"=>"http://unbouncepages.com/bf43f31e-e55b-11df-82d5-12313e003591", "page_id"=>"bf43f31e-e55b-11df-82d5-12313e003591", "variant"=>"a", "publication_id" => @publication.id }
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
  end
end
