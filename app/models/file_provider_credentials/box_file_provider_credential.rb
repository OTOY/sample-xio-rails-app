class BoxFileProviderCredential < FileProviderCredential

  provider_credentials_attr_accessor :access_token, :refresh_token

  def get_authorization_url(callback_url)
    return {
      :token => nil,
      :url => $box.authorize_url(callback_url)
    }
  end

  def create_from_access_token(request_token, current_user, callback_url, params=nil)
    token = $box.get_access_token(params[:code])
    credentials = BoxCloudFsCredential.new(:access_token => token.token,
                    :refresh_token => token.refresh_token,
                    :user => current_user,
                    :expires_at => Time.at(token.expires_at))
    credentials.save!
  end

  def update_provider_details
    client = ::RubyBox::Client.new(box_session)
    self.provider_account_details = client.me.as_json
    self.label = provider_account_details["login"]
  end

  def box_session
    ::RubyBox::Session.new({
      :client_id => Appslingr::Config[:cloud_fs][:box][:id],
      :client_secret => Appslingr::Config[:cloud_fs][:box][:secret],
      :access_token => self.access_token,
      :refresh_token => self.refresh_token
    })
  end

  def updated_access_token(force=false)
    if expires_at < 15.minutes.from_now || force
      begin
        token = box_session.refresh_token(self.refresh_token)
        self.refresh_token = token.refresh_token
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
