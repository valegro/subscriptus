require 'spec_helper'

describe "Sessions", :type => :integration do
  before(:each) do
    stub_wordpress
    https!
    @offer = Factory.create(:offer, :id => 10)
    @user = Factory.create(:user, :email => 'support@subscriptus.com.au')
  end

  describe "when I visit the login page" do
    before(:each) do
      visit "/login"
    end

    it "should prompt me for my email and password" do
      page.should have_content("Email")
      page.should have_content("Password")
      page.should have_xpath("//input[@name='user_session[login]']")
    end

    describe "when I enter my email and password correctly" do
      before(:each) do
        Wordpress.stubs(:authenticate).returns(true)
        fill_in "Email", :with => "support@subscriptus.com.au"
        fill_in "Password", :with => "password"
      end

      describe "and I am a subscriber" do
        before(:each) do
          @user.role = 'subscriber'
          @user.save
          click_link_or_button "submit"
        end

        it "should take me to the subscriber portal" do
          page.should have_content("My Subscriptions")
          current_url.should == 'http://www.example.com/s/subscriptions'
        end
      end

      describe "and I am an admin" do
        before(:each) do
          @user.role = 'admin'
          @user.save
          click_link_or_button "submit"
        end

        it "should take me to the admin console" do
          current_url.should == 'http://www.example.com/admin/subscriptions'
        end
      end

      describe "and I have next_login_redirect set" do
        before(:each) do
          @user.update_attributes(:next_login_redirect => "/renew?offer_id=10")
        end

        it "should redirect me to what ever it was set to" do
          click_link_or_button "submit"
          current_url.should == 'http://www.example.com/renew?offer_id=10'
        end

        it "should clear the next_login_redirect field" do
          click_link_or_button "submit"
          User.find(@user.id).next_login_redirect.should be(nil)
        end
      end
    end

    describe "when I don't provide the right username or password" do
      before(:each) do
        fill_in "Email", :with => "someone@notexist.com"
        fill_in "Password", :with => "password"
        click_link_or_button "submit"
      end

      it "should keep me on the login page" do
        page.should have_content("Email")
        page.should have_content("Password")
      end

      it "should show me an error" do
        page.should have_content("Login Failed!")
      end
    end

    describe "and I follow the forgot password link" do
      before(:each) do
        click_link_or_button "Forgot password?"
      end

      it "should take me to the forgot password page" do
        page.should have_content("Please enter your e-mail address. You will receive an email with instructions to reset your password.")
      end

      describe "and I enter my email address" do
        before(:each) do
          fill_in "Email", :with => "support@subscriptus.com.au"
        end

        it "should send me an email with a reset link" do
          User.any_instance.expects(:deliver_password_reset_instructions!)
          click_link_or_button "submit"
        end

        it "should tell me it sent the email" do
          click_link_or_button "submit"
          page.should have_content("Instructions to reset your password have been emailed to you. Please check your email.")
        end

        describe "and if I follow that link" do
          before(:each) do
            User.update_all "perishable_token = 'abcdefg'", "id = '#{@user.id}'"
            visit "/password_resets/abcdefg/edit"
          end

          it "should show me a password reset form" do
            page.should have_content("Please enter a new password.")
          end

          describe "and if I enter a new password and confirmation" do
            before(:each) do
              fill_in "Password", :with => "test123"
              fill_in "Confirm", :with => "test123"
            end

            it "should reset my password" do
              User.any_instance.expects(:sync_to_wordpress).with('test123')
              click_link_or_button "Reset"
            end

            it "should take me back to the login page" do
              click_link_or_button "Reset"
              page.should have_content("Email")
              page.should have_content("Password")
              page.should have_xpath("//input[@name='user_session[login]']")
            end
          end
        end
      end
    end
  end
end
