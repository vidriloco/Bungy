# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Company.create(:name => "Transpotting")
@truck=Truck.create(:plate => "XMR-3123-21", :name => "Volvo Doble XSM", :company => Company.first)
GpsUnit.create(:identifier => "296767", :rmuid => "E30332L2L2", :truck_id => @truck, :company => Company.first)
User.create(:username => "antonio", :email => "antonio@transpotting.com", :password => "12345678", :password_confirmation => "12345678", :company => Company.first, :role => User.roles[:client_owner])
User.create(:username => "root", :email => "alex@transitgo.com", :password => "12345678", :password_confirmation => "12345678", :role => User.roles[:superuser])