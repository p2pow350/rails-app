class Rate < ApplicationRecord
  belongs_to :zone
  belongs_to :carrier, counter_cache: true
  
  enum status: [ :active, :pending, :expired ]
  default_value_for :status, 1
 
  default_scope { order('name ASC') }
  
  def price_min=(num)
    num.gsub!(',','.') if num.is_a?(String)
    self[:price_min] = num.to_d
  end

  
  def self.best_prices
  	 ActiveRecord::Base.connection.select_all(
  	 	 	" select r.zone_id zone_id, min(r.price_min) price_min
			from rates r, carriers c
			where r.carrier_id = c.id
			and c.status = 't'
			group by r.zone_id "
	  )
  end  


  def self.prices
  	 ActiveRecord::Base.connection.select_all(
  	 	 	" select r.zone_id || '-' || r.carrier_id id, max(r.price_min) price_min
			from rates r
			group by r.zone_id, r.carrier_id"
	  )
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
	  
	  Rate.spada(carrier_id)
	  
	  #return imported_rows
	  JobNotificationMailer.job_status("Rate Import", current_user , "Success", "Subject", "Task completed, imported rows #{imported_rows}").deliver_now
  end
  
  
  
  def self.spada(carrier_id)
  	  
	 Rate.where(:carrier_id => carrier_id).each do |r|
	   # Prima fase, match esatto!	
	   c = Code.find_zone(r.prefix).pluck(:zone_id)
	   r.zone_id = c[0]
	   r.save!
	 end
	 
  end
  
  
  
end