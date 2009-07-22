module Rack
  class ExpireMessages

    MESSAGE_REGEX = /[&]?_message=[a-zA-Z0-9+\/]+/
    EXPIRE_REGEX  = /[&]?_expire=(\d+)/

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['QUERY_STRING'] =~ MESSAGE_REGEX && env['QUERY_STRING'] =~ EXPIRE_REGEX
        if $1.to_i <= Time.now.to_i
          url = env['PATH_INFO'] + env['QUERY_STRING'].gsub(MESSAGE_REGEX, '').gsub(EXPIRE_REGEX, '')
          return [302, {'Location' => url}, ["<html><body>You are being <a href=\"#{url}\">redirected</a>.</body></html>"]]
        end
      end

      @app.call(env)
    end
  end
end