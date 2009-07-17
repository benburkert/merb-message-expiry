# make sure we're running inside Merb
if defined?(Merb::Plugins)

  require 'merb-message-expiry/controller_mixin'
  require 'merb-message-expiry/request_mixin'
  require 'merb-message-expiry/rack'

  class Merb::Controller
    include Merb::ControllerMessageExpiryMixin
  end

  class Merb::Request
    include Merb::RequestMessageExpiryMixin
  end

  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:merb_message_expiry] = {
    :chickens => false
  }
  
  Merb::BootLoader.before_app_loads do
    # require code that must be loaded before the application
  end
  
  Merb::BootLoader.after_app_loads do
    # code that can be required after the application loads
  end
  
  Merb::Plugins.add_rakefiles "merb-message-expiry/merbtasks"
end