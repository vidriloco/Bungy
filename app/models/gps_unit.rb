class GpsUnit < ActiveRecord::Base
  has_many :instants
  belongs_to :truck
  belongs_to :company
end
