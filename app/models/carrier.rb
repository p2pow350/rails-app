class Carrier < ActiveRecord::Base
	validates :name, :presence => true
	default_value_for :is_supplier, true
	
	
	def self.from_file(file)
		imported_rows = 0
	    spreadsheet = Xls.get_spreadsheet(file); header = spreadsheet.row(1)                
	    spreadsheet.each(Hash[ *header.collect { |v| [ v.downcase.to_sym,v ] }.flatten ]) do |hash|
	    	imported_rows +=1 if Carrier.create(hash)
	    end
	    return imported_rows
	end	
	
end
