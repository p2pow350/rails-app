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
    
  def self.reset_zones
  	 ActiveRecord::Base.connection.execute(
  	 	 	" update rates set zone_id = NULL"
	  )
  end    
  
  def self.best_prices
  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2"
	   true_flag = '1'
	 when "sqlite3"
	   true_flag = 't'
	 end  	  
  	  
  	 ActiveRecord::Base.connection.select_all(
  	 	 	" select r.zone_id zone_id, min(r.price_min) price_min
			from rates r, carriers c
			where r.carrier_id = c.id
			and c.status = '#{true_flag}'
			and r.status = 2
			group by r.zone_id "
	  )
  end  


  def self.prices
  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2"
		ActiveRecord::Base.connection.select_all(
			" SELECT
				concat(r.zone_id , '-' , r.carrier_id) id ,
				max(r.price_min) price_min
			FROM
				rates r
			WHERE status=2
			GROUP BY
				r.zone_id ,
				r.carrier_id "
		)
	 when "sqlite3"
		ActiveRecord::Base.connection.select_all(
			" select r.zone_id || '-' || r.carrier_id id, max(r.price_min) price_min
			from rates r
			WHERE status=2
			group by r.zone_id, r.carrier_id"
		)
	 end  	  
  	  
  	  
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
	 
	 Rate.spada_base(carrier_id)
	 #Rate.spada(carrier_id)
	 Rate.change_rate_status(carrier_id)
	 
	 #return imported_rows
	 JobNotificationMailer.job_status("Rate Import", current_user , "Success", "Rate Import", "Task completed, imported rows #{imported_rows}").deliver_now
  end
  
  
  def self.change_rate_status(carrier_id, *args)
  	    options = args.extract_options!
  	    param_zone = options[:zone]
        if param_zone
          additional_filter = " and zone_id = #{param_zone} "
        end    
  	    
		@zones = ActiveRecord::Base.connection.select_all(
			" select zone_id, count(*)
				from rates 
				where carrier_id = #{carrier_id}
				and zone_id is not null
				#{additional_filter}
				group by zone_id
			 "
		)
		
		@zones.rows.each do |z|
			r = Rate.find_by_zone_id(z[0])
			if z[1] == 1 
				r.status = 2
				r.save!
			else
				_r = Rate.where(:zone_id=>z[0], :carrier_id=>carrier_id ).each do |rs|
					
					if rs.start_date.strftime("%Y-%m-%d") == DateTime.now.strftime("%Y-%m-%d")
						rs.status = 2
						rs.save!
					elsif rs.start_date.strftime("%Y-%m-%d") < DateTime.now.strftime("%Y-%m-%d")
						rs.status = 0
						rs.save!
					else
						rs.status = 1
						rs.save!
					end
				end
				
			end
			
			#latest active
		    @upd = ActiveRecord::Base.connection.execute(
		    	" update rates set status=2 where zone_id = #{z[0]} and start_date in(
					select max(start_date) from rates r2
					where start_date <> (select max(start_date) from rates where zone_id = #{z[0]} )
					)
				 and zone_id = #{z[0]} 
		    	 "
		    )

		end
		
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
  	  	   	spada.deep_merge!(s3) if spada[f3.zone_id][:flag1] != 'EXACT'
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
