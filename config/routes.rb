Rails.application.routes.draw do
	
  resources :rates do
    collection { post :upload }
    get 'generate', :on => :collection
    get 'comparison', :on => :collection
  end  	
	
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
