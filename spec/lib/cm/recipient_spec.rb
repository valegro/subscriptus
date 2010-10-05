require 'config/environment' # it's not loaded when you run this file alone.
require 'cm/recipient'

def next_val
  $val_count ||= 0
  $val_count += 1
  return $val_count
end


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

  it "should validate certificate"

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
  describe "adding recpient" do
    before(:each) do
      @driver.stub!(:AddRecipient).and_return(nil)
      @recipient = mock("@recipient", :info => nil)
      CM::Recipient.stub!(:new).and_return(@recipient)
    end
    it "should call add_recipient" do
      CM::ServiceReturn.stub!(:new).and_return('spam')
      CM::Proxy.add_recipient({}).should == 'spam'
    end
    it "should return failure and message if Timeout Error raised" do
      @driver.should_receive(:AddRecipient).and_raise(HTTPClient::ConnectTimeoutError.new("spam"))
      result = ''
      lambda { result = CM::Proxy.add_recipient({}) }.should_not raise_error
      result.success?.should be_false
      result[:message].should == 'spam'
    end
    it "should return failure and message if Socket Error raised" do
      @driver.should_receive(:AddRecipient).and_raise(SocketError.new("spam"))
      result = ''
      lambda { result = CM::Proxy.add_recipient({}) }.should_not raise_error
      result.success?.should be_false
      result[:message].should == 'spam'
    end
    it "should raise if other exceptions raised" do
      @driver.should_receive(:AddRecipient).and_raise(StandardError.new("spam"))
      lambda { CM::Proxy.add_recipient({}) }.should raise_error(StandardError)
    end

    it "should log to rails error log" do
      e = mock("e", :class => 'classname', :message => 'hello!')
      Rails.logger.should_receive(:error).with("classname: hello!")
      CM::Proxy.log_cm_error(e)
    end
  end

  describe "querying" do
    before(:each) do
      @driver.stub!(:AddRecipient).and_return(nil)
      @recipient = mock("@recipient", :info => nil)
      CM::Recipient.stub!(:new).and_return(@recipient)
    end
    it "should call get_recipients" do
      CM::ServiceReturn.stub!(:new).and_return('spam')
      @driver.should_receive(:GetRecipients).and_return(nil)
      CM::ServiceReturn.stub!(:new).and_return('spam')
      CM::Proxy.get_recipients( :ham => :egg ).should == 'spam'
    end
    it "should return failure and message if Timeout Error raised" do
      @driver.should_receive(:GetRecipients).and_raise(HTTPClient::ReceiveTimeoutError.new("spam"))
      result = ''
      lambda { result = CM::Proxy.get_recipients({:ham => :spam}) }.should_not raise_error
      result.success?.should be_false
      result[:message].should == 'spam'
    end
    it "should return failure and message if Socket Error raised" do
      @driver.should_receive(:GetRecipients).and_raise(SocketError.new("spam"))
      result = ''
      lambda { result = CM::Proxy.get_recipients({:ham => :spam}) }.should_not raise_error
      result.success?.should be_false
      result[:message].should == 'spam'
    end
    it "should raise if other exceptions raised" do
      @driver.should_receive(:GetRecipients).and_raise(StandardError.new("spam"))
      lambda { CM::Proxy.get_recipients({:ham => :spam}) }.should raise_error(StandardError)
    end
  end

  describe "in conditions to criteria" do
    it "sholud return blank if blank conditions given" do
      CM::Proxy.conditions_to_criteria( {} ).should be_blank
    end

    it "should return blank if null conditions given" do
      CM::Proxy.conditions_to_criteria( nil ).should be_blank
    end

    it "should make array of CmCriterion" do
      CM::Proxy.conditions_to_criteria( { :email => 'spam' } )[0].should be_kind_of( CmCriterion )
    end

    it "should parse operators" do
      CM::Proxy.conditions_to_criteria( { :'some_value_here>=' => 'some value' } )[0].operator.should == CmBooleanBinaryOperator::GreaterThanEquals
    end

    it "should set equality operator by default" do
      CM::Proxy.conditions_to_criteria( { :'some_value_here' => 'some value' } )[0].operator.should == CmBooleanBinaryOperator::Equals
    end

    it "should camelize field name when specified" do
      CM::Proxy.conditions_to_criteria( { :some_value_here => 'some value'}, true )[0].fieldName.should == 'SomeValueHere'
    end

    it "should not camelize field name when not specified" do
      CM::Proxy.conditions_to_criteria( { :some_value_here => 'some value' } )[0].fieldName.should == 'some_value_here'
    end

    it "should start the 'order' value from the specified value" do
      CM::Proxy.conditions_to_criteria( { :some_value_here => 'some value'}, true, 5 )[0].order.should == 5
    end

    it "should start the 'order' value from 1 by default" do
      CM::Proxy.conditions_to_criteria( { :some_value_here => 'some value' } )[0].order.should == 1
    end

    it "should increase the order for each" do
      conds = CM::Proxy.conditions_to_criteria( { :v1 => 'v1', :v2 => 'v2', :v3 => 'v3' }, true, 10 )
      conds[0].order.should == 10
      conds[1].order.should == 11
      conds[2].order.should == 12
    end
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

  describe "with get recipients" do
    before(:each) do
      @cmrecipient = mock('@cmrecipient', :emailAddress => 'spam@example.com')
      @recipients = mock('@recipient', :cmRecipient => @cmrecipient)
      @getrecsres = mock('@getrecsres', :recipients => @recipients)
      @result = mock("@result", :getRecipientsResult => @getrecsres)
      CM::ServiceReturn.stub!(:hash_from_cm_recipient).with(@cmrecipient).and_return( {:email => 'spam@example.com'} )
      @sr = CM::ServiceReturn.new(@result)
    end

    it "should set values for get return value" do
      (@sr[:recipients][0].instance_variable_get :@cm_recipient).emailAddress.should == 'spam@example.com'
      @sr[:recipients].size.should == 1
    end

    it "should return success for get return value" do
      @sr[:status].should == 'Success'
    end

    it "should return a CM::Recipient" do
      @sr[:recipients].first.should be_kind_of(CM::Recipient)
    end
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
    hash[:email].should == 'spam@spam'
    hash[:created_by].should == 'user'
    hash[:create_date_time].should == 'cdt'
    hash[:created_from_ip_address].should == 'cfia'
    hash[:active].should == false
    hash[:verified].should == false
  end
end

describe CM::Recipient do
  it "should have constant PRIMARY_KEY_NAME" do
    CM::Recipient::PRIMARY_KEY_NAME.should == 'user_id'
  end

  it "should have constant ATTRS" do
    CM::Recipient::ATTRS.should == [ 'email' ]
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
                                   :fields => { :field1 => 'field1val', :user_id => next_val })
    @recipient.instance_variable_get(:@cm_recipient).values.map(&:fieldName).should include 'field1'
    @recipient.instance_variable_get(:@cm_recipient).values.map(&:value).should include 'field1val'
  end

  describe "with simple instance" do
    before(:each) do
      @recipient = CM::Recipient.new(:created_at => Time.now,
                                     :email => 'example@example.com',
                                     :fields => { :'publication{expiry}' => '10/10/2010',
                                                  :'publication{state}' => 'spam', :user_id => next_val  }
                                    )
    end
    it "should add extra fields" do
      @recipient.add_field('spam', 'spam')
      @recipient.add_field('ham', 'ham')
      @recipient.add_field('bacon', 'bacon')
      extra_fields = @recipient.instance_variable_get(:@cm_recipient).values
      extra_fields[3].fieldName.should  == 'spam'
      extra_fields[3].value.should  == 'spam'
      extra_fields[4].fieldName.should  == 'ham'
      extra_fields[4].value.should  == 'ham'
      extra_fields[5].fieldName.should  == 'bacon'
      extra_fields[5].value.should  == 'bacon'
    end

    it "should return info" do
      @recipient.instance_variable_set(:@cm_recipient, "spamSPAMspam")
      @recipient.info.should == 'spamSPAMspam'
    end

    it "should return true validating params if fields are present" do
      @recipient.send(:validate_params, {:created_at => nil, :from_ip => nil, :email => nil, :id => nil, :last_modified_by => nil}).should be_true
    end

    it "should raise when missing fields" do
      lambda { @recipient.send(:validate_params, { :id => nil }) }.should raise_error(CM::MissingAttribute)
    end

    it "should set expiry for a publication" do
      @recipient.set_expiry_for('publication', '10/09/2010')
      @recipient.to_hash[:fields][:'publication{expiry}'].should == '10/09/2010'
    end

    it "should get expiry for a publication" do
      @recipient.expiry_for('publication').should == '10/10/2010'
    end

    it "should set state for a publication" do
      @recipient.set_state_for('publication', 'active')
      @recipient.to_hash[:fields][:'publication{state}'].should == 'active'
    end

    it "should get state for a publication" do
      @recipient.state_for('publication').should == 'spam'
    end

    it "should convert to hash" do
      h = @recipient.to_hash
      h[:fields][:"publication{state}"].should == "spam"
      h[:email].should == "example@example.com"
    end
  end

end

describe CM::Recipient, "integration" do
  before(:each) do
    CM::Proxy.delete_all_recipients
    @user_id = next_val
    CM::Recipient.create!(:created_at => Time.now,
                          :email => 'example@example.com',
                          :email_content_type => 'HTML',
                          :fields => { :user_id => @user_id })
  end

  it "should add recipient" do
    CM::Proxy.get_recipients( :email_address => 'example@example.com' )[:recipients][0].to_hash[:email].should == 'example@example.com'
  end

  it "should update recipient" do
    CM::Recipient.update({:created_at => Time.now,
                          :email => 'updated_email@example.com',
                          :active => true,
                          :fields => { :user_id => @user_id,
                                       :address_1 => 'a1',
                                       :address_2 => 'a2',
                                       :city => 'city',
                                       :country => 'country',
                                       :firstname => 'first',
                                       :lastname => 'last',
                                       :login => 'login',
                                       :phone_number => 'number',
                                       :postcode => 'post',
                                       :state => :TAS,
                                       :title => :Rev
                          }
    })

    rhash = CM::Proxy.get_recipients( :fields => { :user_id => @user_id } )[:recipients][0].to_hash
    rhash[:email].should == 'updated_email@example.com'
    rhash[:fields][:address_1].should == 'a1'
    rhash[:fields][:address_2].should == 'a2'
    rhash[:fields][:city].should == 'city'
    rhash[:fields][:state].should == 'TAS'
    rhash[:fields][:title].should == 'Rev'
    CM::Proxy.get_recipients( nil )[:recipients].size.should == 1
  end

  it "should query recipients" do
    CM::Recipient.create!(:created_at => Time.now,
                          :email => 'ham@example.com',
                          :fields => { :user_id => next_val })
    CM::Recipient.find_all( nil )[:recipients].size.should == 2
    CM::Recipient.find_all( :email_address => 'ham@example.com' )[:recipients].size.should == 1
    # XXX: Is it possible to query by craete_date_time? 
  end
  it "should clear recipients" do
    CM::Proxy.delete_all_recipients
    CM::Recipient.find_all( nil )[:recipients].should be_blank
  end

  it "should save" do
    rec = CM::Proxy.get_recipients(nil)[:recipients].first
    cmr = rec.instance_variable_get(:@cm_recipient)
    cmr.emailContentType = 'Text'
    rec.save
    CM::Proxy.get_recipients(nil)[:recipients].first.to_hash[:email_content_type].should == 'Text'
  end

  it "should reload" do
    rec = CM::Proxy.get_recipients(nil)[:recipients].first
    rec2 = CM::Proxy.get_recipients(nil)[:recipients].first
    cmr = rec.instance_variable_get(:@cm_recipient)
    cmr.emailContentType = 'Text'
    rec.save
    rec2_content = rec2.to_hash[:email_content_type]
    rec2.reload
    rec2_content.should_not == rec2.to_hash[:email_content_type]
  end

end

