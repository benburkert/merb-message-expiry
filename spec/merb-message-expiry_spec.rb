require File.dirname(__FILE__) + '/spec_helper'

require 'pp'

class TestController < Merb::Controller
  attr_accessor :redirect_to, :expire_at, :expire_in
  def redirect_with_message_and_expire_at_action
    redirect(@redirect_to, :message => "okey dookey", :expire_at => expire_at)
  end

  def redirect_with_message_and_expire_in_action
    redirect(@redirect_to, :message => "okey dookey", :expire_in => expire_in)
  end

  def index; 'index'; end
end

describe "merb-message-expiry" do
  it 'takes :message and :expire_at options' do
    expire_at = (Time.now + 60)
    dispatch_to(TestController, :redirect_with_message_and_expire_at_action) { |controller|
      controller.redirect_to = "http://example.com"
      controller.expire_at = expire_at
    }.should redirect_to("http://example.com", :message => "okey dookey", :expire_at => expire_at)
  end

  it 'takes :message and :expire_in options' do
    dispatch_to(TestController, :redirect_with_message_and_expire_in_action) { |controller|
      controller.redirect_to = "http://example.com"
      controller.expire_in = 30
    }.should redirect_to("http://example.com", :message => "okey dookey", :expire_in => 30)
  end

  describe "with an already expired expiry option" do
    it 'should not have an :_expire query string parameter' do
      dispatch_to(TestController, :redirect_with_message_and_expire_at_action) { |controller|
        controller.redirect_to = "http://example.com"
        controller.expire_at = Time.now - 5
      }.headers['Location'].should_not =~ /_expire=\d+/
    end

    it 'should not have a :_message query string parameter' do
      dispatch_to(TestController, :redirect_with_message_and_expire_at_action) { |controller|
        controller.redirect_to = "http://example.com"
        controller.expire_at = Time.now - 5
      }.headers['Location'].should_not =~ /_message=[a-zA-Z0-9+\/]+/
    end
  end

  describe "with an unexpired expiry option" do
    it 'should have an :_expire query string parameter' do
      expire_at = (Time.now + 60)
      dispatch_to(TestController, :redirect_with_message_and_expire_at_action) { |controller|
        controller.redirect_to = "http://example.com"
        controller.expire_at = expire_at
      }.headers['Location'].should =~ /_expire=\d+/
    end

    it 'should not have a :_message query string parameter' do
      dispatch_to(TestController, :redirect_with_message_and_expire_at_action) { |controller|
        controller.redirect_to = "http://example.com"
        controller.expire_at = Time.now + 500
      }.headers['Location'].should =~ /_message=[a-zA-Z0-9+\/]+/
    end
  end

end