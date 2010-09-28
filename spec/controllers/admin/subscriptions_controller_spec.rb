require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::SubscriptionsController do
  it "should have subscriptions layout"
  it "should have index"
  it "should have activity"
  it "should have pending"
  it "should have search"
  describe "searching" do
    it "should create an appropriate search object" do
      @s = Subscription.search
      Subscription.should_receive(:search).with( 'spam' => 'lots' ).and_return( @s )
      get :search, :page => 2, :search => { :spam => 'lots' }
      assigns[:search].should == @s
    end

    it "should assign results and count" do
      Subscription.should_receive(:per_page).and_return( 20 )
      get :search, :page => 2, :search => { :publication_id => 1 }
      assigns[:results].should_not be_nil
      assigns[:count].should_not be_nil
    end
  end
end
