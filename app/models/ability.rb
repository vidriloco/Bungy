class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :access, :rails_admin
      can :dashboard
      
      if user.has_role?(:client_admin)
        can :manage, Truck, :company_id => user.company_id
        can :manage, GpsUnit, :company_id => user.company_id
        can :read, Company, :id => user.company_id
      elsif user.has_role?(:client_owner)
        can :manage, User, :company_id => user.company_id
        can :manage, Truck, :company_id => user.company_id
        can :manage, GpsUnit, :company_id => user.company_id
        can :read, Company, :id => user.company_id
        
      elsif user.has_role?(:superuser)
        can :manage, [User,
                      Company,
                      Truck,
                      Instant,
                      GpsUnit]
      end
    end
  end
end