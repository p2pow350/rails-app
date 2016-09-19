Rails.application.configure do
	
	# general settings
    config.action_mailer.default_url_options = { :host => 'localhost:3000' }  #if it is local then 'localhost:3000'
    config.action_mailer.delivery_method = :smtp 

	# get database settings
  	@smtp_settings = Hash[Option.where(:area => 'mail_out').pluck(:key, :value)] 

    ActionMailer::Base.raise_delivery_errors = true    
    ActionMailer::Base.smtp_settings = {
      :from 				=> @smtp_settings["user_name"],	
      :address              => @smtp_settings["address"],
      :port                 => @smtp_settings["port"].to_i,
      :domain               => @smtp_settings["domain"],
      :user_name            => @smtp_settings["user_name"],
      :password             => @smtp_settings["password"],
      :authentication       => @smtp_settings["authentication"],
      :enable_starttls_auto => @smtp_settings["enable_starttls_auto"]
    }
    
end