module Merb
  module ControllerMessageExpiryMixin

    def redirect(url, opts = {})
      default_redirect_options = { :message => nil, :permanent => false, :expire => nil }
      opts = default_redirect_options.merge(opts)
      if opts[:message]
        notice = Merb::Parse.escape([Marshal.dump(opts[:message])].pack("m"))

        expire = if opts[:expire_at]
          opts[:expire_at].to_i
        elsif opts[:expire_in]
          Time.now + opts[:expire_in].to_i
        end

        if expire
          if Time.at(expire) > Time.now
            url = url =~ /\?/ ? "#{url}&_message=#{notice}" : "#{url}?_message=#{notice}"
            url += "&_expire=#{expire.to_i}"
          end
        else
          url = url =~ /\?/ ? "#{url}&_message=#{notice}" : "#{url}?_message=#{notice}"
        end
      end
      self.status = opts[:permanent] ? 301 : 302
      Merb.logger.info("Redirecting to: #{url} (#{self.status})")
      headers['Location'] = url
      "<html><body>You are being <a href=\"#{url}\">redirected</a>.</body></html>"
    end    # Retreives the redirect message either locally or from the request.

    # Retreives the redirect message either locally or from the request.
    # 
    # :api: public
    def message
      @_message = defined?(@_message) ? @_message : request.message unless message_expired?
    end

    def expiry
      @_expiry = defined?(@_expiry) ? @_expiry : request.expiry
    end

    def message_expired?
      expiry && expiry >= Time.now
    end
  end
end