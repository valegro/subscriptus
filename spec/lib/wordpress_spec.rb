require 'wordpress'
require 'spec_helper'

describe Wordpress do
  context "When wordpress is disabled" do
    setup do
      Wordpress.enabled = false
    end
    
    context "#exists" do
      it "should return false" do
        Wordpress.exists?(:login => 'joebloggs').should == false
      end
    end
    
    context "#create" do
      it "should not raise an error" do
        lambda {Wordpress.create(:login => 'joebloggs', :pword => 'password', :email => 'joebloggs@example.com')}.should_not raise_error
      end
      
      it "should return the newly created user's login" do
        Wordpress.create(:login => 'joebloggs', :pword => 'password', :email => 'joebloggs@example.com').should == 'joebloggs'
      end
      
    end
    
    context "#update" do
      it "should not raise an error" do
        lambda {Wordpress.update(:login => 'joebloggs')}.should_not raise_error
      end
      
      it "should return the updated user's login" do
        Wordpress.update(:login => 'joebloggs', :firstname => 'Joe').should == 'joebloggs'
      end
    end    
  end

  context "When wordpress is enabled" do
    setup do
      Wordpress.enabled = true
    end
  
    context "#exists" do
      it "should raise an error if login or email are not passed" do
        lambda {Wordpress.exists?}.should raise_error
      end
    
      it "should return true if the user exists by login" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:key => 'testkey', :func =>'exists', :login => 'joebloggs'}).to_return(:body => 'joebloggs')
        Wordpress.exists?(:login => 'joebloggs').should == true
      end
  
      it "should return true if the user exists by email" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:key => 'testkey', :func =>'exists', :email => 'joebloggs@example.com'}).to_return(:body => 'joebloggs')
        Wordpress.exists?(:email => 'joebloggs@example.com').should == true
      end
  
      it "should return false if the user does not exist by login" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:key => 'testkey', :func =>'exists', :login => 'janebloggs'}).to_return(:body => '')
        Wordpress.exists?(:login => 'janebloggs').should == false
      end

      it "should return false if the user does not exist by email" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:key => 'testkey', :func =>'exists', :email => 'janebloggs@example.com'}).to_return(:body => '')
        Wordpress.exists?(:email => 'janebloggs@example.com').should == false
      end
    end
  
    context "#create" do
      it "should raise an error if no options are present" do
        lambda {Wordpress.create}.should raise_error
      end
    
      it "should raise an error if the login is not present" do
        lambda {Wordpress.create(:pword => 'password', :email => 'joebloggs@example.com')}.should raise_error
      end
    
      it "should raise an error if the password is not present" do
        lambda {Wordpress.create(:login => 'joebloggs', :email => 'joebloggs@example.com')}.should raise_error
      end
    
      it "should raise an error if the email is not present" do
        lambda {Wordpress.create(:login => 'joebloggs', :pword => 'password')}.should raise_error
      end
    
      it "should return the newly created user's login" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:key => 'testkey', :func =>'create', :email => 'joebloggs@example.com', :login => 'joebloggs', :pword => 'password'}).to_return(:body => 'joebloggs')
        Wordpress.create(:login => 'joebloggs', :pword => 'password', :email => 'joebloggs@example.com').should == 'joebloggs'
      end
    
      it "should raise an error if the user already exists" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:key => 'testkey', :func =>'create', :email => 'joebloggs@example.com', :login => 'joebloggs', :pword => 'password'}).to_return(:body => 'User already exists')
        lambda {Wordpress.create(:login => 'joebloggs', :pword => 'password', :email => 'joebloggs@example.com')}.should raise_error
      end
    end
  
    context "#update" do
      it "should raise an error if no options are present" do
        lambda {Wordpress.update}.should raise_error
      end
    
      it "should raise an error if the login is not present" do
        lambda {Wordpress.update(:email => 'joebloggs@example.com')}.should raise_error
      end
    
      it "should return the updated user's login" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:login => 'joebloggs', :key => 'testkey', :func =>'update', :firstname => 'Joe'}).to_return(:body => 'joebloggs')
        Wordpress.update(:login => 'joebloggs', :firstname => 'Joe').should == 'joebloggs'
      end
    
      it "should raise an error if the user does not exist" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:login => 'janebloggs', :key => 'testkey', :func =>'update', :firstname => 'Jane'}).to_return(:body => 'User does not exists!')
        lambda {Wordpress.update(:login => 'janebloggs', :firstname => 'Jane')}.should raise_error
      end
    end
  
    context "#authenticate" do
      it "should raise an error if no options are present" do
        lambda {Wordpress.authenticate}.should raise_error
      end
    
      it "should raise an error if the password is not present" do
        lambda {Wordpress.authenticate(:login => 'joebloggs')}.should raise_error
        lambda {Wordpress.authenticate(:email => 'joebloggs@example.com')}.should raise_error
      end
    
      it "should raise an error if login or email are not passed" do
        lambda {Wordpress.authenticate(:pword => 'password')}.should raise_error
      end
      
      it "should return true if the authentication details are correct" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:login => 'joebloggs', :key => 'testkey', :func =>'authenticate', :pword => 'password'}).to_return(:body => 'true')
        Wordpress.authenticate(:login => 'joebloggs', :pword => 'password').should == true
      end
      
      it "should not return true if the authentication details are incorrect" do
        stub_request(:get, Wordpress.config[:endpoint]).with(:query => {:login => 'joebloggs', :key => 'testkey', :func =>'authenticate', :pword => 'password'}).to_return(:body => '-1')
        Wordpress.authenticate(:login => 'joebloggs', :pword => 'password').should == false
      end
    end
  end
end
