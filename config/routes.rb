Rails.application.routes.draw do

  devise_for :users, :controllers => { :registrations => "registrations" }
  resource :users do
    resources :file_providers, :only => [:new, :destroy]
    match '/file_providers/callback' => "file_providers#callback", :as => :provider_callback, :via => :get
  end

  get 'api/file_providers' => "api#file_providers"

  root 'welcome#index'
end
