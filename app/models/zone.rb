class Zone < ActiveRecord::Base
  has_many :codes, dependent: :destroy
  
  validates :name, :presence => true
  validates :name, uniqueness: true
  default_scope { order('name ASC') }
  
  def self.from_file(file)
  	imported_rows = 0
      spreadsheet = Xls.get_spreadsheet(file); header = spreadsheet.row(1)                
      spreadsheet.each(Hash[ *header.collect { |v| [ v.downcase.to_sym,v ] }.flatten ]) do |hash|
      	imported_rows +=1 if Zone.create(hash)
      end
      #return imported_rows
      
      JobNotificationMailer.job_status("Zone Import", "mvar78@gmail.com", "Success", "Subject", "Task completed, imported rows #{imported_rows}").deliver
  end	
	  
end
