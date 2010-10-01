require 'spec_helper'
describe User do
  before(:each) do
    @user = User.new(:email => 'spam@example.com',
                     :email_confirmation => 'spam@example.com',
                     :address_1 => 'a1',
                     :address_2 => 'a2',
                     :city => 'city',
                     :country => 'country',
                     :firstname => 'first',
                     :lastname => 'last',
                     :login => 'login',
                     :phone_number => 'number',
                     :postcode => 'post',
                     :state => 'SA',
                     :title => 'Rev',
                     :password => 'password',
                     :password_confirmation => 'password'
                    )
    CM::Recipient.stub!(:update)
    CM::Recipient.stub!(:create!)
  end

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
  describe "upon creation" do
    it "should call update_cm with :create" do
      @user.should_receive(:update_cm).with(:create!)
      @user.save!
    end
  end

  describe "upon update" do
    it "should call update_cm with :update" do
      @user.save!
      @user.should_receive(:update_cm).with(:update)
      @user.address_1 = 'new address 1'
      @user.save!
    end
  end

  describe "in update_cm" do
    it "should call update with its attributes" do
      @user.save!
      CM::Recipient.should_receive(:update).with(
            { :created_at => @user.created_at,
              :email => @user.email,
              :fields => { 
                :address_1 => @user.address_1,
                :address_2 => @user.address_2,
                :city => @user.city,
                :country => @user.country,
                :firstname => @user.firstname,
                :lastname => @user.lastname,
                :login => @user.login,
                :phone_number => @user.phone_number,
                :postcode => @user.postcode,
                :state => @user.state,
                :title => @user.title,
                :user_id => @user.id
              }
            }
      )
      @user.save!
    end

    it "should call create with its attributes" do
      CM::Recipient.should_receive(:create!).with(
            {
              :email => 'spam@example.com',
              :created_at => anything,
              :fields => { 
                :address_1 => 'a1',
                :address_2 => 'a2',
                :city => 'city',
                :country => 'country',
                :firstname => 'first',
                :lastname => 'last',
                :login => 'login',
                :phone_number => 'number',
                :postcode => 'post',
                :state => :SA,
                :title => :Rev,
                :user_id => anything
              }
            }
      )
      @user.save!
    end

    it "should log if runtime error raised" do
      CM::Recipient.should_receive(:create!).and_raise( RuntimeError )
      CM::Proxy.should_receive(:log_cm_error)
      @user.save!
    end
  end
end
