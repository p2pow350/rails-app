class ApplicationController < ActionController::Base
  semantic_breadcrumb :index, :root_path
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception  
  
  # default devise
  before_action :authenticate_user!

  # set locale
  before_action :set_locale
  
  # get settings
  before_action :set_mailer_settings
    
  # default WillPaginate
  WillPaginate.per_page = 15
  
  def set_locale
  	I18n.locale = current_user.default_locale || session[:locale] || params[:locale] || I18n.default_locale if user_signed_in? 
  end  
  
  
private

  def set_mailer_settings
  	    
  	#smtp_settings = Option.where(:area => 'mail_out').map{ |o| [o.key,o.value] }.to_h     	
  	@smtp_settings = Hash[Option.where(:area => 'mail_out').pluck(:key, :value)] 
  	#Rails.cache.write(smtp_settings, @smtp_settings , expires_in: 30.days)  
  	#Rails.cache.read({key: 'domain'})

    #ActionMailer::Base.smtp_settings.merge!({
    #  username: 'username',
    #  password: 'yoursupersecretpassword'
    #})

    ActionMailer::Base.raise_delivery_errors = true    
    ActionMailer::Base.smtp_settings = {
      :address              => @smtp_settings["address"],
      :port                 => @smtp_settings["port"],
      :domain               => @smtp_settings["domain"],
      :user_name            => @smtp_settings["user_name"],
      :password             => @smtp_settings["password"],
      :authentication       => @smtp_settings["authentication.name"],
      :enable_starttls_auto => @smtp_settings["enable_starttls_auto"]
    }    
  end
  
  
end
