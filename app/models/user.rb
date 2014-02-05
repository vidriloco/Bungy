class User < ActiveRecord::Base  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :company
  
  def self.roles
    { superuser: 0, client_owner: 1, client_admin: 2 }
  end
  
  def has_role?(role_name)
    role == User.roles[role_name]
  end
end
