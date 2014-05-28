class User < ActiveRecord::Base

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

end
