class DropboxFileProviderCredential < FileProviderCredential

  provider_credentials_attr_accessor :access_token

  provider_auth_type "oauth2"

  def get_authorization_url(callback_url)
    return {
      :token => nil,
      :url => $dropbox.get_authorize_url2(callback_url)
    }
  end

  def create_from_access_token(request_token, current_user, callback_url, params=nil)
    access_token = $dropbox.get_oauth2_token(params[:code], callback_url)
    credentials = DropboxFileProviderCredential.new(:access_token => access_token[0], :user => current_user)
    credentials.save!
  end

  def update_provider_details
    client = ::DropboxClient.new(self.access_token)
    self.provider_account_details = client.account_info
    self.label = provider_account_details["email"]
  end

  def to_specific_provider
    {
      "userToken" => access_token
    }
  end

end
