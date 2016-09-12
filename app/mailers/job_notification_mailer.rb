class JobNotificationMailer < ApplicationMailer
  
  def job_status(source, destination, status, subject, body)
  	@source = source  
  	@status = status
  	@body = body
    mail(to: destination, subject: subject)
  end	
	
end
