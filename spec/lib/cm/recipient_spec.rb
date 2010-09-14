require 'cm/recipient'
require 'config/environment' # it's not loaded when you run this file alone.

describe CM::Base do
  before(:each) do
    @driver = mock('@driver', :generate_explicit_type= => nil, :options => {})
    @factory = mock("@factory", :create_rpc_driver => @driver)
  end

  it "should have url constant" do
    CM::Base::V1_URI.should ==
      'http://api1.campaignmaster.com.au/v1.1/CampaignMasterService.svc?wsdl'
  end

  it "should return cached static driver" do
    CM::Base.send :class_variable_set, :@@static_driver, "spam"
    CM::Base.driver.should == 'spam'
  end

  it "should return new driver if not set" do
    CM::Base.send :class_variable_set, :@@static_driver, nil
    SOAP::WSDLDriverFactory.should_receive(:new).and_return(@factory)
    CM::Base.driver.should == @driver
  end

  it "should return cached token" do
    CM::Base.should_receive(:need_new_token?).and_return(false)
    CM::Base.send :class_variable_set, :@@token, 'parrot'
    CM::Base.access_token.should == 'parrot'
  end

  it "should return new token when needed" do
    CM::Base.should_receive(:need_new_token?).and_return(true)
    CM::Base.should_receive(:login_with_response).and_return('killer rabbit')
    CM::Base.access_token.should == 'killer rabbit'
  end

  it "should have stub method for validate certificate" do
    CM::Base.send(:validate_certificate, nil, nil).should be_true
  end

  it "should login and set token" do
    CM::Base.should_receive(:driver).and_return(@driver)
    @client_response = mock('@cleint_response', :loginResult => nil )
    @driver.should_receive(:login).and_return( @client_response )
    @login_result = mock('@login_result', :minutesTillTokenExpires => 1000, :tokenString => 'spam')
    @result = mock('@result', :loginResult => @login_result)
    LoginResponse.should_receive(:new).and_return(@result)
    CM::Base.login_with_response.should == 'spam'
  end

  it "should return true if no expiry set" do
    CM::Base.send :class_variable_set, :@@token_expires_at, nil
    CM::Base.send( :need_new_token? ).should be_true
  end

  it "should return true if needing new token" do
    CM::Base.send :class_variable_set, :@@token_expires_at, Time.now - 1.day
    CM::Base.send( :need_new_token? ).should be_true
  end

  it "should return false if not needing new token" do
    CM::Base.send :class_variable_set, :@@token_expires_at, Time.now + 1.day
    CM::Base.send( :need_new_token? ).should be_false
  end
end

describe CM::Proxy do
  before(:each) do
    @driver = mock("@driver")
    CM::Proxy.stub!(:driver).and_return(@driver)
    @token = mock("@token")
    CM::Proxy.stub!(:access_token).and_return(@token)
  end

  # class 
  it "should call add_recipient" do
    @driver.should_receive(:AddRecipient).and_return(nil)
    CM::ServiceReturn.stub!(:new).and_return('spam')
    @recipient = mock("@recipient", :info => nil)
    CM::Recipient.stub!(:new).and_return(@recipient)
    CM::Proxy.add_recipient({}).should == 'spam'
  end

  it "should call get_recipients" do
    CM::ServiceReturn.stub!(:new).and_return('spam')
    @driver.should_receive(:GetRecipients).and_return(nil)
    CM::Proxy.get_recipients( :ham => :egg ).should == 'spam'
  end

  describe "checking hash" do
    before( :each ) do
      @os = OpenStruct.new
      CmCriterion.should_receive(:new).and_return(@os)
      @driver.should_receive(:GetRecipients).and_return(nil)
      CM::Proxy.get_recipients( :'last_modified<=' => '2010-09-09T10:00:00.000' )
    end

    it "should set criteria based on the given hash" do
      @os.leftParentheses.should == 1
      @os.rightParentheses.should == 1
      @os.fieldName.should == 'LastModified'
      @os.operator.should == 'LessThanEquals'
      @os.operand.should == '2010-09-09T10:00:00.000'
    end
  end

  it "should have operators" do
    CM::Proxy::Operators['=='].should == CmBooleanBinaryOperator::Equals
    CM::Proxy::Operators['!='].should == CmBooleanBinaryOperator::NotEqual
    CM::Proxy::Operators['<'].should == CmBooleanBinaryOperator::LessThan
    CM::Proxy::Operators['<='].should == CmBooleanBinaryOperator::LessThanEquals
    CM::Proxy::Operators['>'].should == CmBooleanBinaryOperator::GreaterThan
    CM::Proxy::Operators['>='].should == CmBooleanBinaryOperator::GreaterThanEquals
  end

  it "should delete all recipients" do
    CM::Proxy.delete_all_recipients.should be_true
  end
end

describe CM::ServiceReturn do
  before(:each) do
    @sr = CM::ServiceReturn.new(nil)
  end

  it "should return successful if status != Failure" do
    @sr[:status] = 'spam'
    @sr.success?.should be_true
  end

  it "should return not successful if status == Failure" do
    @sr[:status] = 'Failure'
    @sr.success?.should be_false
  end

  it "should set values for add return value" do
    @addrecres = mock('@addrecres', :callStatus => 'spam', :message => 'vikings')
    @result = mock("@result", :addRecipientResult => @addrecres)
    sr = CM::ServiceReturn.new(@result)
    sr[:status].should == 'spam'
    sr[:message].should == 'vikings'
  end

  # TODO: should test when cmRecipient is an array of recipients inside initalize

  it "should set values for get return value" do
    @recipients = mock('@recipient', :cmRecipient => nil)
    @getrecsres = mock('@getrecsres', :recipients => @recipients)
    @result = mock("@result", :getRecipientsResult => @getrecsres)
    CM::ServiceReturn.should_receive(:hash_from_cm_recipient).with(@recipient).and_return( {:spam => 'spam'} )
    sr = CM::ServiceReturn.new(@result)
    sr[:recipients][0][:spam].should == 'spam'
    sr[:recipients].size.should == 1
  end

  it "should make hash from cm_recipient" do
    elems = [ [mock('ele[0]', :name=> 'Id'), 'ID'] ]
    cmr = mock('@cmRecipient',
               :__xmlele => elems,
               :lastModified => 'lastmod',
               :lastModifiedBy => 'lastmodby',
               :emailContentType => 'SGML',
               :emailAddress => 'spam@spam',
               :createdBy => 'user',
               :createDateTime => 'cdt',
               :createdFromIpAddress => 'cfia',
               :isActive => false,
               :isVerified => false,
               :values => '')
    hash = CM::ServiceReturn.hash_from_cm_recipient(cmr)
    hash[:id].should == 'ID'
    hash[:last_modified].should == 'lastmod'
    hash[:last_modified_by].should == 'lastmodby'
    hash[:email_content_type].should == 'SGML'
    hash[:email_address].should == 'spam@spam'
    hash[:created_by].should == 'user'
    hash[:create_date_time].should == 'cdt'
    hash[:created_from_ip_address].should == 'cfia'
    hash[:is_active].should == false
    hash[:is_verified].should == false
  end
end

describe CM::Recipient do
  it "should have constant PRIMARY_KEY_NAME" do
    CM::Recipient::PRIMARY_KEY_NAME.should == 'EmailAddress'
  end

  it "should have constant ATTRS" do
    CM::Recipient::ATTRS.should == ['created_at', 'email' ]
  end

  it "should call add_recipient for update" do
    CM::Proxy.should_receive(:add_recipient).with(anything, CmOperationType::Update).and_return(mock('result', :success? => true))
    CM::Recipient.update({}).should be_true
  end

  it "should raise if update not success" do
    @result = mock('success', :success? => false)
    CM::Proxy.should_receive(:add_recipient).and_return(@result)
    @result.should_receive(:[]).with(:message).and_return 'spam'
    lambda { CM::Recipient.update({}) }.should raise_error( StandardError, "spam" )
  end

  it "should call add reicipent for create" do
    CM::Proxy.should_receive(:add_recipient).and_return(mock('result', :success? => true))
    CM::Recipient.create!({}).should be_true
  end

  it "should raise if create unsuccessful" do
    @result = mock('success', :success? => false)
    CM::Proxy.should_receive(:add_recipient).and_return(@result)
    @result.should_receive(:[]).with(:message).and_return 'spam'
    lambda { CM::Recipient.update({}) }.should raise_error( StandardError, "spam" )
  end

  it "should call get recipients for get all" do
    CM::Proxy.should_receive(:get_recipients).and_return 'spam'
    CM::Recipient.find_all(nil).should == 'spam'
  end

  describe "initializing" do
    before(:each) do
      @timenow = Time.now
      @init_hash = {:created_at => @timenow,
                    :email => 'example@example.com' }
      @recipient = CM::Recipient.new(@init_hash)
      @cmrec = @recipient.instance_variable_get(:@cm_recipient)
    end
    it "should set created by" do
      @cmrec.createdBy.should be_nil
    end
    it "should set createDateTime" do
      @cmrec.createDateTime.should be_close(@timenow, 2)
    end
    it "should set email centent type" do
      @cmrec.emailContentType.should == EmailContentType::HTML
    end
    it "should set email address" do
      @cmrec.emailAddress.should == 'example@example.com'
    end
    it "should set last_modified" do
      @cmrec.lastModified.should be_close( @timenow, 2 )
    end
    it "should set active when active is set true in hash" do
      @recipient = CM::Recipient.new(@init_hash.merge({ :verified => true }))
      @cmrec = @recipient.instance_variable_get(:@cm_recipient)
      @cmrec.isVerified.should be_true
    end
    it "should set active when active is set false in hash" do
      @recipient = CM::Recipient.new(@init_hash.merge({ :verified => false }))
      @cmrec = @recipient.instance_variable_get(:@cm_recipient)
      @cmrec.isVerified.should be_false
    end
    it "should set verified when verified is set true in hash" do
      @recipient = CM::Recipient.new(@init_hash.merge({ :active => true }))
      @cmrec = @recipient.instance_variable_get(:@cm_recipient)
      @cmrec.isActive.should be_true
    end
    it "should set verified when verified is set false in hash" do
      @recipient = CM::Recipient.new(@init_hash.merge({ :active => false }))
      @cmrec = @recipient.instance_variable_get(:@cm_recipient)
      @cmrec.isActive.should be_false
    end
  end

  it "should initialize with extra fields" do
    @recipient = CM::Recipient.new(:created_at => Time.now,
                                   :email => 'example@example.com',
                                   :fields => { :field1 => 'field1val' })
    @recipient.instance_variable_get(:@cm_recipient).values[0].fieldName.should == 'field1'
    @recipient.instance_variable_get(:@cm_recipient).values[0].value.should == 'field1val'
  end

  it "should add extra fields" do
    @recipient = CM::Recipient.new(:created_at => Time.now,
                                   :email => 'example@example.com')
    @recipient.add_field('spam', 'spam')
    @recipient.add_field('ham', 'ham')
    @recipient.add_field('bacon', 'bacon')
    extra_fields = @recipient.instance_variable_get(:@cm_recipient).values
    extra_fields[0].fieldName.should  == 'spam'
    extra_fields[0].value.should  == 'spam'
    extra_fields[1].fieldName.should  == 'ham'
    extra_fields[1].value.should  == 'ham'
    extra_fields[2].fieldName.should  == 'bacon'
    extra_fields[2].value.should  == 'bacon'
  end
  it "should return info" do
    @recipient = CM::Recipient.new(:created_at => Time.now,
                                   :email => 'example@example.com')
    @recipient.instance_variable_set(:@cm_recipient, "spamSPAMspam")
    @recipient.info.should == 'spamSPAMspam'
  end
  it "should return true validating params if fields are present" do
    @recipient = CM::Recipient.new(:created_at => Time.now,
                                   :email => 'example@example.com')
    @recipient.send(:validate_params, {:created_at => nil, :from_ip => nil, :email => nil, :id => nil, :last_modified_by => nil}).should be_true
  end
  it "should raise when missing fields" do
    @recipient = CM::Recipient.new(:created_at => Time.now,
                                   :email => 'example@example.com')
    lambda { @recipient.send(:validate_params, { :id => nil }) }.should raise_error(CM::MissingAttribute)
  end
end

describe CM::Recipient, "integration" do
  before(:each) do
    CM::Proxy.delete_all_recipients
    CM::Recipient.create!(:created_at => Time.now,
                          :email => 'example@example.com',
                          :fields => { :State => 'trial' })
  end

  it "should add recipient" do
    CM::Proxy.get_recipients( :email_address => 'example@example.com' )[:recipients][0][:email_address].should == 'example@example.com'
  end

  it "should update recipient" do
    CM::Recipient.update({:created_at => Time.now,
                          :email => 'example@example.com',
                          :active => false })

    CM::Proxy.get_recipients( :email_address => 'example@example.com' )[:recipients][0][:active].should be_false
    CM::Proxy.get_recipients( nil )[:recipients].size.should == 1
  end

  it "should query recipients" do
    CM::Recipient.create!(:created_at => Time.now,
                          :email => 'ham@example.com',
                          :fields => { :State => 'stateless' })
    CM::Recipient.find_all( nil )[:recipients].size.should == 2
    CM::Recipient.find_all( :email_address => 'ham@example.com' )[:recipients].size.should == 1
    # XXX: Is it possible to query by craete_date_time? 
  end
  it "should clear recipients" do
    CM::Proxy.delete_all_recipients
    CM::Recipient.find_all( nil )[:recipients].should be_blank
  end
end

