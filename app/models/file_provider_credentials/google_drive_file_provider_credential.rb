class GoogleDriveFileProviderCredential < FileProviderCredential

  provider_credentials_attr_accessor :access_token, :refresh_token

  provider_auth_type "oauth2"

  def get_authorization_url(callback_url)
    $google_drive.redirect_uri = callback_url
    return {
      :token => nil,
      :url => $google_drive.authorization.authorization_uri(:access_type => :offline).to_s
    }
  end

  def create_from_access_token(request_token, current_user, callback_url, params=nil)
    drive_client = $google_drive.dup
    drive_client.authorization.code = params[:code]
    token = drive_client.authorization.fetch_access_token!
    credentials = GoogleDriveFileProviderCredential.new(:access_token => token["access_token"],
                              :refresh_token => token["refresh_token"],
                              :user => current_user,
                              :expires_at => Time.at(Time.now.to_i + token["expires_in"].to_i))
    credentials.save!
  end

  def update_provider_details
    self.provider_account_details = id_token.as_json
    self.label = provider_account_details["email"]
  end

  def id_token
    tokens = google_drive_session.authorization.fetch_access_token!
    id_token = tokens["id_token"].split('.')[1]
    id_token += (['='] * (id_token.length % 4)).join('')
    JSON.parse(Base64.decode64(id_token))
  end

  def google_drive_session
    session = $google_drive.dup
    session.authorization.access_token = self.access_token
    session.authorization.refresh_token = self.refresh_token
    session
  end

  def updated_access_token(force=false)
    if expires_at < 15.minutes.from_now || force
      begin
        token = google_drive_session.authorization.refresh!
        self.access_token = token["access_token"]
        self.expires_at = Time.at(Time.now.to_i + token["expires_in"].to_i)
        self.save!
      rescue
      end
    end
    access_token
  end

  def to_specific_provider
    {
      "userToken" => updated_access_token
    }
  end

end
