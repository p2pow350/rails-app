class Code < ActiveRecord::Base
  belongs_to :zone
  
  validates :name, :prefix, :zone_id, :presence => true
  validates :name, :prefix, uniqueness: true
  validates :prefix, numericality: { only_integer: true }
  
  default_scope { order('name ASC') }
  
  def self.from_file(file)
  	imported_rows = 0
      spreadsheet = Xls.get_spreadsheet(file); header = spreadsheet.row(1)                
      spreadsheet.each(Hash[ *header.collect { |v| [ v.downcase.to_sym,v ] }.flatten ]) do |hash|
      	imported_rows +=1 if Code.create(hash)
      end
      return imported_rows
  end	
  
end
