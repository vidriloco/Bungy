class Checkpoint < ActiveRecord::Base
  include Geography
  
  belongs_to :route
  
  validates :route, :title, :expected_timing, :presence => true
  attr_accessor :lat, :lon
  
  before_validation :apply_coordinates
  
  def apply_coordinates
    self.apply_geo({"lon" => lon, "lat" => lat})
  end
  
  def self.from_company(id)
    Checkpoint.where(:route_id => Route.where(:company_id => id).map(&:id))
  end
  
  def company
    route.company.name
  end
  
  def lat
    return @lat unless @lat.nil?
    return coordinates.lat unless coordinates.nil?
  end
  
  def lon
    return @lon unless @lon.nil?
    return coordinates.lon unless coordinates.nil?
  end
  
  private
  
  rails_admin do 
    label do
      I18n.t('models.checkpoint.name')
    end
    
    list do      
      field :title do
        label I18n.t('models.checkpoint.fields.title')
      end
      
      field :company do
        label I18n.t('models.route.fields.company')
        visible do
          bindings[:view].current_user.has_role?(:superuser)
        end
      end
      
      field :expected_timing do 
        label I18n.t('models.checkpoint.fields.expected_timing')
        
        pretty_value do
          "#{value} #{I18n.t('units.time.minutes')}"
        end
      end      
    end
    
    show do
      field :title do 
        label I18n.t('models.checkpoint.fields.title')
      end
      
      field :expected_timing do 
        label I18n.t('models.checkpoint.fields.expected_timing')
        
        pretty_value do
          "#{value} #{I18n.t('units.time.minutes')}"
        end
      end
      
      field :route do 
        label I18n.t('models.checkpoint.fields.route')
      end
      
      field :lat do 
        label I18n.t('models.checkpoint.fields.latitude')
      end
      
      field :lon do
        label I18n.t('models.checkpoint.fields.longitude')
      end
    end
    
    edit do
      field :title do 
        label I18n.t('models.checkpoint.fields.title')
      end
      
      field :expected_timing do 
        label I18n.t('models.checkpoint.fields.expected_timing')
        help I18n.t('models.checkpoint.fields.expected_timing_help')
      end
      
      field :route do 
        label I18n.t('models.checkpoint.fields.route')
      end
      
      field :map do
        help I18n.t('models.checkpoint.fields.map')
        def render
          bindings[:view].render :partial => 'checkpoints/admin/map', :locals => {:field => self, :form => bindings[:form]}
        end
      end
      
      field :lat do 
        label I18n.t('models.checkpoint.fields.latitude')
        help I18n.t('admin.form.required')
      end
      
      field :lon do
        label I18n.t('models.checkpoint.fields.longitude')
        help I18n.t('admin.form.required')
      end
    end
    
  end
end
