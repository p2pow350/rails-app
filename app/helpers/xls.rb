require 'roo'
module Xls
    
    def self.get_spreadsheet(file)
 	  file = File.open(file)    
      open_spreadsheet(file)      	  
    end
     
      
private
    
	def self.open_spreadsheet(file)
	  case File.extname(file)
		when ".csv" then Roo::CSV.new(file.path, csv_options: {col_sep: ","})
		when ".ods" then Roo::OpenOffice.new(file.path)
		when ".xls" then Roo::Excel.new(file.path)
		when ".xlsx" then Roo::Excelx.new(file.path)
	  else raise "Unknown file type: #{file}"
	  end
	end      

end