Rails.application.routes.draw do

  # http://localhost:3000/localtower
  # if Rails.env.development?
  #   mount Localtower::Engine, at: "localtower"
  # end	
	
  resources :rates do
    collection { post :upload }
    get 'generate', :on => :collection
    get 'generated_rates_view', :on => :collection
    post 'generated_rates_view', :on => :collection
    post 'generate', :on => :collection
    get 'comparison', :on => :collection
  end  	
	
  resources :templates

  resources :options
	
  resources :users_admin, :controller => 'users'

  resources :exchange_rates do
    collection { post :upload }
  end  	

  resources :codes do
    collection { post :upload }
  end  	
	
  resources :zones do
    collection { post :upload }
  end  	
	
  resources :carriers do
    collection { post :upload }
  end  
  
  resources :dashboards
  devise_for :users

  root 'dashboards#index'
  
end
