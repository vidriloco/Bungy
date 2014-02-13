class Route < ActiveRecord::Base
  has_many :checkpoints
  belongs_to :company
  
  private
  
  rails_admin do 
    label do
      I18n.t('models.route.name')
    end
    
    list do      
      field :name do
        label I18n.t('models.route.fields.name')
      end
      
      field :company do
        label I18n.t('models.route.fields.company')
        visible do
          bindings[:view].current_user.has_role?(:superuser)
        end
      end
      
      field :checkpoints
      
      field :created_at do
        label I18n.t('models.route.fields.created_at')
      end
      
      
    end
    
    edit do       
      field :name do
        label I18n.t('models.route.fields.name')
      end
      
      field :details do
        label I18n.t('models.route.fields.details')
      end
      
      field :company do
        label I18n.t('models.route.fields.company')
      end
      
      field :checkpoints
    end
  end
end
