require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

scheduler.every '3h' do
	# do stuff
	system("rake code_counter")
	system("rake rate_counter")
end