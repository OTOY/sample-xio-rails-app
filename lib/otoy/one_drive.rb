require "skydrive"

class Otoy
  class OneDrive

    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @skydrive = ::Otoy::OneDrive::OauthClient.new(@consumer_key, @consumer_secret,
                          nil,
                          "wl.contacts_skydrive,wl.skydrive_update,wl.offline_access,wl.emails")
    end

    def __muted_send__(method, *args, &block)
      @skydrive.send(method, *args, &block)
    rescue StandardError, Timeout::Error => e
      nil
    end

    def method_missing(method, *args, &block)
      method = method.to_s

      if method =~ /^muted_(.+)$/
        __muted_send__($1, *args, &block)
      else
        @skydrive.send(method, *args, &block)
      end
    end
  end
end

# Hack to work around SkyDrive gem
class Otoy
  class OneDrive
    class OauthClient < ::Skydrive::Oauth::Client

      def authorize_url(callback)
        oauth_client.auth_code.authorize_url(:redirect_uri => callback)
      end

      def get_access_token(code, callback)
        @access_token = oauth_client.auth_code.get_token(code, :redirect_uri => callback)
      end

    end
  end
end
