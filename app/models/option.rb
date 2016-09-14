class Option < ApplicationRecord
	
	validates :area, :key, :value, presence: true
	validates :key, :value, uniqueness: true
	default_scope { order('area, key ASC') }
	
	scope :mail_out, -> { where(:area => 'mail_out') }
	
end
