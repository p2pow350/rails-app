require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

scheduler.every '3h' do
	# do stuff
	system("rake code_counter")
	system("rake rate_counter")
end


scheduler.cron '5 0 * * *' do
  # do something every day, five minutes after midnight
  system("rake rates_expiration")
end