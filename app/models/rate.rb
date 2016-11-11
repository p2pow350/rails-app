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
		    @upd = ActiveRecord::Base.connection.execute(
		    	" update rates set status=2 where prefix = '#{z[0]}' and status <> 1 and start_date in(
					select max(start_date) from rates where prefix = '#{z[0]}' and status <> 1
				  )
		    	 "
		    )

		end
		
  end
  
  
  def self.spada_rifare(carrier_id)
  	  unless Rate.where(:carrier_id => carrier_id).count == 0 

  	  @codes = Hash[Code.pluck(:prefix, :zone_id)]
	  
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
		 
  	  	   unless @codes[match].nil?
  	  	   	f3=@codes[match]
  	  	   	s3= {f3 => {:carrier_zone_name => r.name, :carrier_prefix => r.prefix, :price_min => r.price_min, :start_date => r.start_date, :flag1 => nil, :flag2 => nil, :flag3 => match} }
  	  	   	spada.deep_merge!(s3) if spada[f3][:flag1] != 'EXACT'
  	  	   end
		 
		 counter-=1
		end while counter >= 0
	  end
	  
	  
	  p spada 
	  
  	  #spada.each do |key, value|
  	  #	  puts value
  	  #	  Rate.where(prefix: "355").update_all(flag1: "cacca")
  	  #	  
  	  #end
  	  
  	  
#{1179=>{:carrier_zone_name=>nil, :carrier_prefix=>nil, :price_min=>nil, :start_date=>nil, :flag1=>nil, :flag2=>nil, :flag3=>nil},
# 1180=>{:carrier_zone_name=>nil, :carrier_prefix=>nil, :price_min=>nil, :start_date=>nil, :flag1=>nil, :flag2=>nil, :flag3=>nil},
# 1181=>{:carrier_zone_name=>nil, :carrier_prefix=>nil, :price_min=>nil, :start_date=>nil, :flag1=>nil, :flag2=>nil, :flag3=>nil},
# 1182=>{:carrier_zone_name=>nil, :carrier_prefix=>nil, :price_min=>nil, :start_date=>nil, :flag1=>nil, :flag2=>nil, :flag3=>nil},
# 1183=>{:carrier_zone_name=>nil, :carrier_prefix=>nil, :price_min=>nil, :start_date=>nil, :flag1=>nil, :flag2=>nil, :flag3=>nil},
# 1184=>{:carrier_zone_name=>nil, :carrier_prefix=>nil, :price_min=>nil, :start_date=>nil, :flag1=>nil, :flag2=>nil, :flag3=>nil},
# 1185=>
#  {:carrier_zone_name=>"ALBANIA",
#   :carrier_prefix=>"355",
#   :price_min=>#<BigDecimal:7f9ebcfbb5f0,'0.1323E0',9(18)>,
#   :start_date=>Fri, 02 Sep 2016 00:00:00 CEST +02:00,
#   :flag1=>"EXACT",
#   :flag2=>nil,
#   :flag3=>nil},
# 2375=>
#  {:carrier_zone_name=>"ALBANIA",
#   :carrier_prefix=>"355",
#   :price_min=>#<BigDecimal:7f9ebc5732f0,'0.1323E0',9(18)>,
#   :start_date=>Fri, 02 Sep 2016 00:00:00 CEST +02:00,
#   :flag1=>nil,
#   :flag2=>"SIMILAR",
#   :flag3=>nil},
# 1186=>
#  {:carrier_zone_name=>"ALBANIA TIRANE",
#   :carrier_prefix=>"355423",
#   :price_min=>#<BigDecimal:7f9ebdb422c0,'0.1327E0',9(18)>,
#   :start_date=>Fri, 02 Sep 2016 00:00:00 CEST +02:00,
#   :flag1=>"EXACT",
#   :flag2=>nil,
#   :flag3=>nil},
# 1187=>
#  {:carrier_zone_name=>"ALBANIA",
#   :carrier_prefix=>"355",
#   :price_min=>#<BigDecimal:7f9eba9e6578,'0.1323E0',9(18)>,
#   :start_date=>Fri, 02 Sep 2016 00:00:00 CEST +02:00,
#   :flag1=>nil,
#   :flag2=>"SIMILAR",
#   :flag3=>nil},
  	  
  	  
  	  
  	  
	 
 	end #unless
  end
  
  

  def self.spada(carrier_id)
  	  CodeProcess.delete_all(carrier_id: carrier_id)
  	  
  	  @codes = Hash[Code.pluck(:prefix, :zone_id)]
  	  @zones = Hash[Zone.pluck(:id, :name)]
  	  
	  @ins = ActiveRecord::Base.connection.execute(" INSERT into code_processes (zone_id, code_id, carrier_id, prefix, created_at, updated_at) select z.id, c.id, '#{carrier_id}', c.prefix, DATETIME('now'), DATETIME('now') from zones z, codes c where z.id=c.zone_id ")
  	  
	  @rates = Hash.new
  	  Rate.where(:carrier_id => carrier_id, :status=>'active').each do |r|
  	  	 s0 = {r.prefix => {:prefix => r.prefix, :name => r.name, :price_min => r.price_min} }
  	  	 @rates.deep_merge!(s0)
  	  end	  
  	  
	 # Prima fase, match esatto!
	 # Ns Prefissi vs Carrier
	 CodeProcess.where(:carrier_id => carrier_id).each do |c|
	   unless @rates[c.prefix.to_s].nil?
	   	  Rate.where(:carrier_id => carrier_id, :prefix => c.prefix.to_s).update_all(flag1: 'ESATTO_MATCH') 
	   	  
	   	  c.carrier_price1 = @rates[c.prefix.to_s][:price_min]
	   	  c.carrier_prefix = c.prefix.to_s
	   	  c.carrier_zone_name = @rates[c.prefix.to_s][:name]
	   	  c.flag_update1='ESATTO_MATCH'
	   	  c.save
	   end
	 end
	 
	 
	  ## Seconda fase, match simile!
	  ## Ns Prefissi vs Carrier
  	  CodeProcess.where(:carrier_id => carrier_id).order("LENGTH(prefix) DESC").each do |c|
  	  	_substring=c.prefix
		counter=_substring.length
		
		begin
		 match = _substring[0..counter]
		 
  	  	   unless @rates[match].nil?
  	  	   	Rate.where(:carrier_id => carrier_id, :prefix => match).update_all(flag2: 'PREF_VICINO')    
  	  	   	c.carrier_price1 = @rates[match][:price_min]
	   	    c.carrier_prefix = match.to_s
	   	    c.carrier_zone_name = @rates[match][:name]
	   	    c.flag_update1='PREF_VICINO'
	   	    c.save
  	  	   end
		 
		 counter-=1
		end while counter >= 0
	  end
	 
	  
	  ## Terza fase, match simile!
	  ## Prefissi Carrier vs Nostri
  	  Rate.where(:carrier_id => carrier_id, :flag1 => nil).each do |r|
  	  	_substring=r.prefix
		counter=_substring.length
		
		begin
		 match = _substring[0..counter]
		 
  	  	   unless @codes[match].nil?
  	  	   	r.flag3=match.to_s
  	  	   	r.save
  	  	   end
		 
		 counter-=1
		end while counter >= 0
	  end
	 
	  
  	 @cross_upd = ActiveRecord::Base.connection.select_all(
  	  	" SELECT flag3 prefix, MAX(price_min) max_price 
		  FROM rates 
		  WHERE flag3 is not null and carrier_id = #{carrier_id}
		  GROUP BY flag3 "
	 )
	  
	 @cross_upd.each do |row|
	 	 CodeProcess.where(:carrier_id => carrier_id, :prefix => row['prefix']).update_all(carrier_price2: row['max_price'])
	 end
	  
	  
	  @zones.each do |k,v|
	  	  
	  	 @sql_check_previous_price = ActiveRecord::Base.connection.select_all(
			"SELECT 
			IFNULL(MAX(alt.carrier_price1), 'NO_FOUND') MAX_PREV
			FROM code_processes AS alt
			WHERE
			carrier_id = #{carrier_id}
			and alt.zone_id='#{k}' AND alt.carrier_price1 <> (SELECT MAX(alt2.carrier_price1) FROM code_processes AS alt2 WHERE carrier_id = #{carrier_id} and alt2.zone_id='#{k}') "
		)
		 
	 	 @sql_check_previous_price.each do |row|
	 	 	 max_prev = row['MAX_PREV']
	 	 	 
	 	 	 if row['MAX_PREV'] == 'NO_FOUND'
				 @sql_check_previous_price2 = ActiveRecord::Base.connection.select_all(
					"SELECT 
					MAX(alt.carrier_price2) MAX_PREV
					FROM code_processes AS alt
					WHERE
					carrier_id = #{carrier_id}
					and alt.zone_id='#{k}'
				 ")
				 @sql_check_previous_price2.each do |row|
				 	 max_prev = row['MAX_PREV']
				 end
				 
	 	 	 end
	 	 	 
	 	 	 CodeProcess.where(:carrier_id => carrier_id, :zone_id => '#{k}').update_all(carrier_price4: max_prev.to_f)
	 	 end

	  end #zones.each
	  
	  	  
	  @rates_p = ActiveRecord::Base.connection.select_all("
			SELECT zone_id,
			IFNULL(MAX(carrier_price1), 0) MAX,
			IFNULL(MAX(carrier_price2), 0) MIN,
			IFNULL(MAX(carrier_price4), 0) SPORCO 
			FROM code_processes
			WHERE carrier_id = #{carrier_id}
			GROUP BY zone_id	
	  ")
	  @rates_parsed = Hash.new
	  @rates_p.each do |row|
	  	  s0 = {row['zone_id'] => {:max_price => row['MAX'], :min_price => row['MIN'], :dirty_price => row['SPORCO']} }
	  	  @rates_parsed.deep_merge!(s0)
	  end
	  
	  
	  @rates_parsed2 = Hash.new
	  @zones.each do |k,v|
	  	  _prices = Array.new
	  	  _prices.push @rates_parsed[k][:min_price] unless @rates_parsed[k].nil?
	  	  _prices.push @rates_parsed[k][:max_price] unless @rates_parsed[k].nil?
	  	  _prices.push @rates_parsed[k][:dirty_price] unless @rates_parsed[k].nil?
	  	  
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
	  

	  
	  @time_to_update = ActiveRecord::Base.connection.select_all("
	  		SELECT prefix, zone_id
			FROM code_processes
			WHERE carrier_id = #{carrier_id}
			GROUP BY prefix, zone_id
	  ")
	  @time_to_update.each do |row|
	  	  
	  	  Rate.where(:carrier_id => carrier_id, :prefix => row['prefix']).update_all(zone_id: row['zone_id'], found_price: @rates_parsed2[row['zone_id']][:max_price] )
	  	  
	  end

	  
	  CodeProcess.delete_all(carrier_id: carrier_id)
	  
  end #SPADA

  
  
end 



private

    def fix_counter_cache
        Carrier.decrement_counter(:rates_count, self.carrier_id_was)
        Carrier.increment_counter(:rates_count, self.carrier_id)
    end  
