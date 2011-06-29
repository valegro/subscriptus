require 'spec_helper'

describe UserMailer do
  before(:each) do
    stub_wordpress
  end

  describe "password reset" do
    before(:each) do
      @user = Factory.create(:subscriber)
      User.any_instance.stubs(:perishable_token).returns("abcdefg")
      @response = UserMailer.deliver_password_reset_instructions(@user)
    end

    it "should include the reset link" do
      @response.body.should include_text("https://example.com/password_resets/abcdefg/edit")
    end

    it "should have the right contact details" do
      @response.body.should include_text("contact us on 1800 985 502 or at subs@crikey.com.au")
    end
  end
end
