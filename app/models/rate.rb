class Rate < ApplicationRecord
  belongs_to :zone
  belongs_to :carrier, counter_cache: true
  before_save :fix_counter_cache, :if => ->(er) { !er.new_record? && er.carrier_id_changed? }
  
  enum status: [ :expired, :pending, :active ]
  default_value_for :status, 2
  #default_scope { order('name ASC') }

  
  def self.Faker  
  	  
	Carrier.enabled.each do | c |
		Zone.all.each do | z |
			
			random = Faker::Number.between(1, 10);
			if random >=5
				_start_date = Faker::Time.backward
			else
				_start_date = Faker::Time.forward
			end
				
			Rate.create(carrier_id: c.id, zone_id: z.id, price_min: Faker::Number.decimal(2, 3).to_f / 300, start_date: _start_date)
		
		end
	
	end  	  
  	  
  end
  
  
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
  
  
  def self.best_prices(currency)
  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2", "postgresql"
	   true_flag = '1'
	 when "sqlite3"
	   true_flag = 't'
	 end  	  
  	  
  	 result = ActiveRecord::Base.connection.select_all(
  	 	 	" select r.zone_name zone_id, c.currency, min(r.price_min) price_min
			from code_processes r, carriers c
			where r.carrier_id = c.id
			and c.status = '#{true_flag}'
			-- and r.status = 2
			and r.zone_name is not null
			group by r.zone_name, c.currency "
	  )
	 
	 r = Array.new
	 
	 result.each do |row|
	 	row['currency'] == currency ? rate = 1.0 : rate = ExchangeRate.exchange(row['currency'], currency)
	 	r.push([row['zone_id'], row['price_min'].to_f / rate.to_f ])
	 end
	 
	 return r
  end  
  
  
  
  def self.best_prices_id(currency)
  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2", "postgresql"
	   true_flag = '1'
	 when "sqlite3"
	   true_flag = 't'
	 end  	  
  	  
  	 result = ActiveRecord::Base.connection.select_all(
  	 	 	" select r.zone_id zone_id, c.currency, min(r.price_min) price_min
			from rates r, carriers c
			where r.carrier_id = c.id
			and c.status = '#{true_flag}'
			and r.status = 2
			and r.zone_id is not null
			group by r.zone_id, c.currency "
	  )
	 
	 r = Array.new
	 
	 result.each do |row|
	 	row['currency'] == currency ? rate = 1.0 : rate = ExchangeRate.exchange(row['currency'], currency)
	 	r.push([row['zone_id'], row['price_min'].to_f / rate.to_f ])
	 end
	 
	 return r
  end  

  
  def self.prices(currency)
  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2", "postgresql"
	 	 
	 	 
		result = ActiveRecord::Base.connection.select_all(
			" SELECT
				concat(r.zone_name , '-' , r.carrier_id) id, c.currency,
				max(r.price_min) price_min
			FROM
				code_processes r, carriers c
			WHERE
			c.id=r.carrier_id
			-- AND r.status =2
			AND r.zone_name is not null
			GROUP BY
				r.zone_name ,
				c.currency,
				r.carrier_id"
		)
	 when "sqlite3"
		result = ActiveRecord::Base.connection.select_all(
			" select r.zone_name || '-' || r.carrier_id id, c.currency, max(r.price_min) price_min
			  from code_processes r, carriers c
			  WHERE
			   c.id=r.carrier_id
			  -- AND r.status =2
			  AND r.zone_name is not null
			  group by r.zone_name, c.currency, r.carrier_id "
		)
	 end  	  
  	  
	 r = Array.new
	 
	 result.each do |row|
	 	row['currency'] == currency ? rate = 1.0 : rate = ExchangeRate.exchange(row['currency'], currency)
		r.push([row['id'], row['price_min'].to_f / rate.to_f ])
	 end
	 
	 return r

  end    
  

  def self.prices_id(currency)
  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2", "postgresql"
		result = ActiveRecord::Base.connection.select_all(
			" SELECT
				concat(r.zone_id , '-' , r.carrier_id) id, c.currency,
				max(r.price_min) price_min
			FROM
				rates r, carriers c
			WHERE r.status=2
			AND c.id=r.carrier_id
			AND r.zone_id is not null
			GROUP BY
				r.zone_id ,
				c.currency,
				r.carrier_id"
		)
	 when "sqlite3"
		result = ActiveRecord::Base.connection.select_all(
			" select r.zone_id || '-' || r.carrier_id id, c.currency, max(r.price_min) price_min
			  from rates r, carriers c
			  WHERE r.status=2
			  AND c.id=r.carrier_id
			  AND r.zone_id is not null
			  group by r.zone_id, c.currency, r.carrier_id "
		)
	 end  	  
  	  
	 r = Array.new
	 
	 result.each do |row|
	 	row['currency'] == currency ? rate = 1.0 : rate = ExchangeRate.exchange(row['currency'], currency)
		r.push([row['id'], row['price_min'].to_f / rate.to_f ])
	 end
	 
	 return r

  end    
  
  
  def self.from_file(file, current_user, carrier_id)
  	 start = Time.now

  	 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
	 case adapter_type
	 when "mysql2", "postgresql"
	   _now = "now()"
	   _concat1 = "concat(carrier_prefix,start_date)"
	   _concat2 = "concat(prefix,start_date)"
	 when "sqlite3"
	   _now = "DATETIME('now')"
	   _concat1 = "(carrier_prefix||start_date)"
	   _concat2 = "(prefix||start_date)"
	 end  	  
  	 
  	 

  	 # pulizia 
  	 Delayed::Worker.logger.debug "pulizia"
  	 CodeProcess.delete_all(carrier_id: carrier_id)
  	 
  	 Delayed::Worker.logger.debug "import raw file"
  	 imported_rows = 0
     spreadsheet = Xls.get_spreadsheet(file);
     header = spreadsheet.row(1)
     
     rates = []
     (2..spreadsheet.last_row).each do |i|
       row = Hash[[header, spreadsheet.row(i)].transpose]
       
       # ZONA, PREFISSO, PREZZO_MIN, DATA_VALIDITA
       #imported_rows +=1 if Rate.create_with(carrier_id: carrier_id, name: spreadsheet.row(i)[0], prefix: spreadsheet.row(i)[1].to_s, price_min: spreadsheet.row(i)[2], start_date: spreadsheet.row(i)[3]).find_or_create_by(carrier_id: carrier_id, prefix: spreadsheet.row(i)[1].to_s, price_min: spreadsheet.row(i)[2], start_date: spreadsheet.row(i)[3])
       
       imported_rows +=1 if rate = CodeProcess.new(carrier_id: carrier_id, carrier_zone_name: spreadsheet.row(i)[0], carrier_prefix: spreadsheet.row(i)[1].to_s, carrier_price1: spreadsheet.row(i)[2], start_date: Chronic.parse(spreadsheet.row(i)[3]).beginning_of_day)
       rates << rate
	 end
	 CodeProcess.import rates
	 
	 Delayed::Worker.logger.debug "import - inserimento nuove rates"
     @ins = ActiveRecord::Base.connection.execute("
		INSERT into rates (carrier_id, name, prefix, price_min, start_date,created_at, updated_at) 
		SELECT carrier_id, carrier_zone_name, carrier_prefix, carrier_price1, start_date, #{_now}, #{_now}
		FROM code_processes WHERE #{_concat1} not in (
			select #{_concat2} from rates where carrier_id = #{carrier_id}
		)
	 ")
	 
	 Delayed::Worker.logger.debug "import - update rates vecchie"
     @upd = ActiveRecord::Base.connection.select_all(
     	" SELECT carrier_zone_name, carrier_prefix, carrier_price1, start_date
			FROM code_processes WHERE #{_concat1} in (
				select #{_concat2} from rates where carrier_id = #{carrier_id}
			)
     ")
		
	@upd.rows.each do |r|
		Rate.where(:carrier_id => carrier_id, :prefix => r[1], :start_date => r[3]).update_all(price_min: r[2], name: r[0] ) 	
	end
	 
	 Delayed::Worker.logger.debug "spada inizio"
	 Rate.spada(carrier_id)
	 
	 Delayed::Worker.logger.debug "change_rate_status"
	 Rate.change_rate_status(carrier_id)
	 
	 #return imported_rows
	 finish = Time.now
	 elapsed = (finish - start).to_i
	 secs = elapsed % 60
	 mins = elapsed / 60
	 JobNotificationMailer.job_status("Rate Import", current_user , "Success", "Rate Import", "Task completed, imported rows #{imported_rows}\n\nElapsed sec: #{secs}, min: #{mins}").deliver_now
  end
  
  
  def self.change_rate_status(carrier_id, *args)
  	    options = args.extract_options!
  	    param_zone = options[:zone]
        if param_zone
          additional_filter = " and prefix = '#{param_zone}' "
        end    
  	    
		@rates = ActiveRecord::Base.connection.select_all(
			" select prefix, count(*)
				from rates 
				where carrier_id = #{carrier_id}
				#{additional_filter}
				group by prefix
			 "
		)
		
		@rates.rows.each do |z|
			r = Rate.find_by_prefix(z[0])
			if z[1] == 1 
				r.status = 2
				r.save!
			else
				_r = Rate.where(:prefix=>z[0], :carrier_id=>carrier_id ).each do |rs|
					
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
				
			 adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
			 case adapter_type
			 when "mysql2"
				   @upd = ActiveRecord::Base.connection.execute("
					UPDATE rates
					SET rates.status =2 where prefix = '#{z[0]}' and status <> 1 and start_date in
						(
							SELECT start_date
							FROM (select max(start_date) from rates where prefix = '#{z[0]}' and status <> 1) AS inner_table
						)
					")
			when "postgresql"
				   @upd = ActiveRecord::Base.connection.execute("
					UPDATE rates
					SET status =2 where prefix = '#{z[0]}' and status <> 1 and start_date in
						(
							SELECT start_date
							FROM (select max(start_date) from rates where prefix = '#{z[0]}' and status <> 1) AS inner_table
						)
					")
				   
			 when "sqlite3"
					@upd = ActiveRecord::Base.connection.execute(
						" update rates set status=2 where prefix = '#{z[0]}' and status <> 1 and start_date in(
							select max(start_date) from rates where prefix = '#{z[0]}' and status <> 1
						  )
						 "
					)
			 end  	  
					
		end
		
  end
    
  

  def self.spada(carrier_id)
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
  	  
  	  Delayed::Worker.logger.debug "pulizia"
  	  CodeProcess.delete_all(carrier_id: carrier_id)
  	  
  	  
  	  Delayed::Worker.logger.debug "hash zone e codici"
  	  @codes = Hash[Code.pluck(:prefix, :zone_id)]
  	  @zones = Hash[Zone.pluck(:id, :name)]
  	  
  	  
  	  Delayed::Worker.logger.debug "tabella con zone e prefissi nostri"
	  @ins = ActiveRecord::Base.connection.execute("
	  	  INSERT into code_processes 
	  	  (zone_id, zone_name, code_id, carrier_id, prefix, created_at, updated_at, flag_update1) 
	  	  select z.id, z.name, c.id, '#{carrier_id}', c.prefix, #{_now}, #{_now}, NULL from zones z, codes c 
	  	  where z.id=c.zone_id 
	  ")
  	  
	  Delayed::Worker.logger.debug "hash tariffe del carrier active"
	  @rates = Hash.new
  	  Rate.where(:carrier_id => carrier_id, :status=>'active').find_each do |r|
  	  	 s0 = {r.prefix => {:prefix => r.prefix, :name => r.name, :price_min => r.price_min, :start_date => r.start_date} }
  	  	 @rates.deep_merge!(s0)
  	  end	  
  	 
  	  Delayed::Worker.logger.debug "prima fase"
	 # Prima fase, match esatto!
	 # Ns Prefissi vs Carrier
	 CodeProcess.where(:carrier_id => carrier_id).find_each do |c|
	   unless @rates[c.prefix.to_s].nil?
	   	  Rate.where(:carrier_id => carrier_id, :prefix => c.prefix.to_s).update_all(flag1: 'ESATTO_MATCH') 
	   	  
	   	  c.carrier_price1 = @rates[c.prefix.to_s][:price_min]
	   	  c.start_date = @rates[c.prefix.to_s][:start_date]
	   	  c.carrier_prefix = c.prefix.to_s
	   	  c.carrier_zone_name = @rates[c.prefix.to_s][:name]
	   	  c.flag_update1='ESATTO_MATCH'
	   	  c.save
	   end
	 end
	 
	 
	 
	 Delayed::Worker.logger.debug "seconda fase"
	  ## Seconda fase, match simile!
	  ## Ns Prefissi vs Carrier
	  CodeProcess.where(:carrier_id => carrier_id, :flag_update1 => nil).find_each do |c|

		   @code_search = ActiveRecord::Base.connection.select_all("
		   	   SELECT * FROM rates
		   	   WHERE '#{c.prefix}' #{_concat}
		   	   AND carrier_id = #{carrier_id}
		   	   ORDER BY length(prefix) DESC
		   	   LIMIT 1
		   ")
	  	     
		   match = @code_search[0]['prefix'] unless @code_search[0].nil?
		
  	  	   unless @rates[match].nil?
  	  	   	 Rate.where(:carrier_id => carrier_id, :prefix => match).update_all(flag2: 'PREF_VICINO')    
  	  	   	 c.carrier_price1 = @rates[match][:price_min]
  	  	   	 #c.start_date = @rates[c.prefix.to_s][:start_date]
	   	     c.carrier_prefix = match.to_s
	   	     c.carrier_zone_name = @rates[match][:name]
	   	     c.flag_update1='PREF_VICINO'
	   	     c.save
	   	   end
	  end
	  	 
	  Delayed::Worker.logger.debug "terza fase"
	  ## Terza fase, match simile!
	  ## Prefissi Carrier vs Nostri
  	  Rate.where(:carrier_id => carrier_id, :flag1 => nil).find_each do |r|
		   @code_search = ActiveRecord::Base.connection.select_all("
		   	   SELECT * FROM code_processes
		   	   WHERE '#{r.prefix}' #{_concat}
		   	   AND carrier_id = #{carrier_id}
		   	   ORDER BY length(prefix) DESC
		   	   LIMIT 1
		   ")
	  	     
		   match = @code_search[0]['prefix'] unless @code_search[0].nil?
		
  	  	   unless @codes[match].nil?
  	  	   	  r.flag3=match.to_s
  	  	   	  r.save
  	  	   end
		 
	  end
	 
	 Delayed::Worker.logger.debug "cross update"
  	 @cross_upd = ActiveRecord::Base.connection.select_all(
  	  	" SELECT flag3 prefix, MAX(price_min) max_price 
		  FROM rates 
		  WHERE flag3 is not null and carrier_id = #{carrier_id}
		  GROUP BY flag3 "
	 )
	  
	 @cross_upd.each do |row|
	 	 CodeProcess.where(:carrier_id => carrier_id, :prefix => row['prefix']).update_all(carrier_price2: row['max_price'])
	 end
	  
	  Delayed::Worker.logger.debug "each zone finale"
	  @zones.each do |k,v|
	  	  
	  	 @sql_check_previous_price = ActiveRecord::Base.connection.select_all(
			"SELECT 
			coalesce(MAX(alt.carrier_price1#{_casting}), 'NO_FOUND') MAX_PREV
			FROM code_processes AS alt
			WHERE
			carrier_id = #{carrier_id}
			and alt.zone_name='#{v}' AND alt.carrier_price1 <> (SELECT MAX(alt2.carrier_price1) FROM code_processes AS alt2 WHERE carrier_id = #{carrier_id} and alt2.zone_name='#{v}') "
		)
		 
	 	 max_prev = @sql_check_previous_price[0]['MAX_PREV']
	 	 	 
	 	 if max_prev == 'NO_FOUND'
			 @sql_check_previous_price2 = ActiveRecord::Base.connection.select_all(
				"SELECT 
				MAX(alt.carrier_price2) MAX_PREV
				FROM code_processes AS alt
				WHERE
				carrier_id = #{carrier_id}
				and alt.zone_name='#{v}'
			 ")
			 max_prev = @sql_check_previous_price2[0]['MAX_PREV']
			 
	 	  end
	 	 	 
	  CodeProcess.where(:carrier_id => carrier_id, :zone_name => v ).update_all(carrier_price4: max_prev.to_f)
	  end #zones.each

	  
	  
	  @rates_p = ActiveRecord::Base.connection.select_all("
			SELECT zone_name,
			coalesce(MAX(carrier_price1), 0) MAX,
			coalesce(MAX(carrier_price2), 0) MIN,
			coalesce(MAX(carrier_price4), 0) SPORCO 
			FROM code_processes
			WHERE carrier_id = #{carrier_id}
			GROUP BY zone_name	
	  ")
	  @rates_parsed = Hash.new
	  @rates_p.each do |row|
	  	  s0 = {row['zone_name'] => {:max_price => row['MAX'], :min_price => row['MIN'], :dirty_price => row['SPORCO']} }
	  	  @rates_parsed.deep_merge!(s0)
	  end
	  
	  Delayed::Worker.logger.debug "min - max update"
	  @rates_parsed2 = Hash.new
	  @zones.each do |k,v|
	  	  _prices = Array.new
	  	  _prices.push @rates_parsed[v][:min_price] unless @rates_parsed[v].nil?
	  	  _prices.push @rates_parsed[v][:max_price] unless @rates_parsed[v].nil?
	  	  _prices.push @rates_parsed[v][:dirty_price] unless @rates_parsed[v].nil?
	  	  
	  	  sorted = _prices.uniq.sort_by(&:to_f).reverse

	  	  prezzo_max = sorted[0]
	  	  prezzo_min = sorted[1]
	  	  
	  	  if prezzo_min == 0 
	  	  	  prezzo_min = prezzo_max
	  	  end
	  	  if prezzo_max == 0 
	  	  	  prezzo_min = 0
	  	  	  prezzo_max = 60
	  	  end
	  	  prezzo_max=60 if prezzo_max.nil?
	  	  	  
	  	  s0 = {k => {:max_price => prezzo_max, :min_price => prezzo_min} }
	  	  @rates_parsed2.deep_merge!(s0)
	  	  #{k}
	  end	  
	  

	  Delayed::Worker.logger.debug "fine"
	  @time_to_update = ActiveRecord::Base.connection.select_all("
	  		SELECT zone_id
			FROM code_processes
			WHERE carrier_id = #{carrier_id}
			GROUP BY zone_id
	  ")
	  @time_to_update.each do |row|
	  	  CodeProcess.where(:carrier_id => carrier_id, :zone_id => row['zone_id']).update_all(price_min: @rates_parsed2[row['zone_id']][:max_price] )
	  end
	  	  
	  #CodeProcess.delete_all(carrier_id: carrier_id)

  end #SPADA

  
  
end 



private

    def fix_counter_cache
        Carrier.decrement_counter(:rates_count, self.carrier_id_was)
        Carrier.increment_counter(:rates_count, self.carrier_id)
    end  
