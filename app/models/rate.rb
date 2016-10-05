class Rate < ApplicationRecord
  belongs_to :zone
  belongs_to :carrier, counter_cache: true
  
  enum status: [ :active, :pending, :expired ]
  
  default_scope { order('name ASC') }
  
  def price_min=(num)
    num.gsub!(',','.') if num.is_a?(String)
    self[:price_min] = num.to_d
  end

  
  def self.from_file(file, current_user, carrier_id)
  	 imported_rows = 0
     spreadsheet = Xls.get_spreadsheet(file);
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
		#code = find_by_prefix(row["prefix"]) || new
        #code.attributes = row.to_hash.slice(*row.to_hash.keys)
        
        #Rate.create(carrier_id: carrier_id, name: spreadsheet.row(i)[0], prefix: spreadsheet.row(i)[1], price_min: spreadsheet.row(i)[2])
        
        if Rate.create_with(carrier_id: carrier_id, name: spreadsheet.row(i)[0], prefix: spreadsheet.row(i)[1], price_min: spreadsheet.row(i)[2]).find_or_create_by(prefix: spreadsheet.row(i)[1])
        	imported_rows +=1
        end
        
	  end
	  
	  #return imported_rows
	  JobNotificationMailer.job_status("Rate Import", current_user , "Success", "Subject", "Task completed, imported rows #{imported_rows}").deliver_now
  end
  
  
  
  def self.spada
  	  
	Rate.all.each do |r|
	c = Code.find_zone(r.prefix).pluck(:zone_id)
	r.zone_id = c[0]
	r.save!
	end  
  	  
  
  
  end
  
  
  
  
end
