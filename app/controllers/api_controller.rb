class ApiController < ApplicationController

  acts_as_token_authentication_handler_for User, fallback_to_devise: false
  before_filter :authenticate_user!

  def file_providers
    render :json => current_user.file_providers_response(api_file_providers_url)
  end

end
