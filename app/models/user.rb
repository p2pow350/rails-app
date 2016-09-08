class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable
         
  validates :email, presence: true
  validates :email, uniqueness: true
  default_scope { order('name ASC') }
  default_value_for :default_locale, 'it'
  
end
