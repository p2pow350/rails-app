Rails.application.routes.draw do
	
  resources :options
	
  resources :users_admin, :controller => 'users'
	
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
