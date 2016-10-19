module ApplicationHelper
	
	def active_class(link_path) current_page?(link_path) ? "active" : "" end
	
	# Comparison View
	def empty_rate(value)
		value ||= '--'
	end	
  
end
