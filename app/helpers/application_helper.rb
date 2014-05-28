module ApplicationHelper

  def bootstrap_class_for flash_type
    case flash_type.to_sym
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-danger"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def sign_api_request(method, url, params, secret_key, expires = 24.hours.from_now.to_i)
    # Build string to sign
    sign_string = method.upcase + "&"
    sign_string += Otoy::Utilities.url_escape(url) + "&"
    sign_string += Otoy::Utilities.url_escape(params)

    # Sign it
    digest = OpenSSL::Digest.new('sha256')
    Otoy::Utilities.safe_b64_encode(OpenSSL::HMAC.digest(digest, secret_key, sign_string))
  end

end
