class FileProvidersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :set_file_provider, :except => [:new, :callback]
  before_filter :user_has_access

  def destroy
    if @provider.destroy
      redirect_to edit_user_registration_path, :notice => "Provider deleted"
    else
      redirect_to edit_user_registration_path, :notice => "Unable to delete provider"
    end
  end

  def new
    if !params[:provider] || !FileProviderCredential.valid_type?(params[:provider])
      redirect_to :back, :notice => "Invalid provider specified"
      return
    end
    request = FileProviderCredential.new_of_type(params[:provider]).get_authorization_url(provider_callback_users_url)
    session[:provider_request] = params[:provider]
    session[:provider_token] = request[:token]
    redirect_to request[:url]
  end

  def callback
    if !session[:provider_request]
      redirect_to edit_user_registration_path, :notice => "Missing data, aborting..."
    end
    if FileProviderCredential.new_of_type(session[:provider_request]).create_from_access_token(session[:provider_token], current_user, provider_callback_users_url, params)
      session[:provider_request] = nil
      session[:provider_token] = nil
      redirect_to edit_user_registration_path, :notice => "Provider added successfully"
    else
      redirect_to edit_user_registration_path, :notice => "Unable to add provider"
    end
  end


protected

  def user_has_access
    if @provider && @provider.user != current_user
      redirect_to :back, :notice => 'You do not have access to that provider.'
    end
  end

  def set_file_provider
    @provider ||= FileProviderCredential.find(params[:id])
  end

end
