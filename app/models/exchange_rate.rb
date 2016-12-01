class ExchangeRate < ApplicationRecord
  before_save :default_values
  def default_values
    self.name ||= Faker::Lorem.characters(10)
  end
  
  validates :start_date, :currency, :rate, :presence => true
  default_scope { order('start_date DESC') }
      
  
  def self.exchange(from_curr, to_curr)
  	base_currency = "eur"  		
	
    if from_curr == to_curr
      rate = 1.0
    elsif from_curr == base_currency
      @rate = ActiveRecord::Base.connection.select_all(" 
  		select rate from exchange_rates where currency = '#{to_curr}' order by start_date desc limit 1
  		" )
  	   rate = @rate[0]["rate"].to_d
    elsif to_curr == base_currency
      @r= ActiveRecord::Base.connection.select_all(" 
  		select rate from exchange_rates where currency = '#{from_curr}' order by start_date desc limit 1
  		" )
      rate = 1.0 / @r[0]["rate"].to_d
    else
      	@r_from= ActiveRecord::Base.connection.select_all(" 
  		select rate from exchange_rates where currency = '#{from_curr}' order by start_date desc limit 1
  		" )
  		
    	@r_to= ActiveRecord::Base.connection.select_all(" 
  		select rate from exchange_rates where currency = '#{to_curr}' order by start_date desc limit 1
  		" )
  		
  		rate = @r_to[0]["rate"].to_d * (1.0 / @r_from[0]["rate"].to_d)
    end
	
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
