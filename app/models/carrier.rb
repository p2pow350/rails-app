class Carrier < ActiveRecord::Base
	has_many :rates, dependent: :destroy
		
	validates :name, :presence => true
	validates :name, uniqueness: true
		
	default_value_for :status, 1
	default_value_for :is_supplier, true
	default_value_for :currency, :eur
	default_scope { order('name ASC') }

    scope :enabled, -> { where(status: true) }
    scope :disabled, -> { where(status: false) }
	
	def self.from_file(file)
		imported_rows = 0
	    spreadsheet = Xls.get_spreadsheet(file); header = spreadsheet.row(1)                
	    spreadsheet.each(Hash[ *header.collect { |v| [ v.downcase.to_sym,v ] }.flatten ]) do |hash|
	    	imported_rows +=1 if Carrier.create(hash)
	    end
	    return imported_rows
	end	

end
