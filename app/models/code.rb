class Code < ActiveRecord::Base
  belongs_to :zone, counter_cache: true
  
  validates :name, :prefix, :zone_id, :presence => true
  validates :name, uniqueness: { scope: [:prefix] }
  validates :prefix, numericality: { only_integer: true }
  before_save :fix_counter_cache, :if => ->(er) { !er.new_record? && er.zone_id_changed? }
  
  default_scope { order('name ASC') }
  
  def self.from_file(file, current_user)
  	 imported_rows = 0
     spreadsheet = Xls.get_spreadsheet(file);
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        
        if Code.create_with(:name => row["Zone"].to_s, :prefix => row["Code"].to_s, :zone_id => Zone.where(name: row["Zone"].to_s).pluck(:id)[0].to_i).find_or_create_by(prefix: row["Code"].to_s)
        	imported_rows +=1
        end
        
	  end
	  
	  #return imported_rows
	  JobNotificationMailer.job_status("Code Import", current_user , "Code Import", "Subject", "Task completed, imported rows #{imported_rows}").deliver_now
  end
  
  
  def self.find_our_zone(prefix)
  	  
  	  # MySQL
  	#Code.find_by_sql "
  	#	SELECT zone_id, name, prefix
	#FROM codes
	#-- POSITION(prefix IN '#{dialled_number}') = 1
	#ORDER BY LENGTH(prefix) DESC
	#LIMIT 1"
  	  
  	  # Sqlite
  	  Code.find_by_sql "
  	  	SELECT zone_id, name, prefix
		FROM codes
		WHERE '#{prefix}' LIKE prefix||'%'
		ORDER BY LENGTH(prefix) DESC
		LIMIT 1"
  	  
  	  
  end
  
  
  
end


private

    def fix_counter_cache
        Zone.decrement_counter(:codes_count, self.zone_id_was)
        Zone.increment_counter(:codes_count, self.zone_id)
    end  
