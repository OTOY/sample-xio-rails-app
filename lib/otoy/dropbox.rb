require 'dropbox_sdk'

class Otoy
  class Dropbox

    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @dropbox = ::DropboxSession.new(@consumer_key, @consumer_secret)
      @dropbox_oauth2 = ::DropboxOAuth2FlowBase.new(@consumer_key, @consumer_secret)
    end

    def get_request_token
      # Pulled from Dropbox SDK
      @dropbox.get_token("/request_token", nil, "Error getting request token.  Is your app key and secret correctly set?")
    end

    def get_authorize_url(request_token, callback=nil)
      url = "/#{::Dropbox::API_VERSION}/oauth/authorize?oauth_token=#{URI.escape(request_token.key)}"

      if callback
          url += "&oauth_callback=#{URI.escape(callback)}"
      end

      "https://#{::Dropbox::WEB_SERVER}#{url}"
    end

    def get_authorize_url2(redirect=nil, state=nil)
      @dropbox_oauth2._get_authorize_url(redirect, state)
    end

    def get_access_token(request_token)
      if request_token.nil?
        raise DropboxAuthError.new("No request token. You must set this or get an authorize url first.")
      end

      @dropbox.get_token("/access_token", request_token,  "Couldn't get access token.")
    end

    def get_oauth2_token(oauth2_code, redirect)
      if oauth2_code.nil?
          raise DropboxAuthError.new("No OAuth2 Code. You must set this or get an authorize url first.")
      end

      @dropbox_oauth2._finish(oauth2_code, redirect)
    end

    def request_token_to_json(request_token)
      request_token.to_json
    end

    def request_token_from_json(request_token)
      request_token = JSON.parse(request_token)
      ::OAuthToken.new(request_token["key"], request_token["secret"])
    end

    def __muted_send__(method, *args, &block)
      @dropbox.send(method, *args, &block)
    rescue StandardError, Timeout::Error => e
      nil
    end

    def method_missing(method, *args, &block)
      method = method.to_s

      if method =~ /^muted_(.+)$/
        __muted_send__($1, *args, &block)
      else
        @dropbox.send(method, *args, &block)
      end
    end
  end
end
