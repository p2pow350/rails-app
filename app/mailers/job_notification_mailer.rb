class JobNotificationMailer < ApplicationMailer
  
  # JobNotificationMailer.job_status("Zone Import", "mvar78@gmail.com", "Success", "Subject", "Task completed").deliver
  def job_status(source, destination, status, subject, body)
  	@source = source  
  	@status = status
  	@body = body
    mail(to: destination, subject: subject)
  end	
	
end
