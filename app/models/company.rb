class Company < ActiveRecord::Base
  has_many :trucks
  has_many :users
  has_many :gps_units
end
