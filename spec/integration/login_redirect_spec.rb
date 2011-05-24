
require 'spec_helper'

describe "Sessions", :type => :integration do
  before(:each) do
    stub_wordpress
    @offer = Factory.create(:offer, :id => 10)
    @user = Factory.create(:user, :email => 'daniel@codefire.com.au')
  end

  describe "when I visit the renewal page with a specific offer" do
    before(:each) do
      visit "/renew?offer_id=10"
    end

    it "should take me to the login page" do
      page.should have_content("Email")
      page.should have_content("Password")
      page.should have_xpath("//input[@name='user_session[login]']")
    end

    describe "and I follow the forgot password link (because I'm a dork and I can't remember my password)" do
      before(:each) do
        click_link_or_button "Forgot password?"
      end

      describe "and I reset my password" do
        before(:each) do
          fill_in "Email", :with => "daniel@codefire.com.au"
          click_link_or_button "submit"
        end

        it "should set my next_login_redirect to the renew page I started with" do
          user = User.find(@user.id)
          user.next_login_redirect.should == "/renew?offer_id=10"
        end
      end
    end
  end
end

