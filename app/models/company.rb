class Company < ActiveRecord::Base
  has_many :trucks
  has_many :users
  has_many :gps_units
  
  rails_admin do
    visible do
      bindings[:controller].current_user.has_role?(:superuser)
    end
  end
end
