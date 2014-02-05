class Truck < ActiveRecord::Base
  has_one :gps_unit
  belongs_to :company
end
