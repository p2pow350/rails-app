class Code < ActiveRecord::Base
  belongs_to :zone
  
  validates :name, :prefix, :zone_id, :presence => true
  validates :name, :prefix, uniqueness: true
  validates :prefix, numericality: { only_integer: true }
  
  default_scope { order('name ASC') }
  
  def self.from_file(file)
  	 imported_rows = 0
     spreadsheet = Xls.get_spreadsheet(file);
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
		#code = find_by_prefix(row["prefix"]) || new
        #code.attributes = row.to_hash.slice(*row.to_hash.keys)
        
        c = Code.create_with(:name => row[0].to_s, :prefix => row[1].to_s, :zone_id => row[2].to_i).find_or_create_by(prefix: row["prefix"])
		imported_rows +=1 if c
	  end
	  
	  return imported_rows
  end
  
  
  
end
