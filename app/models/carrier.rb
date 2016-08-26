class Carrier < ActiveRecord::Base
	validates :name, :presence => true
end
