require 'spec_helper'

describe User do
  before(:each) do
    stub_wordpress
    @user = Factory.build(:subscriber)
    @user.stubs(
                     :address_1 => 'a1',
                     :address_2 => 'a2',
                     :city => 'city',
                     :country => 'country',
                     :firstname => 'first',
                     :lastname => 'last',
                     :phone_number => 'number',
                     :postcode => 'post',
                     :state => 'SA',
                     :title => 'Rev',
                     :password => 'password',
                     :password_confirmation => 'password'
               )
    cm_return = stub(:success? => true)
  end

  it "should create a trial user" do
    expect {
      user = User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel@netfox.com')
      user.auto_created.should == true
      user.password.length.should == 8
    }.to change { User.count }.by(1)

    # Attempt a duplicate email
    lambda {
      User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel@netfox.com')
    }.should raise_exception

    # And another with a different email
    expect {
      user2 = User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel2@netfox.com')
    }.to change { User.count }.by(1)
  end
    
  it "should only allow one trial per publication" do
    publication = Factory.build(:publication)
    @user.save!
    @user.subscriptions.count.should == 0
    @user.subscriptions.create(:publication => publication)
    @user.subscriptions.count.should == 1
    lambda {
      @user.subscriptions.create(:publication => publication)
    }.should raise_exception
    # Change the first subscription to active
    @user.subscriptions.first.activate!
    @user.subscriptions.first.state.should == 'active'
    lambda {
      @user.subscriptions.create(:publication => publication)
    }.should_not raise_exception
    @user.subscriptions.count.should == 2
    @user.subscriptions.trial.count.should == 1
  end

  it "should show active subscriptions" do
    publication = Factory.build(:publication)
    @user.save!
    @user.subscriptions.count.should == 0
    @user.subscriptions.create(:publication => publication)
    @user.subscriptions.count.should == 1
    @user.has_active_subscriptions?.should_not == true
    # Add an active
    @user.subscriptions.create(:publication => publication, :state => 'active')
    @user.subscriptions.count.should == 2
    @user.has_active_subscriptions?.should == true
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

  it "should return full name" do
    User.new(:firstname => 'spam', :lastname => 'ham').fullname.should == 'spam ham'
  end

  describe "upon creation" do
    before(:each) do
      @stubbed_login = "abc123"
    end

    it "should generate a random username if user is a subscriber" do
      UserObserver.any_instance.stubs(:generate_unique_id).returns(@stubbed_login)
      user = Factory.build(:user, :login => "shit that will be overwitten")
      user.save!
      user.login.should_not be(nil)
      user.login.should == @stubbed_login
    end

    it "login should not be over written if user is an admin"

    it "should call update_cm with :create" do
      @user.expects(:send_later).with(:sync_to_campaign_master)
      @user.save!
    end

    it "should NOT call update_cm if admin" do
      @user = Factory.build(:admin, :login => 'daniel')
      @user.expects(:send_later).with(:sync_to_campaign_master).never
      @user.save!
    end

    it "should cause error if email confirmation missing" do
      user = Factory.build(:user, :email => 'daniel@netfox.com', :email_confirmation => "")
      lambda {
        user.save!
      }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should cause error if email confirmation not matching" do
      user = Factory.build(:user, :email => 'daniel@netfox.com', :email_confirmation => "foo@bar.com")
      lambda {
        user.save!
      }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should allow blank :phone_number, :address_1, :city, :postcode, :state, :country, :role if auto_created is true" do
      lambda {
        User.create!(:firstname => 'Dan', :lastname => 'Draper', :email => 'daniel@netfox.com', :auto_created => true, :password => 'test', :password_confirmation => 'test')
      }.should_not raise_error
    end

    describe "wordpress" do
      it "should create a user in Wordpress" do
        @stubbed_login = '12345'
        UserObserver.any_instance.stubs(:generate_unique_id).returns(@stubbed_login)
        Wordpress.expects(:send_later).with(:create, { :login => '12345', :pword => 'password', :email => 'daniel@netfox.com',:firstname => 'Daniel', :lastname => 'Draper' })
        Factory.create(:user, :firstname => 'Daniel', :lastname => 'Draper', :email => 'daniel@netfox.com', :password => 'password',:password_confirmation => 'password')
      end

      it "should NOT create a user in Wordpress if admin" do
        Wordpress.expects(:send_later).never
        @user = Factory.create(:admin, :login => "daniel")
      end

      it "should not be valid if the login exists in Wordpress" do
        Wordpress.stubs(:exists?).returns(true)
        user = Factory.build(:user)
        user.valid?.should == false
      end
      
      it "should be valid even though the login exists in Wordpress if we are an admin" do
        Wordpress.stubs(:exists?).returns(true)
        user = Factory.build(:admin, :login => 'daniel')
        user.valid?.should == true
      end

      it "should not create a trial user if the email exists in Wordpress" do
        Wordpress.stubs(:exists?).with(:email => 'daniel@netfox.com').returns(true)
        lambda {
          User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel@netfox.com')
        }.should raise_exception(ActiveRecord::RecordInvalid)
      end

      it "should not create a user if the email exists in Wordpress" do
        Wordpress.stubs(:exists?).with(:email => 'daniel@netfox.com').returns(true)
        lambda {
          Factory.create(:user, :email => 'daniel@netfox.com')
        }.should raise_exception(ActiveRecord::RecordInvalid)
      end

      it "should not create a user if the login exists in Wordpress" do
        Wordpress.stubs(:exists?).with(:login => @stubbed_login).returns(true)
        UserObserver.any_instance.stubs(:generate_unique_id).returns(@stubbed_login)
        lambda {
          Factory.create(:user)
        }.should raise_exception(ActiveRecord::RecordInvalid)
      end

      it "should not create a user if no login is provided and the generated login already exists in Wordpress" do
        UserObserver.any_instance.stubs(:generate_unique_id).returns(@stubbed_login)
        Wordpress.stubs(:exists?).with(:login => @stubbed_login).returns(true)
        lambda {
          Factory.create(:user, :login => nil)
        }.should raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    describe "gender" do
      it "should be set" do
        @user = Factory.create(:user)
        @user.gender.should_not be(nil)
      end

      it "should be set to male if title is Mr" do
        @user = Factory.create(:user, :title => 'Mr')
        @user.gender.should == :male
      end

      it "should be set to male if title is Sir" do
        @user = Factory.create(:user, :title => 'Sir')
        @user.gender.should == :male
      end

      it "should be set to male if title is Fr" do
        @user = Factory.create(:user, :title => 'Fr')
        @user.gender.should == :male
      end

      it "should be set to female if title is Mrs" do
        @user = Factory.create(:user, :title => 'Mrs')
        @user.gender.should == :female
      end

      it "should be set to female if title is Ms" do
        @user = Factory.create(:user, :title => 'Ms')
        @user.gender.should == :female
      end

      it "should be set to female if title is Miss" do
        @user = Factory.create(:user, :title => 'Miss')
        @user.gender.should == :female
      end

      it "should be set to female if title is Lady" do
        @user = Factory.create(:user, :title => 'Lady')
        @user.gender.should == :female
      end
    end
  end

  describe "upon update" do
    before(:each) do
      @user.save!
    end

    it "should call sync_to_campaign_master" do
      @user.expects(:send_later).with(:sync_to_campaign_master)
      @user.save!
    end

    it "should NOT call sync_to_campaign_master if admin" do
      @user = Factory.create(:admin, :login => 'daniel')
      @user.expects(:send_later).with(:sync_to_campaign_master).never
      @user.save!
    end

    it "should NOT call sync_to_campaign_master if anything but name or email is changed"

    it "should not allow us to change our login" do
      @user.login = 'anotherlogin'
      lambda {
        @user.save!
      }.should raise_exception(ActiveRecord::RecordInvalid)
    end

    describe "Wordpress" do
      it "should update Wordpress if role is subscriber and email or name changes" do
        @user.email = 'another@example.com'
        @user.email_confirmation = 'another@example.com'
        Wordpress.expects(:send_later).with(
          :update,
          :email => @user.email,
          :login => @user.login,
          :firstname => @user.firstname,
          :lastname => @user.lastname
        )
        @user.save!
      end

      it "should NOT update Wordpress if role is subscriber and anything but email or name changes" do
        @user.last_request_at = Time.now
        Wordpress.expects(:send_later).with(
          :update,
          :email => @user.email,
          :login => @user.login,
          :firstname => @user.firstname,
          :lastname => @user.lastname
        ).never
        @user.save!
      end

      it "should NOT update Wordpress if user is an admin" do
        @user = Factory.create(:admin, :login => 'daniel')
        Wordpress.expects(:send_later).never
        @user.save!
      end

      it "should not update the user if we change our email but that email has been taken" do
        @user.email = 'foo@bar.com'
        Wordpress.stubs(:exists?).with(:email => 'foo@bar.com').returns(true)
        Wordpress.expects(:send_later).with(
          :update,
          :email => @user.email,
          :login => @user.login,
          :firstname => @user.firstname,
          :lastname => @user.lastname
        ).never
        lambda {
          @user.save!
        }.should raise_exception(ActiveRecord::RecordInvalid)
      end

      it "should still update the user if we change our email but that email has been taken if we are an admin" do
        Wordpress.stubs(:exists?).with(:email => 'foo@bar.com').returns(true)
        lambda {
          @user.save!
        }.should_not raise_exception(ActiveRecord::RecordInvalid)
      end

      it "should authenticate to wordpress if role is subscriber"
    end
  end

  describe "upon call to sync_to_campaign_master" do
    it "should call sync on all subscriptions" do
      @user.save!
      @subscription = Factory.build(:subscription)
      @user.subscriptions << @subscription
      @subscription.expects(:sync_to_campaign_master)
      @user.sync_to_campaign_master
    end
  end

  describe "storing a credit on the gateway" do
    before(:each) do
      @payment = Factory.build(:payment)
      @card = @payment.credit_card
      @token = "12345"
      Utilities.stubs(:generate_unique_token).returns(@token)
    end

    it "should save a token to the user object" do
      success = stub(:success? => true)
      GATEWAY.expects(:setup_recurrent).with(0, @card, @token).returns(success)
      user = Factory.create(:user)
      user.store_credit_card_on_gateway(@card)
    end

    it "should not make a call to setup_recurring if there is already a token stored" do
      GATEWAY.expects(:setup_recurrent).never
      user = Factory.create(:user_with_token)
      user.store_credit_card_on_gateway(@card)
    end

    it "should handle errors" do
      failure = stub(:success? => false, :message => "Test Failure")
      GATEWAY.expects(:setup_recurrent).with(0, @card, "12345").returns(failure)
      user = Factory.create(:user)
      lambda {
        user.store_credit_card_on_gateway(@card)
      }.should raise_exception(Exceptions::CannotStoreCard)
      user.payment_gateway_token.should be(nil)
    end
  end
end
