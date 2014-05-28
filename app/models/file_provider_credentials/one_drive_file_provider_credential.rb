class OneDriveFileProviderCredential < FileProviderCredential

  provider_credentials_attr_accessor :access_token, :refresh_token

  def get_authorization_url(callback_url)
    return {
      :token => nil,
      :url => $onedrive.authorize_url(callback_url)
    }
  end

  def create_from_access_token(request_token, current_user, callback_url, params=nil)
    token = $onedrive.get_access_token(params[:code], callback_url)
    credentials = OneDriveFileProviderCredential.new(:access_token => token.token,
                        :refresh_token => token.refresh_token,
                        :user => current_user,
                        :expires_at => Time.at(token.expires_at))
    credentials.save!
  end

  def update_provider_details
    client = ::Skydrive::Client.new(skydrive_session)
    self.provider_account_details = client.me.as_json
    self.label = provider_account_details["name"]
  end

  def skydrive_session
    Otoy::Skydrive::OauthClient.new(
      ENV['ONE_DRIVE_ID'],
      ENV['ONE_DRIVE_SECRET'],
      nil,
      "wl.contacts_skydrive,wl.skydrive_update,wl.offline_access"
    ).get_access_token_from_hash(self.access_token, :refresh_token => self.refresh_token)
  end

  def updated_access_token(force=false)
    if expires_at < 15.minutes.from_now || force
      begin
        token = ::Skydrive::Client.new(skydrive_session).refresh_access_token!
        self.access_token = token.token
        self.expires_at = Time.at(token.expires_at)
        self.save!
      rescue
      end
    end
    access_token
  end

  def to_specific_provider
    {
      "access_token" => updated_access_token
    }
  end

end
