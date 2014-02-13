class User < ActiveRecord::Base  
  serialize :roles, Array
  
  validates :username, :presence => true, :uniqueness => true
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
  
  def role_enum
    User.roles_for_user(self)
  end
  
  def self.roles_for_user(user)
    trans_roles = User.roles.to_a.map { |ro| [I18n.t("models.user.roles.#{ro[0]}"), ro[1]]  }
    return trans_roles[1,2] if user.has_role?(:client_owner)
    return [trans_roles.last] if user.has_role?(:client_admin)
    trans_roles
  end
  
  private
  
  rails_admin do 
    label do
      I18n.t('models.user.name')
    end
    
    list do      
      
      field :username do
        label I18n.t('models.user.fields.username')
      end
      
      field :full_name do
        label I18n.t('models.user.fields.full_name')
      end
      
      field :role do
        label I18n.t('models.user.fields.role')
      end
      
      field :email do
        label I18n.t('models.user.fields.email')
      end
      
      field :company do
        label I18n.t('models.user.fields.company')
        visible do
          bindings[:view].current_user.has_role?(:superuser)
        end
      end
      
      field :last_sign_in_at do
        label I18n.t('models.user.fields.last_sign_in_at')
      end
      
      field :sign_in_count do
        label I18n.t('models.user.fields.sign_in_count')
      end
    end
    
    edit do       
      field :username do
        label I18n.t('models.user.fields.username')
      end
      
      field :full_name do
        label I18n.t('models.user.fields.full_name')
      end
      
      field :role, :enum do
        label I18n.t('models.user.fields.role')
        
        enum do
          User.roles_for_user(bindings[:view].current_user)
        end
      end
      
      field :email do
        label I18n.t('models.user.fields.email')
      end
      
      field :company do
        label I18n.t('models.user.fields.company')
      end
      
      field :password do
        label I18n.t('models.user.fields.password')
      end
      
      field :password_confirmation do
        label I18n.t('models.user.fields.password_confirmation')
      end
    end
  end
end
