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
  	  
end
