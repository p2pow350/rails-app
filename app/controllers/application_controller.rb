class ApplicationController < ActionController::Base
  semantic_breadcrumb :index, :root_path
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # default devise
  before_action :authenticate_user!
  
  # default WillPaginate
  WillPaginate.per_page = 15
  
end
