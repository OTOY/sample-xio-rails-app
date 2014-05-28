require "google/api_client"

class Otoy
  class GoogleDrive

    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @google_drive = ::Google::APIClient.new(
        :application_name => "X.IO Sample Web App"
      )
      @google_drive.authorization.client_id = @consumer_key
      @google_drive.authorization.client_secret = @consumer_secret
      @google_drive.authorization.scope = ['https://www.googleapis.com/auth/drive', 'email']
    end

    def redirect_uri=(uri)
      @google_drive.authorization.redirect_uri ||= uri
    end

    def __muted_send__(method, *args, &block)
      @google_drive.send(method, *args, &block)
    rescue StandardError, Timeout::Error => e
      nil
    end

    def method_missing(method, *args, &block)
      method = method.to_s

      if method =~ /^muted_(.+)$/
        __muted_send__($1, *args, &block)
      else
        @google_drive.send(method, *args, &block)
      end
    end
  end
end
