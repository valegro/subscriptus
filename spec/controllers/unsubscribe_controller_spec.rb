require 'spec_helper'

describe UnsubscribeController do

  integrate_views

  before(:each) do
    stub_wordpress
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
    describe "and the user has no subscriptions" do
      before(:each) do
        @user = User.create!(Factory.attributes_for(:subscriber))
        puts "AAAA userid = #{@user.id}"
        puts User.all.inspect
        get :show, :user_id => @user.id
      end

      it "should show me the unsubscribe page with no subs" do
        response.should render_template("show")
      end
    end
  end

end
