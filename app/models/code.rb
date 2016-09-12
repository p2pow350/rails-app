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
        
        Code.create_with(:name => row["name"].to_s, :prefix => row["prefix"].to_s, :zone_id => row["zone"].to_i).find_or_create_by(prefix: row["prefix"].to_s)
		imported_rows +=1 if Code.new_record?
	  end
	  
	  return imported_rows
  end
  
  
  
end
