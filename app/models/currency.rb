class Currency

  # Returns an array of currency id where
  # priority < 10
  def self.major_currencies(hash)
  	
    hash.inject([]) do |array, (id, attributes)|
      priority = attributes[:priority]
      if priority && priority < 10
        array[priority] ||= []
        array[priority] << id
      end
      array
    end.compact.flatten
  end
  
  # Returns an array of all currency id
  def self.all_currencies(hash)
    hash.keys
  end
  
  def self.currency_codes
    currencies = []
    Money::Currency.table.values.each do |currency|
      currencies = currencies + [[currency[:name] + ' (' + currency[:iso_code] + ')', currency[:iso_code]]]
    end
    currencies
  end
  
  def self.select_currency
    currencies = []
    currencies = currencies + [:eur]
    
    Money::Currency.table.keys.each do |currency|
    	priority = currency[:priority]
    	if priority && priority < 10
    		currencies = currencies + currency[:name] if currency[:name] != ':eur'
    	end
    end
    currencies
  end  
  
end
