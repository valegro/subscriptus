require File.dirname(__FILE__) + '/../../../spec_helper'

describe Admin::System::UsersController, "as admin" do
  before(:each) do
    stub_wordpress
    admin_login
    https!
  end
  
  describe "on create" do
    describe "if post with valid data" do
      before(:each) do
        @attrs = Factory.attributes_for(:admin_attributes)
      end

      it "should create a subscriber" do
        expect {
          post(:create, :user => @attrs)
        }.to change { User.admins.count }.by(1)
      end
    end
  end
end