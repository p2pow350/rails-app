Rails.application.routes.draw do
	
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
  resources :users do
    collection { post :upload }
  end  	
  
  root 'dashboards#index'
  
end
