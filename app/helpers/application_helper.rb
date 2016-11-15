module ApplicationHelper
	
	def active_class(link_path) current_page?(link_path) ? "active" : "" end
		
	# Comparison View
	def empty_rate(value)
		_v = number_with_precision(value, precision: 4)
		_v ||= '--'
	end	
  	
end
