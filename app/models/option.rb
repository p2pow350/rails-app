class Option < ApplicationRecord
	
	validates :area, :o_key, :value, presence: true
	validates :o_key, :value, uniqueness: true
	default_scope { order('area, o_key ASC') }
	
	scope :mail_out, -> { where(:area => 'mail_out') }
	
end
