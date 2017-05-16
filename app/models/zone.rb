class Zone < ActiveRecord::Base
  has_many :codes, dependent: :destroy
  
  validates :name, :presence => true
  validates :name, uniqueness: true
  default_scope { order('name ASC') }
  

  def self.find_zone_by_prefix(prefix)
  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2"
	   _now = "now()"
	 when "postgresql" 
	 	_now = "now()"
	    _casting = "::numeric::text"
	    _concat = " LIKE CONCAT(prefix,'%') "
	 when "sqlite3"
	    _now = "DATETIME('now')"
	    _concat = " LIKE prefix ||'%' "
	 end  	  
	 
    @code_search = ActiveRecord::Base.connection.select_all("
	     SELECT zone_id FROM codes
	     WHERE '#{prefix}' #{_concat}
	     AND zone_id is not NULL
	     AND prefix like '#{prefix[0..0]}%'
	     ORDER BY length(prefix) DESC
	     LIMIT 1
    ")
	   
    match = @code_search[0]['zone_id'] unless @code_search[0].nil?
  end

  
  
  
  def self.from_file_header_columns(file, current_user)
  	imported_rows = 0
      spreadsheet = Xls.get_spreadsheet(file); header = spreadsheet.row(1)                
      spreadsheet.each(Hash[ *header.collect { |v| [ v.downcase.to_sym,v ] }.flatten ]) do |hash|
      	imported_rows +=1 if Zone.create(hash)
      end
      #return imported_rows
      
      JobNotificationMailer.job_status("Zone Import", current_user, "Success", "Subject", "Task completed, imported rows #{imported_rows}").deliver_now
  end	
	  
  
  def self.from_file(file, current_user)
  	 imported_rows = 0
     spreadsheet = Xls.get_spreadsheet(file);
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        
        if Zone.create_with(:id => row["ID"].to_s, :name => row["Zones"].to_s).find_or_create_by(id: row["ID"].to_s)
        	imported_rows +=1
        end
        
	  end
	  
	  #return imported_rows
	  JobNotificationMailer.job_status("Zone Import", current_user , "Zone Import", "Subject", "Task completed, imported rows #{imported_rows}").deliver_now
  end
  
end
