class Carrier < ActiveRecord::Base
	validates :name, :presence => true
	default_value_for :is_supplier, true
	
	
	def self.from_file(file)		  
	    spreadsheet = Xls.get_spreadsheet(file); header = spreadsheet.row(1)                
	    spreadsheet.each(Hash[ *header.collect { |v| [ v.downcase.to_sym,v ] }.flatten ]) do |hash|
	    	Carrier.create(hash)
	    end
	end	
	
end
