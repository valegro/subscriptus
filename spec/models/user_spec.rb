require 'spec_helper'

describe User do
  before(:each) do
    @user = User.new
  end

  it "should generate a correct random number for the recurrent" do
    @user.id = 876579
    @user.generate_recurrent_profile_id.should < 10000000000000000000
  end 
end
