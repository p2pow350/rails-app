# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "highline/import"

puts "Create Admin account..."
admin_email = ask "Enter admin email: "
admin_password = ask "Enter admin password: "

u=User.new(:email => admin_email, :password=> admin_password)
u.save!

puts "Creating Fake data..."
(1..5).each do |i|
	Carrier.create :name => Faker::Company.name, :email => Faker::Internet.email
end

(1..10).each do |i|
	Zone.create :name => Faker::Address.country
end


puts "done!"
puts Carrier.count.to_s + " Carriers created."
puts Zone.count.to_s + " Zones created."