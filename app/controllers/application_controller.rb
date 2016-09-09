class ApplicationController < ActionController::Base
  semantic_breadcrumb :index, :root_path
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception  
  
  # default devise
  before_action :authenticate_user!

  # set locale
  before_action :set_locale
    
  # default WillPaginate
  WillPaginate.per_page = 15
  
  def set_locale
  	I18n.locale = current_user.default_locale || session[:locale] || params[:locale] || I18n.default_locale if user_signed_in? 
  end  
  
end
