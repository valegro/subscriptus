require 'spec_helper'

describe StateCallbacks::CallbackHandler do
  before(:each) do
    @callbacks = StateCallbacks::CallbackHandler.new
  end

  it "should add a callback" do
    expect {
      @callbacks.add('foo', 'bar') do
        # Do stuff
      end
    }.to change { @callbacks.size }.by(1)
  end

  it "should retrieve a callback" do
    @array = []
    @array.expects(:test_method)
    @callbacks.add('foo', 'bar') do
      @array.test_method
    end
    @callbacks.get('foo', 'bar').call
  end
end
