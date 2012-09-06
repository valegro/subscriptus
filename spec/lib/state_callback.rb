require 'spec_helper'

describe StateCallbacks::CallbackHandler do
  before(:each) do
    @callbacks = StateCallbacks::CallbackHandler.new
  end

  it "should add a callback" do
    @callbacks.add('foo', 'bar') do
      # Do stuff
    end
    @callbacks.after.size.should == 1
  end

  it "should retrieve a callback" do
    @array = []
    @array.expects(:test_method)
    @callbacks.add('foo', 'bar') do
      @array.test_method
    end
    @callbacks.get('foo', 'bar').call
  end

  it "should add a callback to run before" do
    @callbacks.add('foo', 'bar', :before) do
      # Do stuff
    end
    @callbacks.before.size.should == 1
  end

  it "should retrieve a callback to run before" do
    @array = []
    @array.expects(:test_method)
    @callbacks.add('foo', 'bar', :before) do
      @array.test_method
    end
    @callbacks.get('foo', 'bar', :before).call
  end

end
