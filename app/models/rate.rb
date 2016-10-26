class Rate < ApplicationRecord
  belongs_to :zone
  belongs_to :carrier, counter_cache: true
  before_save :fix_counter_cache, :if => ->(er) { !er.new_record? && er.carrier_id_changed? }
  
  enum status: [ :expired, :pending, :active ]
  default_value_for :status, 2
 
  default_scope { order('name ASC') }
  
  def price_min=(num)
    num.gsub!(',','.') if num.is_a?(String)
    self[:price_min] = num.to_d
  end

  def self.truncate
  	 ActiveRecord::Base.connection.execute(
  	 	 	" delete from rates "
	  )
	 Carrier.update_all rates_count: 0
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
       
       # ZONA, PREFISSO, PREZZO_MIN, DATA_VALIDITA
       imported_rows +=1 if Rate.create_with(carrier_id: carrier_id, name: spreadsheet.row(i)[0], prefix: spreadsheet.row(i)[1].to_s, price_min: spreadsheet.row(i)[2], start_date: spreadsheet.row(i)[3]).find_or_create_by(carrier_id: carrier_id, prefix: spreadsheet.row(i)[1].to_s, price_min: spreadsheet.row(i)[2], start_date: spreadsheet.row(i)[3])
       
	 end
	 
	 #Rate.spada(carrier_id)
	 Rate.spada_base(carrier_id)
	 
	 #return imported_rows
	 JobNotificationMailer.job_status("Rate Import", current_user , "Success", "Rate Import", "Task completed, imported rows #{imported_rows}").deliver_now
  end
  
  
  
  def self.spada(carrier_id)
  	  unless Rate.where(:carrier_id => carrier_id).count == 0 

  	  spada = Hash.new
  	  
  	  Zone.select(:id).each do |z|
  	  	 s0 = {z.id => {:carrier_zone_name => nil, :carrier_prefix => nil, :price_min => nil, :start_date => nil, :flag1 => nil, :flag2 => nil, :flag3 => nil} }
  	  	 spada.deep_merge!(s0)
  	  end
  	  

	  ## Prima fase, match esatto!
	  ## Ns Prefissi vs Carrier
  	  Code.select(:zone_id, :prefix).each do |c|
  	  	 unless Rate.where(:carrier_id =>carrier_id).find_by_prefix(c.prefix).nil?
  	  	 	f1=Rate.where(:carrier_id =>carrier_id).find_by_prefix(c.prefix)
  	  	 	s1= {c.zone_id => {:carrier_zone_name => f1.name, :carrier_prefix => f1.prefix, :price_min => f1.price_min, :start_date => f1.start_date, :flag1 => 'EXACT', :flag2 => nil, :flag3 => nil} }
  	  	 	spada.deep_merge!(s1)
  	  	 end
  	  end
  	  
	  ## Seconda fase, match simile!
	  ## Ns Prefissi vs Carrier
  	  Code.select(:zone_id, :prefix).each do |c|
  	  	_substring=c.prefix
		counter=_substring.length
		
		begin
		 match = _substring[0..counter]
		 
  	  	   unless Rate.where(:carrier_id =>carrier_id).find_by_prefix(match).nil?
  	  	   	f2=Rate.where(:carrier_id =>carrier_id).find_by_prefix(match)
  	  	   	s2= {c.zone_id => {:carrier_zone_name => f2.name, :carrier_prefix => f2.prefix, :price_min => f2.price_min, :start_date => f2.start_date, :flag1 => nil, :flag2 => 'SIMILAR', :flag3 => nil} }
  	  	   	spada.deep_merge!(s2) if spada[c.zone_id][:flag1] != 'EXACT'
  	  	   end
		 
		 counter-=1
		end while counter >= 0
	  end
  	  

	  ## Terza fase, match simile!
	  ## Prefissi Carrier vs Nostri
  	  Rate.where(:carrier_id => carrier_id).each do |r|
  	  	_substring=r.prefix
		counter=_substring.length
		
		begin
		 match = _substring[0..counter]
		 
  	  	   unless Code.find_by_prefix(match).nil?
  	  	   	f3=Code.find_by_prefix(match)
  	  	   	s3= {f3.zone_id => {:carrier_zone_name => r.name, :carrier_prefix => r.prefix, :price_min => r.price_min, :start_date => r.start_date, :flag1 => nil, :flag2 => nil, :flag3 => match} }
  	  	   	spada.deep_merge!(s3) if spada[c.zone_id][:flag1] != 'EXACT'
  	  	   end
		 
		 counter-=1
		end while counter >= 0
	  end
	  
	  
	  
  	  p spada
  	  
	 ## Prima fase, match esatto!
	 ## Ns Prefissi vs Carrier
	 #Rate.where(:carrier_id => carrier_id).each do |r|
	 #  unless Code.find_by_prefix(r.prefix.to_s).nil?
	 #  	  c = Code.select(:zone_id).find_by_prefix(r.prefix.to_s)
	 #  	  r.zone_id = c["zone_id"]
	 #  	  r.flag1='ESATTO_MATCH'
	 #  	  r.save
	 #  end
	 #end

	 
	 
 	end #unless
  end
  
  def self.spada_base(carrier_id)
	 # Prima fase, match esatto!
	 # Ns Prefissi vs Carrier
	 Rate.where(:carrier_id => carrier_id).each do |r|
	   unless Code.find_by_prefix(r.prefix.to_s).nil?
	   	  c = Code.select(:zone_id).find_by_prefix(r.prefix.to_s)
	   	  r.zone_id = c["zone_id"]
	   	  r.flag1='ESATTO_MATCH'
	   	  r.save
	   end
	 end
  end
  
  
end 



private

    def fix_counter_cache
        Carrier.decrement_counter(:rates_count, self.carrier_id_was)
        Carrier.increment_counter(:rates_count, self.carrier_id)
    end  
