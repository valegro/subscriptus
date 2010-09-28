require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe "class def" do
    # test acts_as_authentic?
    it { should have_many :audit_log_entries }
    it { should have_many :subscriptions }
    it { should respond_to :email_confirmation }
    it { should respond_to :title } # XXX: test enum?
    it { should respond_to :state } # XXX: test enum?
    it { should validate_presence_of :firstname }
    it { should validate_presence_of :lastname }
    it { should validate_presence_of :email }
    it { should validate_presence_of :phone_number }
    it { should validate_presence_of :address_1 }
    it { should validate_presence_of :city }
    it { should validate_presence_of :postcode }
    it { should validate_presence_of :state }
    it { should validate_presence_of :country }
    # test validates_format_of?
  end

  describe "validating" do
    it "should cause error if email confirmation missing"
    it "should cause error if email confirmation not matching"
  end

  it "should return full name" do
    User.new(:firstname => 'spam', :lastname => 'ham').fullname.should == 'spam ham'
  end
end
