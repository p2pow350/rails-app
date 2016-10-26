class ApplicationMailer < ActionMailer::Base
	
  default :from => Option.where(:area => 'mail_out').find_by_o_key("user_name").value
  
end

