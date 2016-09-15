class Rate < ApplicationRecord
  belongs_to :zone
  belongs_to :carrier, counter_cache: true
  
  enum status: [ :active, :pending, :expired ]
  
  default_scope { order('name ASC') }
  
  def self.from_file(file, current_user)
  	 imported_rows = 0
     spreadsheet = Xls.get_spreadsheet(file);
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
		#code = find_by_prefix(row["prefix"]) || new
        #code.attributes = row.to_hash.slice(*row.to_hash.keys)
        
        if Rate.create_with(:name => row["name"].to_s, :prefix => row["prefix"].to_s, :zone_id => row["zone"].to_i).find_or_create_by(prefix: row["prefix"].to_s)
        	imported_rows +=1
        end
        
	  end
	  
	  #return imported_rows
	  JobNotificationMailer.job_status("Rate Import", current_user , "Success", "Subject", "Task completed, imported rows #{imported_rows}").deliver_now
  end
  
  
end
