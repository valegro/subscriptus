require 'spec_helper'

describe "Renewals", :type => :request do
  before(:each) do
    @user = Factory.create(:subscriber)
    @subscription = Factory.create(:subscription, :user => @user)
  end

  describe "I visit the renewal page" do

    context "#I am not logged in" do
      it "should prompt me to login"
    end

    context "#I am logged in" do
      before(:each) do
        SubscribeController.any_instance.stubs(:current_user).with(@user)
      end

      it "should display the renewals page" do
        visit "/renew"
        page.should have_content("Renew your Subscription")
      end

      describe "and I do not modify my details" do
        visit "/renew"
        it "should NOT create a new subscription" do
          expect {
            click_link_or_button "btnSubmit"
          }.to_not change { Subscription.count }
        end

        it "should extend and activate my subscription"
        it "should display the thanks page"
      end

      describe "and I change some of my personal details" do
        before(:each) do
          fill_in "First Name", :with => "Sam"
        end

      end
    end
  end
      
  it "should create a subscription if a user has no subscriptions but tries to renew"

  # TODO: Test if auth succeeds but there is no subscriptus user to match
end
