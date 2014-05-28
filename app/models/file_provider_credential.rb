class FileProviderCredential < ActiveRecord::Base

  belongs_to :user

  serialize :provider_account_details
  serialize :provider_credentials

  before_save :update_provider_details
  before_save :update_provider_credentials

  def self.types
    # Make sure to add new FileProviderCredentials to this list
    {
      "Dropbox"       => "Dropbox",
      "Box"           => "Box",
      "OneDrive"      => "OneDrive",
      "GoogleDrive"   => "Google Drive"
    }.with_indifferent_access
  end

  def self.new_of_type(str_type, opts={})
    if valid_type?(str_type)
      (str_type.camelcase + "FileProviderCredential").constantize.new(opts)
    else
      raise "Invalid File Provider Credential Type"
    end
  end

  def self.valid_type?(str_type)
    types.keys.include?(str_type.camelcase)
  end

  def self.provider_auth_type(auth_type)
    @auth_type = auth_type
  end

  def self.auth_type
    @auth_type
  end

  def auth_type
    self.class.auth_type
  end

  def self.provider_credentials_attr_accessor(*attrs)
    attrs.each do |provider_credential|
      define_method(:"#{provider_credential}=") do |value|
        self.provider_credentials ||= {}.with_indifferent_access
        self.provider_credentials[:"#{provider_credential}"] = value
      end

      define_method(:"#{provider_credential}") do
        (provider_credentials || {}.with_indifferent_access)[:"#{provider_credential}"]
      end
    end
  end

  def update_provider_credentials
    self.provider_credentials = provider_credentials
  end

  def human_type
    FileProviderCredential.types[self.class.name.sub("FileProviderCredential", '')]
  end

  def get_authorization_url
    raise "Not implemented"
  end

  def create_from_access_token(request_token, current_user, params=nil)
    raise "Not implemented"
  end

  def update_provider_details
    raise "Not implemented"
  end

  def provider_label
    return self.label if self.label
    update_provider_details
    self.label
  end

  def api_provider_type
    self.class.name.sub("FileProviderCredential", '').underscore
  end

  def to_provider
    {
      "id" => id.to_s,
      "provider_type" => api_provider_type,
      "auth_type" => auth_type,
      "label" => provider_label,
      "expires_at" => expires_at
    }.merge(to_specific_provider)
  end

  def to_specific_provider
    {}
  end
end
