class ExchangeRate < ApplicationRecord
  before_save :default_values
  def default_values
    self.name ||= Faker::Lorem.characters(10)
  end
  
  validates :start_date, :currency, :rate, :presence => true
  default_scope { order('start_date DESC') }
      
  def self.exchange(currency)
  	@last_update = ActiveRecord::Base.connection.select_all(" select start_date from exchange_rates where '#{Date.today.to_s}' >= start_date and currency= '#{currency}' order by start_date desc limit 1 ")
	@last_update.count == 0 ? last ='' : last = @last_update[0]["start_date"]
	
  	@rate = ActiveRecord::Base.connection.select_all(" select rate from exchange_rates where currency= '#{currency}' and start_date ='#{last}' " )
	@rate.count == 0 ? 1 : @rate[0]["rate"]
  end
  
  
  
  def self.from_file(file, current_user)
  	imported_rows = 0
      spreadsheet = Xls.get_spreadsheet(file); header = spreadsheet.row(1)                
      spreadsheet.each(Hash[ *header.collect { |v| [ v.downcase.to_sym,v ] }.flatten ]) do |hash|
      	imported_rows +=1 if ExchangeRate.create(hash)
      end
      #return imported_rows
      
      JobNotificationMailer.job_status("ExchangeRate Import", current_user, "Success", "Subject", "Task completed, imported rows #{imported_rows}").deliver_now
  end		
end