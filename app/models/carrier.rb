class Carrier < ActiveRecord::Base
	validates :name, :presence => true
	default_value_for :is_supplier, true
end
