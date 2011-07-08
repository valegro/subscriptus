require 'spec_helper'

describe User do
  before(:each) do
    # User.any_instance.stubs(:delay).returns(stub('delay'))
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

  describe "trial user" do
    it "should create" do
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
  end

  describe "find_or_create_with_trial" do
    describe "an existing user" do
      before(:each) do
        @user = Factory.create(:subscriber, :email => 'guy@example.com')
        @publication = Factory.create(:publication)
      end

      it "should add a publication to that user" do
        expect {
          User.find_or_create_with_trial(@publication, 10, 'referrer', { :first_name => 'Daniel', :last_name => 'Draper', :email => 'guy@example.com' })
        }.to change { @user.subscriptions(true).size }.by(1)
      end

      it "should reset the user's password" do
        User.stubs(:random_password).returns('password')
        Subscription.any_instance.expects(:temp_password=).with('password')
        User.find_or_create_with_trial(@publication, 10, 'referrer', { :first_name => 'Daniel', :last_name => 'Draper', :email => 'guy@example.com' })
      end
    end
  end

  describe "add_or_reset_trial" do
    before(:each) do
      @user = Factory.create(:user)
      @publication = Factory.create(:publication)
    end

    describe "a user that has no sub to given publication" do
      it "should create a trial and return the sub" do
        expect {
          @user.add_or_reset_trial(@publication, 10, 'refer', true)
        }.to change { @user.subscriptions(true).count }.by(1)
      end
    end

    describe "a user that has a trial sub to given publication" do
      before(:each) do
        @subscription = Factory.create(:subscription, :state => 'trial', :user => @user, :publication => @publication)
      end

      it "should raise an error" do
        lambda {
          @user.add_or_reset_trial(@publication, 10, 'refer', true)
        }.should raise_exception(Exceptions::AlreadyHadTrial)
      end
    end

    describe "a user that has a squatter sub to given publication that is less than 12 months in that state" do
      before(:each) do
        @subscription = Factory.create(:subscription, :state => 'squatter', :user => @user, :publication => @publication)
      end

      it "should raise an error" do
        lambda {
          @user.add_or_reset_trial(@publication, 10, 'refer', true)
        }.should raise_exception(Exceptions::AlreadyHadTrial)
      end
    end

    describe "a user that has a squatter sub to given publication that is MORE than 12 months in that state" do
      before(:each) do
        @subscription = Factory.create(:subscription, :state => 'squatter', :user => @user, :publication => @publication)
      end

      it "should create a trial and return the sub" do
        Timecop.travel(13.months.from_now) do
          expect {
            @user.add_or_reset_trial(@publication, 10, 'refer', true)
          }.to change { @user.subscriptions(true).count }.by(0)
          Subscription.find(@subscription.id).trial?.should be(true)
        end
      end
    end
  end

  describe "webhook" do
    before(:each) do
      @publication = Factory.create(:publication)
      @weekender = Factory.create(:publication, :name => "Crikey Weekender")
    end

    it "should create a trial user and subscription" do
      expect {
        @sub = User.find_or_create_with_trial(@publication, 10, "Refer", {
          :first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel2@netfox.com'
        })
        @sub.state.should == 'trial'
        @sub.user.subscriptions.count.should == 1
      }.to change { User.count }.by(1)
    end

    it "should create a trial user and subscription + weekender if requested" do
      expect {
        @sub = User.find_or_create_with_trial(@publication, 10, "Refer", {
          :first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel2@netfox.com', :options => { :weekender => true }
        })
        @sub.state.should == 'trial'
        @sub.user.subscriptions(true).count.should == 2
        @sub.user.has_weekender?.should be(true)
      }.to change { User.count }.by(1)
    end

    it "should create a trial and set solus if requested" do
      expect {
        @sub = User.find_or_create_with_trial(@publication, 10, "Refer", {
          :first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel2@netfox.com', :options => { :solus => true }
        })
        @sub.state.should == 'trial'
        @sub.solus.should be(true)
        @sub.user.subscriptions.count.should == 1
      }.to change { User.count }.by(1)

    end
  end
    
  it "should only allow one subscription per publication" do
    publication = Factory.build(:publication)
    @user.save!
    @user.subscriptions.create!(:publication => publication)
    lambda {
      @user.subscriptions.create!(:publication => publication)
    }.should raise_exception(Exceptions::DuplicateSubscription)
  end

  it "should show active subscriptions" do
    publication = Factory.build(:publication)
    @user.save!
    @user.subscriptions.count.should == 0
    @user.subscriptions.create(:publication => publication)
    @user.subscriptions.count.should == 1
    @user.has_active_subscriptions?.should_not == true
    lambda {
      @user.subscriptions.create(:publication => publication, :state => 'active')
    }.should raise_exception(Exceptions::DuplicateSubscription)
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
      user = Factory.build(:user, :login => nil)
      user.save!
      user.login.should_not be(nil)
      user.login.should == @stubbed_login
    end

    it "login should not be over written if user is an admin" do
      user = Factory.create(:admin, :login => "mesocool")
      user.login.should == 'mesocool'
    end

    it "should call update_cm with :create" do
      @user.stubs(:delay).returns(mock('delay'))
      @user.delay.stubs(:sync_to_wordpress).with('password')
      @user.delay.expects(:sync_to_campaign_master)
      @user.save!
    end

    it "should NOT call update_cm if admin" do
      @user = Factory.build(:admin, :login => 'daniel')
      @user.stubs(:delay).returns(mock('delay'))
      @user.delay.expects(:sync_to_campaign_master).never
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

    it "should allow blank :phone_number, :address_1, :city, :postcode, :state, :country, :role if validates_as :system" do
      lambda {
        User.validate_as(:system) do
          User.create!(:firstname => 'Dan', :lastname => 'Draper', :email => 'daniel@netfox.com', :auto_created => true, :password => 'test', :password_confirmation => 'test')
        end
      }.should_not raise_error
    end

    describe "wordpress" do
      it "should create a user in Wordpress" do
        @stubbed_login = '12345'
        UserObserver.any_instance.stubs(:generate_unique_id).returns(@stubbed_login)
        delay = mock('delay')
        delay.expects(:sync_to_wordpress).with('password')
        delay.expects(:sync_to_campaign_master)
        User.any_instance.stubs(:delay).returns(delay)
        Factory.create(:user, :firstname => 'Daniel', :lastname => 'Draper', :email => 'daniel@netfox.com', :password => 'password',:password_confirmation => 'password')
      end

      it "should NOT create a user in Wordpress if admin" do
        Wordpress.stubs(:delay).returns(mock('delay'))
        Wordpress.delay.expects(:create).never
        @user = Factory.create(:admin, :login => "daniel")
      end

      describe "if the email exists in WP" do
        before(:each) do
          Wordpress.stubs(:exists?).with(:email => 'daniel@netfox.com').returns(true)
        end

        it "should not be valid if the login exists in Wordpress" do
          user = Factory.build(:user, :email => 'daniel@netfox.com')
          user.valid?.should == false
        end
        
        it "should not create a trial user" do
          lambda {
            User.create_trial_user(:first_name => 'Daniel', :last_name => 'Draper', :email => 'daniel@netfox.com')
          }.should raise_exception(ActiveRecord::RecordInvalid)
        end

        it "should not create a user" do
          lambda {
            Factory.create(:user, :email => 'daniel@netfox.com')
          }.should raise_exception(ActiveRecord::RecordInvalid)
        end

        it "should create a user if we set the overide_wordpress flag to true" do
          lambda {
            Factory.create(:user, :email => 'daniel@netfox.com', :overide_wordpress => true)
          }.should_not raise_exception
        end
      end

      describe "if the login already exists in WP" do
        it "should be valid even though the login exists in Wordpress if we are an admin" do
          Wordpress.stubs(:exists?).returns(true)
          user = Factory.build(:admin, :login => 'daniel')
          user.valid?.should == true
        end

        it "should not create a user if the login exists in Wordpress" do
          Wordpress.stubs(:exists?).with(:login => @stubbed_login).returns(true)
          UserObserver.any_instance.stubs(:generate_unique_id).returns(@stubbed_login)
          lambda {
            Factory.create(:user)
          }.should raise_exception(ActiveRecord::RecordInvalid)
        end
      end

      it "should not create a user if no login is provided and the generated login already exists in Wordpress" do
        UserObserver.any_instance.stubs(:generate_unique_id).returns(@stubbed_login)
        Wordpress.stubs(:exists?).with(:login => @stubbed_login).returns(true)
        lambda {
          Factory.create(:user, :login => nil)
        }.should raise_exception(ActiveRecord::RecordInvalid)
      end
    end

    describe "premium" do
      before(:each) do
        @user = Factory.create(:user)
      end

      it "should be false if no active subscriptions" do
        @user.premium?.should be(false)
      end

      it "should be true if the user has at least one active subscription" do
        @user.subscriptions << Factory.create(:subscription, :state => 'active')
        @user.premium?.should be(true)
      end

      it "should be false if the only active sub is to Crikey Weekender" do
        @weekender = Factory.create(:publication, :name => "Crikey Weekender")
        @user.subscriptions << Factory.create(:subscription, :state => 'active', :publication => @weekender)
        @user.premium?.should be(false)
      end
    end

    describe "weekender" do
      before(:each) do
        @weekender = Factory.create(:publication, :name => "Crikey Weekender")
        @user.save!
      end

      it "should be added if not already present" do
        expect {
          @user.add_weekender_to_subs
        }.to change { @user.subscriptions.size }.by(1)
        @user.has_weekender?.should be(true)
      end

      it "should NOT be added if present" do
        @user.add_weekender_to_subs
        @user.has_weekender?.should be(true)
        expect {
          @user.add_weekender_to_subs
        }.to_not change { @user.subscriptions.size }
        @user.has_weekender?.should be(true)
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
      Wordpress.stubs(:delay).returns(mock('delay'))
    end

    it "should call sync_to_campaign_master" do
      User.any_instance.stubs(:delay).returns(mock('delay'))
      @user.delay.expects(:sync_to_campaign_master)
      @user.delay.expects(:sync_to_wordpress).with('password')
      @user.firstname = "Changed"
      @user.save!
    end

    it "should NOT call sync_to_campaign_master if only last_request_at was changed" do
      user2 = Factory.create(:user)
      user2 = User.find(user2.id)
      user2.stubs(:delay).returns(mock('delay'))
      user2.delay.expects(:sync_to_campaign_master).never
      user2.last_request_at = Time.now
      user2.save!
    end

    it "should NOT call sync_to_campaign_master if admin" do
      @user = Factory.create(:admin, :login => 'daniel')
      @user.stubs(:delay).returns(mock('delay'))
      @user.delay.expects(:sync_to_campaign_master).never
      @user.save!
    end

    describe "Wordpress" do
      it "should update Wordpress if role is subscriber and email or name changes" do
        User.any_instance.stubs(:delay).returns(mock('delay'))
        @user.email = 'another@example.com'
        @user.email_confirmation = 'another@example.com'
        @user.delay.expects(:sync_to_campaign_master)
        @user.delay.expects(:sync_to_wordpress).with('password')
        @user.save!
      end

      it "should NOT update Wordpress if role is subscriber and anything but email or name changes" do
        @user.last_request_at = Time.now
        Wordpress.delay.expects(:update).with(
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
        Wordpress.delay.expects(:create).never
        @user.save!
      end

      it "should not update the user if we change our email but that email has been taken" do
        @user.email = 'foo@bar.com'
        Wordpress.stubs(:exists?).with(:email => 'foo@bar.com').returns(true)
        Wordpress.delay.expects(:update).with(
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

  describe "upon call to sync_to_wordpress" do
    describe "and password is accessible (ie; new user)" do
      describe "for a user who doesn't exist in WP" do
        it "should call Wordpress with create" do
          @user.save!
          Wordpress.expects(:create).with({
            :login       => @user.login,
            :firstname   => @user.firstname,
            :lastname    => @user.lastname,
            :email       => @user.email,
            :pword       => @user.password,
            :premium     => false
          })
          @user.sync_to_wordpress(@user.password)
        end
      end

      describe "for a user who does exist in WP" do
        it "should call Wordpress with update" do
          @user.save!
          Wordpress.stubs(:exists?).with(:login => @user.login).returns(true)
          Wordpress.expects(:update).with({
            :login       => @user.login,
            :firstname   => @user.firstname,
            :lastname    => @user.lastname,
            :email       => @user.email,
            :premium     => false
          })
          @user.sync_to_wordpress
        end
      end
    end

    describe "and password is NOT accessible" do
      describe "for a user who doesn't exist in WP" do
        it "should call Wordpress with create and a random password" do
          @user.save!
          User.stubs(:random_password).returns('12345')
          @user = User.find(@user.id)
          Wordpress.expects(:create).with({
            :login       => @user.login,
            :firstname   => @user.firstname,
            :lastname    => @user.lastname,
            :email       => @user.email,
            :premium     => false,
            :pword       => '12345'
          })
          @user.sync_to_wordpress
        end
      end
    end

    it "should set premium true if the user is premium" do
      @user.stubs(:premium?).returns(true)
      @user.save!
      Wordpress.expects(:create).with(has_entry(:premium, true))
      @user.sync_to_wordpress(@user.password)
    end

    describe "if a user exists in WP with my email but the logins are different" do
      before(:each) do
        @user.save!
        Wordpress.stubs(:exists?).with(:email => @user.email).returns(true)
        Wordpress.stubs(:exists?).with(:login => @user.login).returns(false)
        Wordpress.stubs(:exists?).with(:login => 'new_login').returns(true)
      end

      it "should change the subscriptus user's login to match WP then sync" do
        lambda {
          @user.sync_to_wordpress
        }.should raise_exception(Wordpress::PrimaryKeyMismatch)
      end
    end
  end

  describe "deliver password reset instructions" do
    it "should send me a password reset email" do
      @user = Factory.create(:subscriber)
      UserMailer.expects(:deliver_password_reset_instructions).with(@user)
      @user.deliver_password_reset_instructions!
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
      GATEWAY.expects(:setup_recurrent).with(1, @card, @token).returns(success)
      user = Factory.create(:user)
      user.store_credit_card_on_gateway(@card)
    end

    it "should still make a call to setup_recurring if there is already a token stored" do
      GATEWAY.expects(:setup_recurrent).returns(stub(:success? => true))
      user = Factory.create(:user_with_token)
      user.store_credit_card_on_gateway(@card)
    end

    it "should handle errors" do
      failure = stub(:success? => false, :message => "Test Failure")
      GATEWAY.expects(:setup_recurrent).with(1, @card, "12345").returns(failure)
      user = Factory.create(:user)
      lambda {
        user.store_credit_card_on_gateway(@card)
      }.should raise_exception(Exceptions::CannotStoreCard)
      user.payment_gateway_token.should be(nil)
    end

    it "should raise an exception if I provide a dodgy card" do
      @card.number = 'kjwefgwekjqfhw'
      GATEWAY.expects(:setup_recurrent).never
      user = Factory.create(:user)
      lambda {
        user.store_credit_card_on_gateway(@card)
      }.should raise_exception(Exceptions::CannotStoreCard)
    end
  end
end
