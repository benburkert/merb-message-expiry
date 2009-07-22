require File.expand_path(File.join( File.dirname(__FILE__), 'spec_helper' ))
require 'rack/client'

describe Rack::ExpireMessages do
  before(:each) do
    @client = Rack::Client.new do
      use Rack::ExpireMessages
      run lambda {|env| [200, {}, ['Hello, World!']]}
    end
  end

  it 'should do nothing if there is no _message & _expire query string parameters in the request' do
    @client.get('/').body.should == 'Hello, World!'
  end

  it 'should do nothing if the _expire timestamp has not yet expired' do
    @client.get('/', :_message => :foo, :_expire => Time.now.to_i + 100).body.should == 'Hello, World!'
  end

  it 'should redirect to the same url without the _message & _expire query string parameters' do
    response = @client.get('/', :_message => :foo, :_expire => Time.now.to_i - 100)
    response.should be_redirection
    response.location.should == '/'
  end

  it 'should keep non _message & _expire query string parameters' do
    response = @client.get('/', :_message => :foo, :keep => :true, :_expire => Time.now.to_i - 100)
    response.location.should == '/?keep=true'
  end
end