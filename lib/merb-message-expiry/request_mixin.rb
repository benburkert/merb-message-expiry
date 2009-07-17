module Merb
  module RequestMessageExpiryMixin
    def expiry
      Time.at(params[:_expire].to_i) if params[:_expire]
    end
  end
end