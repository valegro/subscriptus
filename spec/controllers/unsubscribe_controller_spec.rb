require 'spec_helper'

describe UnsubscribeController do

  integrate_views

  before(:each) do
    stub_wordpress
    @user = User.create!(Factory.attributes_for(:subscriber, :id => 10))
  end

  describe "if no user is provided" do
    before(:each) do
      get unsubscribe_path
    end
    it "should show me the error page" do
      response.should render_template("no_user")
    end
  end

  describe "if a user is provided" do
    before(:each) do
    end

    describe "and the user has no subscriptions" do
      before(:each) do
        puts "AAAA userid = #{@user.id}"
        get "/unsubscribe?user_id=10"
      end

      it "should show me the unsubscribe page with no subs" do
        response.should render_template("show")
        response.should have_content("Unsubscribe")
        response.should have_content("You have no subscriptions")
      end
    end
  end

 end
