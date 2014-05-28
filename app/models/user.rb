class User < ActiveRecord::Base

  acts_as_token_authenticatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :file_provider_credentials

  def full_name
    if first_name || last_name
      "#{first_name} #{last_name}"
    else
      email
    end
  end

  def file_providers_api_url(callback_url)
    "#{callback_url}?#{{user_email: self.email, user_token: self.authentication_token}.to_query}"
  end

  def file_providers
    if !file_provider_credentials.empty?
      file_provider_credentials.each.map(&:to_provider).compact
    else
      []
    end
  end

  def file_providers_response(callback_url)
    {
      update_url: file_providers_api_url(callback_url),
      file_providers: file_providers
    }
  end

end
